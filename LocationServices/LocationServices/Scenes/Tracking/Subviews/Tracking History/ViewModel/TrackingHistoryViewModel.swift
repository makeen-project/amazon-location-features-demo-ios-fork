//
//  TrackingHistoryViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocationXCF

struct TrackingHistoryPresentation {
    let time: String
    let date: String
    let cooordinates: String
    let stepType: StepType
    let receivedTime: Date
    
    init(model: AWSLocationDevicePosition, stepType: StepType) {
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
            self.cooordinates = positions.map { $0.stringValue }.joined(separator: ",")
        } else {
            cooordinates = ""
        }
        self.stepType = stepType
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
    
    func loadData() {
        trackingService.getAllTrackingHistory { result in
            switch result {
            case .success(let response):
                self.setHistory(response)
                self.delegate?.reloadTableView()
            case .failure(let error):
                let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                DispatchQueue.main.async {
                    self.delegate?.showAlert(model)
                }
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
    
    func deleteHistory() {
        trackingService.removeAllHistory { [weak self] result in
            switch result {
            case .success:
                self?.setHistory([])
                self?.delegate?.reloadTableView()
            case .failure(let error):
                let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                DispatchQueue.main.async {
                    self?.delegate?.showAlert(model)
                }
            }
        }
    }
    
    func getTitle(for section: Int) -> String {
        guard section < sortedKeys.count else { return "" }
        
        let day = sortedKeys[section]
        return day.convertToRelativeString()
    }
    
    func getItemCount(for section: Int) -> Int {
        guard section < sortedKeys.count else { return 0 }
        return history[sortedKeys[section]]?.count ?? 0
    }
    
    func getCellModel(indexPath: IndexPath) -> TrackHistoryCellModel? {
        let sectionArray = history[sortedKeys[indexPath.section]] ?? []
        guard indexPath.row < sectionArray.count else { return nil }
        
        let item = sectionArray[indexPath.row]
        return TrackHistoryCellModel(model: item)
    }
    
    func startTracking(lat: Double, long: Double)  {
        self.updateTrackingData(lat: lat, long: long)
    }
    
    func getTrackingStatus() -> Bool {
        return isTrackingActive
    }
    
    func changeTrackingStatus(_ isTrackingActive: Bool) {
        self.isTrackingActive = isTrackingActive
    }
    
    private func updateTrackingData(lat: Double, long: Double) {
        trackingService.updateTrackerLocation(lat: lat, long: long, completion: { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                DispatchQueue.main.async {
                    self.delegate?.showAlert(model)
                }
            }
        })
    }
}
