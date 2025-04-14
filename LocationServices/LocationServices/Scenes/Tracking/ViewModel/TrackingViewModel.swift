//
//  TrackingViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import AWSIoT
import AWSIoTEvents
import AWSCognitoIdentity
import AwsCommonRuntimeKit

final class TrackingViewModel: TrackingViewModelProtocol {
    enum Constants {
        static let majorDistanceChange: CGFloat = 30
    }
    
    weak var delegate: TrackingViewModelDelegate?
    
    private let trackingService: TrackingServiceable
    private let geofenceService: GeofenceServiceable
    
    private var lastLocation: CLLocation?
    private var history: [TrackingHistoryPresentation] = []
    var mqttClient: Mqtt5Client?
    var mqttIoTContext: MqttIoTContext?
    let backgroundQueue = DispatchQueue(label: "background_queue",
                                        qos: .background)
    
    var busRoutes: [BusRoute] = []
    
    init(trackingService: TrackingServiceable, geofenceService: GeofenceServiceable) {
        self.trackingService = trackingService
        self.geofenceService = geofenceService
        busRoutes = getBusRoutesData()?.busRoutesData ?? []
    }
    
    func getBusRoutesData() -> BusRoutesData? {
        do {
            if let jsonData = JsonHelper.loadJSONFile(fileName: "RoutesData") {
                let decoder = JSONDecoder()
                let busRoutesData = try decoder.decode(BusRoutesData.self, from: jsonData)
                return busRoutesData
            }
            return nil
        }
        catch {
            print("Error decoding BusRoutesData: \(error)")
            return nil
        }
    }
    
    func startIoTSubscription() {
        subscribeToAWSNotifications()
    }
    
    func stopIoTSubscription() {
        unsubscribeFromAWSNotifications()
    }
    
    func fetchListOfGeofences(collectionName: String) async -> [GeofenceDataModel]? {
        let result = await geofenceService.getGeofenceList(collectionName: collectionName)
        switch result {
        case .success(let geofences):
            return geofences
        case .failure(let error):
            print(error)
            return nil
        }
    }
    
    func showGeofences(routeId: String, geofences: [GeofenceDataModel]) {
        self.delegate?.showGeofences(routeId: routeId, geofences)
    }
    
    func drawTrackingRoute(routeId: String, coordinates: [CLLocationCoordinate2D]) {
        self.delegate?.drawTrackingRoute(routeId: routeId, coordinates: coordinates)
    }
    
    func evaluateGeofence(coordinate: CLLocationCoordinate2D, collectionName: String) async {
        do {
            try await geofenceService.evaluateGeofence(lat: coordinate.latitude, long: coordinate.longitude, collectionName: collectionName)
        }
        catch {
            print(error)
        }
    }
    
    func createClient(clientOptions: MqttClientOptions, iotContext: MqttIoTContext) throws -> Mqtt5Client {

        let clientOptionsWithCallbacks: MqttClientOptions

        clientOptionsWithCallbacks = MqttClientOptions(
            hostName: clientOptions.hostName,
            port: clientOptions.port,
            bootstrap: clientOptions.bootstrap,
            socketOptions: clientOptions.socketOptions,
            tlsCtx: clientOptions.tlsCtx,
            onWebsocketTransform: iotContext.onWebSocketHandshake,
            httpProxyOptions: clientOptions.httpProxyOptions,
            connectOptions: clientOptions.connectOptions,
            sessionBehavior: clientOptions.sessionBehavior,
            extendedValidationAndFlowControlOptions: clientOptions.extendedValidationAndFlowControlOptions,
            offlineQueueBehavior: clientOptions.offlineQueueBehavior,
            retryJitterMode: clientOptions.retryJitterMode,
            minReconnectDelay: clientOptions.minReconnectDelay,
            maxReconnectDelay: clientOptions.maxReconnectDelay,
            minConnectedTimeToResetReconnectDelay: clientOptions.minConnectedTimeToResetReconnectDelay,
            pingTimeout: clientOptions.pingTimeout,
            connackTimeout: clientOptions.connackTimeout,
            ackTimeout: clientOptions.ackTimeout,
            topicAliasingOptions: clientOptions.topicAliasingOptions,
            onPublishReceivedFn: iotContext.onPublishReceived,
            onLifecycleEventStoppedFn: iotContext.onLifecycleEventStopped,
            onLifecycleEventAttemptingConnectFn: iotContext.onLifecycleEventAttemptingConnect,
            onLifecycleEventConnectionSuccessFn: iotContext.onLifecycleEventConnectionSuccess,
            onLifecycleEventConnectionFailureFn: iotContext.onLifecycleEventConnectionFailure,
            onLifecycleEventDisconnectionFn: iotContext.onLifecycleEventDisconnection)

        let mqtt5Client = try Mqtt5Client(clientOptions: clientOptionsWithCallbacks)
        return mqtt5Client
    }
    
