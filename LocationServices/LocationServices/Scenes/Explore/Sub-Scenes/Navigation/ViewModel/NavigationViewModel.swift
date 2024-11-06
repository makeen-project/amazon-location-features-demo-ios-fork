//
//  NavigationViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class NavigationVCViewModel {
    var delegate: NavigationViewModelOutputDelegate?
    var service: LocationService
    var routeLegDetails: [RouteLegDetails]
    var presentation: [NavigationPresentation] = []
    private var summaryData: (totalDistance: Double, totalDuration: Double)
    let dispatchGroup = DispatchGroup()
    
    private(set) var firstDestination: MapModel?
    private(set) var secondDestination: MapModel?
    
    init(service: LocationService, routeLegDetails: [RouteLegDetails], summaryData: (totalDistance: Double, totalDuration: Double), firstDestination: MapModel?, secondDestination: MapModel?) {
        self.service = service
        self.routeLegDetails = routeLegDetails
        self.summaryData = summaryData
        self.firstDestination = firstDestination
        self.secondDestination = secondDestination
        Task {
            await populateNavigationSteps()
        }
    }

    actor PresentationManager {
        var presentation: [NavigationPresentation] = []

        func addPresentation(_ model: NavigationPresentation) {
            presentation.append(model)
        }

        func getSortedPresentation() -> [NavigationPresentation] {
            presentation.sort(by: { $0.id < $1.id })
            return presentation
        }
    }
    
    private func populateNavigationSteps() async {
        let manager = PresentationManager()
        for legDetails in routeLegDetails {
            for (id, step) in legDetails.navigationSteps.enumerated() {
                let model = NavigationPresentation(id: id, duration: step.duration.convertSecondsToMinString(), distance: step.distance.formatToKmString(), instruction: step.instruction, stepType: step.type)
                await manager.addPresentation(model)
            }
        }
        let sortedPresentation = await manager.getSortedPresentation()
        self.presentation = sortedPresentation
        self.delegate?.updateResults()
    }
    
    func update(routeLegDetails: [RouteLegDetails], summaryData: (totalDistance: Double, totalDuration: Double)) {
        self.routeLegDetails = routeLegDetails
        self.summaryData = summaryData
        Task {
            await populateNavigationSteps()
        }
    }
    
    func getSummaryData() -> (totalDistance: String, totalDuration: String) {
        return (summaryData.totalDistance.formatToKmString(),
                summaryData.totalDuration.convertSecondsToMinString())
    }
    
    func getData() -> [NavigationCellModel] {
        var model: [NavigationCellModel] = []
        if presentation.count > 0 {
            for i in 0...presentation.count - 1 {
                let item = presentation[i]
                if i == presentation.count - 1 {
                    model.append(NavigationCellModel(model: item, stepState: .last))
                } else {
                    model.append(NavigationCellModel(model: item, stepState: .first))
                }
            }
        }
        
        return model
    }
    
    func getItemCount() -> Int {
        return presentation.count
    }
}
