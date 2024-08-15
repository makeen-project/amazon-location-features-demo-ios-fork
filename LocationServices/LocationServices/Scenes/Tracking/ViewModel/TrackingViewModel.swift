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
                self.delegate?.showGeofences(geofences)
            case .failure(let error):
                if(ErrorHandler.isAWSStackDeletedError(error: error)) {
                    ErrorHandler.handleAWSStackDeletedError(delegate: self.delegate as AlertPresentable?)
                }
                else {
                    let model = AlertModel(title: StringConstant.error, message: error.localizedDescription)
                    self.delegate?.showAlert(model)
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
    

    
    private func subscribeToAWSNotifications() {
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
