//
//  DirectionViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import AWSLocation

final class DirectionViewModel: DirectionViewModelProtocol {
    
    private var presentation: [SearchPresentation] = []
    private var searchCellModel: [SearchCellViewModel] = []
    
    // to use in case of second call for routing
    private var cachedMapModel: MapModel?
    
    var defaultTravelMode: [LocationClientTypes.TravelMode: Result<DirectionPresentation, Error>]  = [:]
    
    var userLocation: (lat: Double?, long: Double?)?
    
    var delegate: DirectionViewModelOutputDelegate?
    var service: LocationServiceable
    var routingService: RoutingServiceable
    var selectedTravelMode: RouteTypes?
    var avoidFerries: Bool = false
    var avoidTolls: Bool = false
    
    init(service: LocationServiceable, routingService: RoutingServiceable) {
        self.service = service
        self.routingService = routingService
    }
    
    func loadLocalOptions() {
        self.avoidFerries = UserDefaultsHelper.get(for: Bool.self, key: .ferriesOptions) ?? true
        self.avoidTolls = UserDefaultsHelper.get(for: Bool.self, key: .tollOptions) ?? true
        delegate?.getLocalRouteOptions(tollOption: avoidTolls, ferriesOption: avoidFerries)
    }
    
    func addMyLocationItem() {
        guard !(delegate?.isMyLocationAlreadySelected() ?? false)  else { return }
        let myLocation = getMyLocationItem()
        presentation.insert(myLocation, at: 0)
        delegate?.reloadView()
    }
    
    func myLocationSelected() {
        presentation = []
        delegate?.reloadView()
    }
    
    func searchWithSuggestion(text: String, userLat: Double?, userLong: Double?) async {
        
        guard !text.isEmpty && text != "My Location" else {
            presentation = []
            
            if text != "My Location" {
                addMyLocationItem()
            }
            
            self.delegate?.searchResult(mapModel: [])
                
            return
        }
        
        if text.isCoordinate() {
            let requestValue = text.convertTextToCoordinate()
            let response = await service.searchWithPosition(position: requestValue, userLat: userLat, userLong: userLong)
                switch response {
                case .success(let results):
                    self.presentation = results
                    let model = results.map(MapModel.init)
                    self.delegate?.searchResult(mapModel: model)
                case .failure(let error):
                    let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                    self.delegate?.showAlert(model)
                }
        } else {
            let response = await service.searchTextWithSuggestion(text: text, userLat: userLat, userLong: userLong)
            switch response {
            case .success(let results):
                self.presentation = results
                self.addMyLocationItem()
                let model = results.map(MapModel.init)
                self.delegate?.searchResult(mapModel: model)
            case .failure(let error):
                let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                self.delegate?.showAlert(model)
            }
        }
        
    }
    
    func searchWith(text: String, userLat: Double?, userLong: Double?) async throws {
        guard !text.isEmpty && text != "My Location" else {
            presentation = []
            if text != "My Location" {
                addMyLocationItem()
            }
            delegate?.searchResult(mapModel: [])
            return
        }
        
        if text.isCoordinate() {
            let requestValue = text.convertTextToCoordinate()
            let response = await service.searchWithPosition(position: requestValue, userLat: userLat, userLong: userLong)
                switch response {
                case .success(let results):
                    self.presentation = results
                    let model = results.map(MapModel.init)
                    self.delegate?.searchResult(mapModel: model)
                case .failure(let error):
                    let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                    self.delegate?.showAlert(model)
                }
        } else {
            let result = await service.searchText(text: text, userLat: userLat, userLong: userLong)
            let resultValue = try result.get()
            self.presentation = resultValue
            self.addMyLocationItem()
            let model = resultValue.map(MapModel.init)
            self.delegate?.searchResult(mapModel: model)
        }
    }
    
    func numberOfRowsInSection() -> Int {
        return presentation.count
    }
    
    func getMyLocationItem() -> SearchPresentation {
        let model = SearchPresentation(placeId: "myLocation",
                                       fullLocationAddress: "My Location",
                                       distance: nil,
                                       countryName: nil,
                                       cityName: nil,
                                       placeLat: userLocation?.lat,
                                       placeLong: userLocation?.long,
                                       name: "My Location")
        return model
    }
    
    func getSearchCellModel() -> [SearchCellViewModel] {
        searchCellModel = presentation.map({
            return SearchCellViewModel(searchType: ($0.placeId != nil || $0.placeLat != nil) ? ($0.placeId == "myLocation" ? .mylocation : .location) : .search,
                                placeId: $0.placeId,
                                locationName: $0.name,
                                locationDistance: $0.distance,
                                locationCountry: $0.countryName,
                                locationCity: $0.cityName,
                                label: $0.fullLocationAddress,
                                long: $0.placeLong, lat: $0.placeLat)
        })
        
        return searchCellModel
    }
    
    
    
