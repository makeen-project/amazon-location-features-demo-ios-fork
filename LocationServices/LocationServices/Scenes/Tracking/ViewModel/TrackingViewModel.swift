//
//  TrackingViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import AWSIoT
import AWSMobileClientXCF

final class TrackingViewModel: TrackingViewModelProtocol {
    
    enum Constants {
        static let majorDistanceChange: CGFloat = 30
    }
    
    weak var delegate: TrackingViewModelDelegate?
    
    private let trackingService: TrackingAPIService
    private let geofenceService: GeofenceAPIService
    
    private var lastLocation: CLLocation?
    private(set) var isTrackingActive: Bool = false
    
    private var iotDataManager: AWSIoTDataManager?
    private var iotManager: AWSIoTManager?
    private var iot: AWSIoT?
    
    init(trackingService: TrackingAPIService, geofenceService: GeofenceAPIService) {
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
    
    func trackLocationUpdate(location: CLLocation?) {
        guard let location else { return }
        
        guard isTrackingActive else {
            stopTracking()
            return
        }
        
        if let lastLocation {
            guard location.distance(from: lastLocation) > Constants.majorDistanceChange else { return }
            self.lastLocation = location
            sendLocationUpdate(location)
        } else {
            lastLocation = location
            sendLocationUpdate(location)
        }
    }
    
    func fetchListOfGeofences() {
        
        // if we are not authorized do not send it
        if UserDefaultsHelper.getAppState() != .loggedIn {
            return
        }
        
        geofenceService.getGeofenceList { [weak self] result in
            switch result {
            case .success(let geofences):
                self?.delegate?.showGeofences(geofences)
            case .failure(let error):
                if(ErrorHandler.isAWSStackDeletedError(error: error)) {
                    ErrorHandler.handleAWSStackDeletedError(delegate: self?.delegate as AlertPresentable?)
                }
                else {
                    let model = AlertModel(title: StringConstant.error, message: error.localizedDescription)
                    self?.delegate?.showAlert(model)
                }
            }
        }
    }
    
    private func sendLocationUpdate(_ location: CLLocation) {
        let lat = location.coordinate.latitude
        let long = location.coordinate.longitude
        
        trackingService.updateTrackerLocation(lat: lat, long: long) { [weak self] result in
            switch result {
            case .success:
                self?.updateHistory()
            case .failure(let error):
                if(ErrorHandler.isAWSStackDeletedError(error: error)) {
                    ErrorHandler.handleAWSStackDeletedError(delegate: self?.delegate as AlertPresentable?)
                }
                else {
                    let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                    DispatchQueue.main.async {
                        self?.delegate?.showAlert(model)
                    }
                }
            }
        }
        geofenceService.evaluateGeofence(lat: lat, long: long)
    }
    
    private func updateHistory() {
        trackingService.getAllTrackingHistory { [weak self] result in
            switch result {
            case .success(let history):
                NotificationCenter.default.post(name: Notification.updateTrackingHistory, object: self, userInfo: ["history": history])
                self?.delegate?.drawTrack(history: history)
            case .failure(let error):
                if(ErrorHandler.isAWSStackDeletedError(error: error)) {
                    ErrorHandler.handleAWSStackDeletedError(delegate: self?.delegate as AlertPresentable?)
                }
                else {
                    let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                    DispatchQueue.main.async {
                        self?.delegate?.showAlert(model)
                    }
                }
            }
        }
    }
    
    private func subscribeToAWSNotifications() {
        
        createIoTManagerIfNeeded {
            guard let identityId = AWSMobileClient.default().identityId else {
                return
            }
            
            self.iotDataManager?.connectUsingWebSocket(withClientId: identityId, cleanSession: true) { status in
                print("Websocket connection status \(status.rawValue)")
                
                switch status {
                case .connected:
                    let status = self.iotDataManager?.subscribe(
                        toTopic: "\(identityId)/tracker",
                        qoS: .messageDeliveryAttemptedAtMostOnce,
                        messageCallback: { [weak self] payload in
                            let stringValue = NSString(data: payload, encoding: String.Encoding.utf8.rawValue)!
                            print("Message received: \(stringValue)")
                            
                            guard let model = try? JSONDecoder().decode(TrackingEventModel.self, from: payload) else { return }
                            
                            let eventText: String
                            switch model.trackerEventType {
                            case .enter:
                                eventText = StringConstant.entered
                            case .exit:
                                eventText = StringConstant.exited
                            }
                            
                            let alertModel = AlertModel(title: model.geofenceId, message: "\(StringConstant.tracker) \(eventText) \(model.geofenceId)", cancelButton: nil)
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.trackingEvent, object: nil, userInfo: ["trackingEvent": model])
                                self?.delegate?.showAlert(alertModel)
                            }
                        }
                    )
                    print("subscribe status \(String(describing: status))")
                default:
                    break
                }
            }
        }
    }
    
    private func createIoTManagerIfNeeded(completion: @escaping ()->()) {
        guard iotDataManager == nil,
              let configuration = getAWSConfigurationModel(),
              !configuration.webSocketUrl.isEmpty else { return }
                
        iotManager = AWSIoTManager.default()
        iot = AWSIoT(forKey: "default")
        
        let iotEndPoint = AWSEndpoint(
            urlString: "wss://\(configuration.webSocketUrl)/mqtt")

        var region = AWSMobileClient.default().identityId?.toRegionType() ?? AWSRegionType.USEast1
        if let regionFromURL = iotEndPoint?.regionType, regionFromURL != .Unknown {
            region = regionFromURL
        }
                
        let iotDataConfiguration = AWSServiceConfiguration(
            region: region,
            endpoint: iotEndPoint,
            credentialsProvider: AWSMobileClient.default()
        )
        
        AWSIoTDataManager.register(with: iotDataConfiguration!, forKey: "MyAWSIoTDataManager")
        iotDataManager = AWSIoTDataManager(forKey: "MyAWSIoTDataManager")
        
        completion()
    }
    
    private func unsubscribeFromAWSNotifications() {
        guard let identityId = AWSMobileClient.default().identityId else {
            return
        }
        
        iotDataManager?.unsubscribeTopic("\(identityId)/tracker")
    }
    
    private func getAWSConfigurationModel() -> CustomConnectionModel? {
        var defaultConfiguration: CustomConnectionModel? = nil
        // default configuration
        if let identityPoolId = Bundle.main.object(forInfoDictionaryKey: "IdentityPoolId") as? String {
            defaultConfiguration = CustomConnectionModel(identityPoolId: identityPoolId, userPoolClientId: "", userPoolId: "", userDomain: "", webSocketUrl: "")
        }

        // custom configuration
        let customConfiguration = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect)
        
        return customConfiguration ?? defaultConfiguration
    }
}
