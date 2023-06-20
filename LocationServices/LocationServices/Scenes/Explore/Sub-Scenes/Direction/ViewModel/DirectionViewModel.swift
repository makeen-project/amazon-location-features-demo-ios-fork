//
//  DirectionViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import AWSLocationXCF

final class DirectionViewModel: DirectionViewModelProtocol {
    
    private var presentation: [SearchPresentation] = []
    private var searchCellModel: [SearchCellViewModel] = []
    
    // to use in case of second call for routing
    private var cachedMapModel: MapModel?
    
    var defaultTravelMode: [AWSLocationTravelMode: Result<DirectionPresentation, Error>]  = [:]
    
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
    
    func searchWithSuggesstion(text: String, userLat: Double?, userLong: Double?) {
        
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
            service.searchWithPosition(text: requestValue, userLat: userLat, userLong: userLong) { [weak self] response in
                switch response {
                case .success(let results):
                    self?.presentation = results
                    let model = results.map(MapModel.init)
                    self?.delegate?.searchResult(mapModel: model)
                case .failure(let error):
                    let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                    self?.delegate?.showAlert(model)
                }
            }
        } else {
            service.searchTextWithSuggestion(text: text, userLat: userLat, userLong: userLong) { result in
                self.presentation = result
                self.addMyLocationItem()
                let model = result.map(MapModel.init)
                self.delegate?.searchResult(mapModel: model)
            }
        }
        
    }
    
    func searchWith(text: String, userLat: Double?, userLong: Double?) {
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
            service.searchWithPosition(text: requestValue, userLat: userLat, userLong: userLong) { [weak self] response in
                switch response {
                case .success(let results):
                    self?.presentation = results
                    let model = results.map(MapModel.init)
                    self?.delegate?.searchResult(mapModel: model)
                case .failure(let error):
                    let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                    self?.delegate?.showAlert(model)
                }
            }
        } else {
            service.searchText(text: text, userLat: userLat, userLong: userLong) { result in
                self.presentation = result
                self.addMyLocationItem()
                let model = result.map(MapModel.init)
                self.delegate?.searchResult(mapModel: model)
            }
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
        return presentation.map(SearchCellViewModel.init)
    }
    
    
    
    func searchSelectedPlaceWith(_ selectedItem: SearchCellViewModel, lat: Double?, long: Double?) -> Bool {
        if selectedItem.searchType == .mylocation {
            return true
        }
        
        if let id = selectedItem.placeId  {
            service.getPlace(with: id) { [weak self] result in
                guard let result else { return }
                let mapModel = MapModel(model: result)
                // cache the latest result for future usage
                self?.cachedMapModel = mapModel
                self?.delegate?.selectedPlaceResult(mapModel: [mapModel])
            }
            return false
        } else if selectedItem.lat != nil {
            return true
        } else {
            service.searchText(text: selectedItem.locationName ?? "", userLat: lat, userLong: long) { result in
                self.presentation = []
                self.presentation = result
                self.addMyLocationItem()
                let model = result.map(MapModel.init)
                if model.count == 1, let data = model[safe: 0] {
                    self.delegate?.searchResult(mapModel: [data])
                } else {
                    self.delegate?.searchResult(mapModel: model)
                }
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
                            avoidTolls: Bool = false,
                            completion: @escaping ((_ data: Data , _ model: DirectionVM) -> Void)) {
        defaultTravelMode = [:]
        selectedTravelMode = travelMode
        self.avoidFerries = avoidFerries
        self.avoidTolls = avoidTolls
        routingService.calculateRouteWith(depaturePosition: departurePosition,
                                          destinationPosition: destinationPosition,
                                          travelModes: [.car, .walking, .truck],
                                          avoidFerries: avoidFerries,
                                          avoidTolls: avoidTolls) { result in
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
                    completion(jsonData, directionVM)
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
        }
    }
    
    private func getModel(for type: RouteTypes) -> Result<DirectionPresentation, Error>? {
        let locationTravelMode = convertToLocationTravelMode(type: type)
        let model = defaultTravelMode[locationTravelMode]
        return model
    }
    
    private func convertToLocationTravelMode(type: RouteTypes) -> AWSLocationTravelMode {
        return AWSLocationTravelMode(routeType: type) ?? .walking
    }
}
