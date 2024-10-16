//
//  TrackingHistoryViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocation

struct TrackingHistoryPresentation {
    let time: String
    let date: String
    let cooordinates: String
    let stepState: StepState
    let receivedTime: Date
    
    init(model: LocationClientTypes.DevicePosition, stepState: StepState) {
        if let time = model.receivedTime {
            self.receivedTime = time
            self.time = time.convertTimeString()
            self.date = time.convertDateString()
        } else {
            self.receivedTime = Date()
            self.time = ""
            self.date = ""
        }
        
        if let positions = model.position {
            self.cooordinates = positions.map { $0.description }.joined(separator: ",")
        } else {
            cooordinates = ""
        }
        self.stepState = stepState
    }
}

final class TrackingHistoryViewModel: TrackingHistoryViewModelProtocol {
    
    var delegate: TrackingHistoryViewModelOutputDelegate?
    
    private var history: [Date: [TrackingHistoryPresentation]] = [:]
    private var sortedKeys: [Date] = []
    
    private var trackingService: TrackingAPIService
    private var isTrackingActive: Bool = false
    
    init(serivce: TrackingAPIService, isTrackingActive: Bool) {
        self.trackingService = serivce
        self.isTrackingActive = isTrackingActive
    }
    
    func loadData() async {
        do {
            let result = try await trackingService.getAllTrackingHistory()
            self.setHistory(result)
            self.delegate?.reloadTableView()
        }
        catch {
            let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
            DispatchQueue.main.async {
                self.delegate?.showAlert(model)
            }
        }
    }
    
    func sectionsCount() -> Int {
        return sortedKeys.count
    }
    
    func setHistory(_ history: [TrackingHistoryPresentation]) {
        self.history = Dictionary(grouping: history) { (entry) -> Date in
            return entry.receivedTime.truncateTime()
        }
        
        sortedKeys = Array(self.history.keys).sorted(by: >)
    }
    
    func deleteHistory() async throws {
       let result = try await trackingService.removeAllHistory()
        
        if result!.errors == nil || result!.errors!.isEmpty {
            let history: [TrackingHistoryPresentation] = []
            NotificationCenter.default.post(name: Notification.updateTrackingHistory, object: self, userInfo: ["history": history])
            setHistory(history)
            delegate?.reloadTableView()
        }
        else if let error = result!.errors?.first {
            let model = AlertModel(title: StringConstant.error, message: error.error?.message ?? "", cancelButton: nil)
                DispatchQueue.main.async {
                    self.delegate?.showAlert(model)
                }
            }
    }
    
    func getTitle(for section: Int) -> String {
        guard section < sortedKeys.count else { return "" }
        
        let day = sortedKeys[section]
        
        let title: String
        let relativeString = day.convertToRelativeString()
        let mediumDateString = day.convertDateMediumString()
        let dateString = day.convertDateString()
        if relativeString == mediumDateString {
            title = dateString
        } else {
            title = "\(relativeString), \(dateString)"
        }
        
        return title
    }
    
    func getItemCount(for section: Int) -> Int {
        guard section < sortedKeys.count else { return 0 }
        return history[sortedKeys[section]]?.count ?? 0
    }
    
    func getCellModel(indexPath: IndexPath) -> TrackHistoryCellModel? {
        if indexPath.section < sortedKeys.count {
            let sectionArray = history[sortedKeys[indexPath.section]] ?? []
            guard indexPath.row < sectionArray.count else { return nil }
            
            let item = sectionArray[indexPath.row]
            return TrackHistoryCellModel(model: item)
        }
        return nil
    }
    
    func startTracking(lat: Double, long: Double)  {
        Task {
            await self.updateTrackingData(lat: lat, long: long)
        }
    }
    
    func getTrackingStatus() -> Bool {
        return isTrackingActive
    }
    
    func changeTrackingStatus(_ isTrackingActive: Bool) {
        self.isTrackingActive = isTrackingActive
    }
    
    private func updateTrackingData(lat: Double, long: Double) async {
        do {
            _ = try await trackingService.updateTrackerLocation(lat: lat, long: long)
        }
        catch {
            if(ErrorHandler.isAWSStackDeletedError(error: error)) {
                ErrorHandler.handleAWSStackDeletedError(delegate: self.delegate as AlertPresentable?)
            }
            else {
                let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                DispatchQueue.main.async {
                    self.delegate?.showAlert(model)
                }
            }
        }
    }
}