    private func subscribeToAWSNotifications() {
        backgroundQueue.async {
            Task {
                do {
                    await self.createIoTClientIfNeeded()
                    if self.mqttClient != nil {
                        try self.connectClient(client: self.mqttClient!, iotContext: self.mqttIoTContext!)
                    }
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    private func createIoTClientIfNeeded() async {
        guard let configuration = GeneralHelper.getAWSConfigurationModel(),
              !configuration.webSocketUrl.isEmpty, mqttClient == nil else {
            return
        }
        do {
            let identityIdOutput = try await CognitoAuthHelper.getAWSIdentityId(identityPoolId: configuration.identityPoolId)
            if let identityId = identityIdOutput.identityId {
                UserDefaultsHelper.save(value: identityId, key: .identityId)
                mqttIoTContext = MqttIoTContext(onPublishReceived: {payloadData in
                    if let payload = payloadData.publishPacket.payload {
                        guard let model = try? JSONDecoder().decode(TrackingEventModel.self, from: payload) else { return }
                        self.sendGeofenceNotification(model: model)

                    }
                }, topicName: "\(identityId)/tracker", identityId: identityId)
                print("topicName: \(identityId)/tracker")
                let ConnectPacket = MqttConnectOptions(keepAliveInterval: 60000, clientId: identityId)
                let tlsOptions = TLSContextOptions.makeDefault()
                let tlsContext = try TLSContext(options: tlsOptions, mode: .client)
                let elg = try EventLoopGroup()
                let resolver = try HostResolver.makeDefault(eventLoopGroup: elg,
                                                            maxHosts: 8,
                                                            maxTTL: 30)
                let bootstrap = try ClientBootstrap(eventLoopGroup: elg, hostResolver: resolver)
                let clientOptions = MqttClientOptions(
                    hostName: configuration.webSocketUrl,
                    port: UInt32(443),
                    bootstrap: bootstrap,
                    tlsCtx: tlsContext,
                    connectOptions: ConnectPacket,
                    connackTimeout: TimeInterval(10))
                mqttClient = try createClient(clientOptions: clientOptions, iotContext: mqttIoTContext!)
                mqttIoTContext?.client = mqttClient
            }
        }
        catch {
            mqttIoTContext?.printView("Failed to setup client.")
        }
    }
    
    func sendGeofenceNotification(model: TrackingEventModel) {
        let eventText: String
        switch model.trackerEventType {
        case .enter:
            eventText = StringConstant.entered
        case .exit:
            eventText = StringConstant.exited
        }
        
        let busRouteId = model.geofenceId.split(separator: "-").first ?? ""
        let stopId = Int(model.geofenceId.split(separator: "-").last?.lowercased() ?? "0")
        if let busRoute = busRoutes.first(where:  { $0.id == busRouteId }),
           let stop = busRoute.stopCoordinates.first(where: { $0.id == stopId })?.stopProperties {
            let message = "\(busRoute.name.split(separator: " ").dropLast().joined(separator: " ")): \(eventText) \(stop.stop_name)"
            let userInfo = ["title": StringConstant.trackingNotificationTitle, "message": message]
            NotificationCenter.default.post(name: Notification.showTrackingNotification, object: nil, userInfo: userInfo)
        }
    }
    
    func connectClient(client: Mqtt5Client, iotContext: MqttIoTContext) throws {
        try client.start()
        if iotContext.semaphoreConnectionSuccess.wait(timeout: .now() + 5) == .timedOut {
            print("Connection Success Timed out after 5 seconds")
        }
    }

    func stopClient(client: Mqtt5Client, iotContext: MqttIoTContext) {
        backgroundQueue.async {
            do {
                try client.stop()
                if iotContext.semaphoreStopped.wait(timeout: .now() + 5) == .timedOut {
                    print("Stop timed out after 5 seconds")
                }
            }
            catch {
                print("Failed to stop client: \(error.localizedDescription)")
            }
        }
    }
    
    private func unsubscribeFromAWSNotifications() {
        guard mqttClient != nil else {
            return
        }
        stopClient(client: mqttClient!, iotContext: mqttIoTContext!)
    }
}
