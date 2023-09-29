//
//  GeofenceDashboardViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class GeofenceDashboardViewModel: GeofenceDasboardViewModelProtocol {
    var delegate: GeofenceDasboardViewModelOutputProtocol?
    
    private let geofenceService: GeofenceServiceable
    
    var geofences: [GeofenceDataModel] = []

    init(geofenceService: GeofenceServiceable) {
        self.geofenceService = geofenceService
    }
    
    func fetchListOfGeofences() {
        
        // if we are not authorized do not send it
        if UserDefaultsHelper.getAppState() != .loggedIn {
            return
        }
        
        geofenceService.getGeofenceList { [weak self] result in
            switch result {
            case .success(let geofences):
                self?.geofences = geofences
                self?.delegate?.refreshData(with: geofences)
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
    
    func deleteGeofenceData(model: GeofenceDataModel) {
        guard let id = model.id else {
            let model = AlertModel(title: StringConstant.error, message: StringConstant.geofenceNoIdentifier, cancelButton: nil)
            delegate?.showAlert(model)
            return
        }
        
        let alertModel = AlertModel(title: StringConstant.deleteGeofence, message: StringConstant.deleteGeofenceAlertMessage) { [weak self] in
            print("LETS DELETE")
            self?.geofenceService.deleteGeofence(with: id) { [weak self] result in
                switch result {
                case .success:
                    NotificationCenter.default.post(name: Notification.deleteGeofenceData, object: nil, userInfo: ["id": id])
                    self?.geofences.removeAll(where: { $0.id == id })
                    self?.delegate?.refreshData(with: self?.geofences ?? [])
                case .failure(let error):
                    if(ErrorHandler.isAWSStackDeletedError(error: error)) {
                        ErrorHandler.handleAWSStackDeletedError(delegate: self?.delegate as AlertPresentable?)
                    }
                    else {
                        let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                        self?.delegate?.showAlert(model)
                    }
                }
            }
        }
        delegate?.showAlert(alertModel)
    }
}
