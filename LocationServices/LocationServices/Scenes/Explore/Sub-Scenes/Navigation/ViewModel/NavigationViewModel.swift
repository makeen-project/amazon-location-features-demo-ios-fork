//
//  NavigationViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSGeoRoutes

final class NavigationVCViewModel {
    var delegate: NavigationViewModelOutputDelegate?
    var service: LocationService
    var presentation: [NavigationPresentation] = []
    var route: GeoRoutesClientTypes.Route
    let dispatchGroup = DispatchGroup()
    
    private(set) var firstDestination: MapModel?
    private(set) var secondDestination: MapModel?
    
    init(service: LocationService, route: GeoRoutesClientTypes.Route, firstDestination: MapModel?, secondDestination: MapModel?) {
        self.service = service
        self.route = route
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
        if let routeLegDetails = route.legs {
            for legDetails in routeLegDetails {
                if let steps = legDetails.pedestrianLegDetails?.travelSteps {
                    for (id, step) in steps.enumerated() {
                        let model = NavigationPresentation(id: id, pedestrianStep: step)
                        await manager.addPresentation(model)
                    }
                }
                if let steps = legDetails.vehicleLegDetails?.travelSteps {
                    for (id, step) in steps.enumerated() {
                        let model = NavigationPresentation(id: id, vehicleStep: step)
                        await manager.addPresentation(model)
                    }
                }
                if let steps = legDetails.ferryLegDetails?.travelSteps {
                    for (id, step) in steps.enumerated() {
                        let model = NavigationPresentation(id: id, ferryStep: step)
                        await manager.addPresentation(model)
                    }
                }
            }
        }
        let sortedPresentation = await manager.getSortedPresentation()
        self.presentation = sortedPresentation
        self.delegate?.updateResults()
    }
    
    func update(route: GeoRoutesClientTypes.Route) {
        self.route = route
        Task {
            await populateNavigationSteps()
        }
    }
    
    func getSummaryData() -> (totalDistance: String, totalDuration: String, arrivalTime: String) {
        var arrivalTime = ""
        let lastLeg = route.legs?.last
        if let leg = lastLeg?.ferryLegDetails, let time = leg.arrival?.time {
            arrivalTime = time
        }
        else if let leg = lastLeg?.pedestrianLegDetails, let time = leg.arrival?.time {
            arrivalTime = time
        }
        else if let leg = lastLeg?.vehicleLegDetails, let time = leg.arrival?.time {
            arrivalTime = time
        }
        return (route.summary!.distance.formatToKmString(),
                route.summary!.duration.convertSecondsToMinString(),
                arrivalTime)
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