    func searchSelectedPlaceWith(_ selectedItem: SearchCellViewModel, lat: Double?, long: Double?) async throws -> Bool {
        if selectedItem.searchType == .mylocation {
            return true
        }
        
        if let id = selectedItem.placeId  {
            let result = try await service.getPlace(with: id)
                guard let result else { return false }
                let mapModel = MapModel(model: result)
                // cache the latest result for future usage
                self.cachedMapModel = mapModel
                try await self.delegate?.selectedPlaceResult(mapModel: [mapModel])
            return false
        } else if selectedItem.lat != nil {
            return true
        } else {
            let result = await service.searchText(text: selectedItem.locationName ?? "", userLat: lat, userLong: long)
            let resultValue = try result.get()
                self.presentation = []
                self.presentation = resultValue
                self.addMyLocationItem()
                let model = resultValue.map(MapModel.init)
                if model.count == 1, let data = model[safe: 0] {
                    self.delegate?.searchResult(mapModel: [data])
                } else {
                    self.delegate?.searchResult(mapModel: model)
                }
            return false
        }
    }
    
    func getCurrentNavigationLegsWith(_ type: RouteTypes) -> Result<[NavigationSteps], Error> {
        let currentModel = getModel(for: type)
        switch currentModel {
        case .success(let presentation):
            return .success(presentation.navigationSteps)
        case .failure(let error):
            return .failure(error)
        case .none:
            return .failure(NSError(domain: "Navigation", code: -1))
        }
    }
    
    func getSumData(_ type: RouteTypes) -> (totalDistance: Double, totalDuration: Double) {
        let currentModel = getModel(for: type)
        switch currentModel {
        case .success(let presentation):
            return (presentation.distance, presentation.duration)
        case .failure, .none:
            return (0.0, 0.0)
        }
    }
    
    func calculateRouteWith(destinationPosition:  CLLocationCoordinate2D,
                            departurePosition: CLLocationCoordinate2D,
                            travelMode: RouteTypes = .car,
                            avoidFerries: Bool = false,
                            avoidTolls: Bool = false) async throws -> (Data, DirectionVM)? {
        defaultTravelMode = [:]
        selectedTravelMode = travelMode
        self.avoidFerries = avoidFerries
        self.avoidTolls = avoidTolls
        let result = try await routingService.calculateRouteWith(depaturePosition: departurePosition,
                                          destinationPosition: destinationPosition,
                                          travelModes: [LocationClientTypes.TravelMode.car, LocationClientTypes.TravelMode.walking, LocationClientTypes.TravelMode.truck],
                                          avoidFerries: avoidFerries,
                                          avoidTolls: avoidTolls)
            self.defaultTravelMode = result
            var directionVM: DirectionVM = DirectionVM(carTypeDistane: "", carTypeDuration: "", walkingTypeDuration: "", walkingTypeDistance: "", truckTypeDistance: "", truckTypeDuration: "")
            
            result.values.forEach { model in
                switch model {
                case .success(let model):
                    switch model.travelMode {
                    case .car:
                        directionVM.carTypeDistane = model.distance.convertFormattedKMString()
                        directionVM.carTypeDuration = model.duration.convertSecondsToMinString()
                    case .walking:
                        directionVM.walkingTypeDistance = model.distance.convertFormattedKMString()
                        directionVM.walkingTypeDuration = model.duration.convertSecondsToMinString()
                    case .truck:
                        directionVM.truckTypeDistance = model.distance.convertFormattedKMString()
                        directionVM.truckTypeDuration = model.duration.convertSecondsToMinString()
                    default: break
                    }
                case .failure:
                    break
                }
            }
            
            let currentTravelMode = self.getModel(for: travelMode)
            switch currentTravelMode {
            case .success(let travelMode):
                let encoder = JSONEncoder()
                do {
                    let jsonData = try encoder.encode(travelMode.lineString)
                    return (jsonData, directionVM)
                } catch {
                    print(String.errorJSONDecoder)
                }
            case .failure(let error):
                let alertModel = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                self.delegate?.showAlert(alertModel)
            case .none:
                let alertModel = AlertModel(title: StringConstant.error, message: StringConstant.failedToCalculateRoute, cancelButton: nil)
                self.delegate?.showAlert(alertModel)
            }
        return nil
    }
    
    private func getModel(for type: RouteTypes) -> Result<DirectionPresentation, Error>? {
        let locationTravelMode = convertToLocationTravelMode(type: type)
        let model = defaultTravelMode[locationTravelMode]
        return model
    }
    
    private func convertToLocationTravelMode(type: RouteTypes) -> LocationClientTypes.TravelMode {
        return LocationClientTypes.TravelMode(rawValue: type.title) ?? .walking
    }
}
