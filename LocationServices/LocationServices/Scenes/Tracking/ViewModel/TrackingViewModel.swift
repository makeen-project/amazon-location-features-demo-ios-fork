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
    private(set) var isTrackingActive: Bool = false
    private var history: [TrackingHistoryPresentation] = []
    var hasHistory: Bool { !history.isEmpty }
    
    //private var iotDataManager: AWSIoTDataManager?
    //private var iotManager: AWSIoTManager?
    //private var iot: AWSIoT?
    
    init(trackingService: TrackingServiceable, geofenceService: GeofenceServiceable) {
        self.trackingService = trackingService
        self.geofenceService = geofenceService
    }
    
    func startTracking() {
        isTrackingActive = true
        subscribeToAWSNotifications()
    }
    
    func stopTracking() {
        isTrackingActive = false
        unsubscribeFromAWSNotifications()
    }
    
    func resetHistory() {
        history = []
    }
    
    func trackLocationUpdate(location: CLLocation?) {
        guard let location else { return }
        
        guard isTrackingActive else {
            stopTracking()
            return
        }
        Task {
            if let lastLocation {
                guard location.distance(from: lastLocation) > Constants.majorDistanceChange else { return }
                self.lastLocation = location
                await sendLocationUpdate(location)
            } else {
                lastLocation = location
                await sendLocationUpdate(location)
            }
        }
    }
    
    func fetchListOfGeofences() async {
        
        // if we are not authorized do not send it
        if UserDefaultsHelper.getAppState() != .loggedIn {
            delegate?.showGeofences([])
            return
        }
        
        let result = await geofenceService.getGeofenceList()
            switch result {
            case .success(let geofences):
                DispatchQueue.main.async {
                    self.delegate?.showGeofences(geofences)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    if(ErrorHandler.isAWSStackDeletedError(error: error)) {
                        ErrorHandler.handleAWSStackDeletedError(delegate: self.delegate as AlertPresentable?)
                    }
                    else {
                        let model = AlertModel(title: StringConstant.error, message: error.localizedDescription)
                        self.delegate?.showAlert(model)
                    }
                }
            }
    }
    
    private func sendLocationUpdate(_ location: CLLocation) async {
        do {
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            
            let result = try await trackingService.updateTrackerLocation(lat: lat, long: long)
            await updateHistory()
            try await geofenceService.evaluateGeofence(lat: lat, long: long)
        }
        catch {
            DispatchQueue.main.async {
                self.history = []
                if(ErrorHandler.isAWSStackDeletedError(error: error)) {
                    ErrorHandler.handleAWSStackDeletedError(delegate: self.delegate as AlertPresentable?)
                } else {
                    let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                    
                    self.delegate?.showAlert(model)
                }
            }
        }
    }
    
    func updateHistory() async {
        do {
            let result = try await trackingService.getAllTrackingHistory()
            NotificationCenter.default.post(name: Notification.updateTrackingHistory, object: self, userInfo: ["history": history])
            self.history = result
            if self.isTrackingActive {
                self.delegate?.drawTrack(history: history)
            } else {
                self.delegate?.historyLoaded()
            }
        }
        catch {
            self.history = []
            if(ErrorHandler.isAWSStackDeletedError(error: error)) {
                ErrorHandler.handleAWSStackDeletedError(delegate: self.delegate as AlertPresentable?)
            } else {
                let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                DispatchQueue.main.async {
                    self.delegate?.showAlert(model)
                }
            }
        }
    }
    
    var mqttClient: Mqtt5Client?
    
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

    let backgroundQueue = DispatchQueue(label: "background_queue",
                                        qos: .background)
    
    private func subscribeToAWSNotifications() {
        backgroundQueue.async {
            do {
                self.createIoTClientIfNeeded()
                try self.connectClient(client: self.mqttClient!, iotContext: self.mqttIoTContext!)
            }
            catch {
                print(error)
            }
        }
        
//        createIoTManagerIfNeeded {
//            
//            guard let identityId = getAWSIdentityId(identityPoolId: "", region: "").identityId else {
//                return
//            }
//            
//            self.iotDataManager?.connectUsingWebSocket(withClientId: identityId, cleanSession: true) { status in
//                print("Websocket connection status \(status.rawValue)")
//                
//                switch status {
//                case .connected:
//                    let status = self.iotDataManager?.subscribe(
//                        toTopic: "\(identityId)/tracker",
//                        qoS: .messageDeliveryAttemptedAtMostOnce,
//                        messageCallback: { [weak self] payload in
//                            let stringValue = NSString(data: payload, encoding: String.Encoding.utf8.rawValue)!
//                            print("Message received: \(stringValue)")
//                            
//                            guard let model = try? JSONDecoder().decode(TrackingEventModel.self, from: payload) else { return }
//                            
//                            let eventText: String
//                            switch model.trackerEventType {
//                            case .enter:
//                                eventText = StringConstant.entered
//                            case .exit:
//                                eventText = StringConstant.exited
//                            }
//                            
//                            let alertModel = AlertModel(title: model.geofenceId, message: "\(StringConstant.tracker) \(eventText) \(model.geofenceId)", cancelButton: nil)
//                            DispatchQueue.main.async {
//                                NotificationCenter.default.post(name: Notification.trackingEvent, object: nil, userInfo: ["trackingEvent": model])
//                                self?.delegate?.showAlert(alertModel)
//                            }
//                        }
//                    )
//                    print("subscribe status \(String(describing: status))")
//                default:
//                    break
//                }
//            }
//        }
    }
    
    func createClientId() -> String {
        return "iotconsole-93889251-b366-4f31-9bac-0435c862763a" //"geonotification-" + UUID().uuidString
    }
    var mqttIoTContext: MqttIoTContext?
    
    private func createIoTClientIfNeeded() {
        guard let configuration = getAWSConfigurationModel(),
              let identityId = UserDefaultsHelper.get(for: String.self, key: .signedInIdentityId),
              !configuration.webSocketUrl.isEmpty, mqttClient == nil else {
            return
        }
        do {
            let url = "wss://\(configuration.webSocketUrl)/mqtt"
            
            mqttIoTContext = MqttIoTContext(topicName: "\(identityId)\tracker")
            let ConnectPacket = MqttConnectOptions(keepAliveInterval: 60000, clientId: identityId)// createClientId())

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
                connackTimeout: TimeInterval(10))//, connectOptions: ConnectPacket)
            mqttClient = try createClient(clientOptions: clientOptions, iotContext: mqttIoTContext!)
            mqttIoTContext?.client = mqttClient
        }
        catch {
            mqttIoTContext?.printView("Failed to setup client.")
        }
    }
    
    func connectClient(client: Mqtt5Client, iotContext: MqttIoTContext) throws {
        try client.start()
        if iotContext.semaphoreConnectionSuccess.wait(timeout: .now() + 5) == .timedOut {
            print("Connection Success Timed out after 5 seconds")
        }
    }

    /// stop client and check for stopped lifecycle event
    func stopClient(client: Mqtt5Client, iotContext: MqttIoTContext) {
        //DispatchQueue.global(qos: .userInitiated).async {
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
    
    private func createIoTManagerIfNeeded(completion: @escaping ()->()) {
//        guard iotDataManager == nil,
//              let configuration = getAWSConfigurationModel(),
//              !configuration.webSocketUrl.isEmpty else {
//            completion()
//            return
//        }
//                
//        iotManager = AWSIoTManager.default()
//        iot = AWSIoT(forKey: "default")
//        
//        let iotEndPoint = AWSEndpoint(
//            urlString: "wss://\(configuration.webSocketUrl)/mqtt")
//
//        var region = AWSMobileClient.default().identityId?.toRegionType() ?? AWSRegionType.USEast1
//        if let regionFromURL = iotEndPoint?.regionType, regionFromURL != .Unknown {
//            region = regionFromURL
//        }
//                
//        let iotDataConfiguration = AWSServiceConfiguration(
//            region: region,
//            endpoint: iotEndPoint,
//            credentialsProvider: AWSMobileClient.default()
//        )
//        
//        AWSIoTDataManager.register(with: iotDataConfiguration!, forKey: "MyAWSIoTDataManager")
//        iotDataManager = AWSIoTDataManager(forKey: "MyAWSIoTDataManager")
//        
//        completion()
    }
    
    private func unsubscribeFromAWSNotifications() {
//        guard let identityId = AWSMobileClient.default().identityId else {
//            return
//        }
//        
//        iotDataManager?.unsubscribeTopic("\(identityId)/tracker")
//        iotDataManager?.disconnect()
        guard mqttClient != nil else {
            return
        }
        stopClient(client: mqttClient!, iotContext: mqttIoTContext!)
    }
    
    private func getAWSConfigurationModel() -> CustomConnectionModel? {
        var defaultConfiguration: CustomConnectionModel? = nil
        // default configuration
        if let identityPoolId = Bundle.main.object(forInfoDictionaryKey: "IdentityPoolId") as? String,
           let region = Bundle.main.object(forInfoDictionaryKey: "AWSRegion") as? String,
           let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String {
            defaultConfiguration = CustomConnectionModel(identityPoolId: identityPoolId, userPoolClientId: "", userPoolId: "", userDomain: "", webSocketUrl: "", apiKey: apiKey, region: region)
        }

        // custom configuration
        let customConfiguration = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect)
        
        return customConfiguration ?? defaultConfiguration
    }
}
