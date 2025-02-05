//
//  DirectionViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import AWSGeoRoutes
import Polyline

final class DirectionViewModel: DirectionViewModelProtocol {
    
    private var presentation: [SearchPresentation] = []
    private var searchCellModel: [SearchCellViewModel] = []
    
    // to use in case of second call for routing
    private var cachedMapModel: MapModel?
    
    var defaultTravelMode: [GeoRoutesClientTypes.RouteTravelMode: Result<DirectionPresentation, Error>]  = [:]
    
    var userLocation: (lat: Double?, long: Double?)?
    
    var delegate: DirectionViewModelOutputDelegate?
    var service: LocationServiceable
    var routingService: RoutingServiceable
    var selectedTravelMode: RouteTypes?
    var avoidFerries: Bool = false
    var avoidTolls: Bool = false
    var avoidUturns: Bool = false
    var avoidTunnels: Bool = false
    var avoidDirtRoads: Bool = false
    
    var leaveNow: Bool? = true
    var leaveTime: Date? = nil
    var arrivalTime: Date? = nil
    
    init(service: LocationServiceable, routingService: RoutingServiceable) {
        self.service = service
        self.routingService = routingService
    }
    
    func loadLocalOptions() {
        self.avoidFerries = UserDefaultsHelper.get(for: Bool.self, key: .ferriesOptions) ?? true
        self.avoidTolls = UserDefaultsHelper.get(for: Bool.self, key: .tollOptions) ?? true
        self.avoidUturns = UserDefaultsHelper.get(for: Bool.self, key: .uturnsOptions) ?? true
        self.avoidTunnels = UserDefaultsHelper.get(for: Bool.self, key: .tunnelsOptions) ?? true
        self.avoidDirtRoads = UserDefaultsHelper.get(for: Bool.self, key: .dirtRoadsOptions) ?? true
        delegate?.getLocalRouteOptions(tollOption: avoidTolls, ferriesOption: avoidFerries, uturnsOption: avoidUturns, tunnelsOption: avoidTunnels, dirtRoadsOption: avoidDirtRoads)
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
        let mapCenter = UserDefaultsHelper.getObject(value: LocationCoordinate2D.self, key: .mapCenter)
        if text.isCoordinate() {
            let requestValue = text.convertTextToCoordinate()
            let response = await service.reverseGeocode(position: requestValue, userLat: mapCenter != nil ? mapCenter?.latitude : userLat, userLong: mapCenter != nil ? mapCenter?.longitude : userLong)
                switch response {
                case .success(let results):
                    self.presentation = results
                    let model = results.map(MapModel.init)
                    self.delegate?.searchResult(mapModel: model)
                case .failure(let error):
                    let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                    DispatchQueue.main.async {
                        self.delegate?.showAlert(model)
                    }
                }
        } else {
            let response = await service.searchWithSuggest(text: text, userLat: mapCenter != nil ? mapCenter?.latitude : userLat, userLong: mapCenter != nil ? mapCenter?.longitude : userLong)
            switch response {
            case .success(let results):
                self.presentation = results
                self.addMyLocationItem()
                let model = results.map(MapModel.init)
                self.delegate?.searchResult(mapModel: model)
            case .failure(let error):
                let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                DispatchQueue.main.async {
                    self.delegate?.showAlert(model)
                }
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
        let mapCenter = UserDefaultsHelper.getObject(value: LocationCoordinate2D.self, key: .mapCenter)
        if text.isCoordinate() {
            let requestValue = text.convertTextToCoordinate()
            let response = await service.reverseGeocode(position: requestValue, userLat: mapCenter != nil ? mapCenter?.latitude : userLat, userLong: mapCenter != nil ? mapCenter?.longitude : userLong)
                switch response {
                case .success(let results):
                    self.presentation = results
                    let model = results.map(MapModel.init)
                    self.delegate?.searchResult(mapModel: model)
                case .failure(let error):
                    let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                    DispatchQueue.main.async {
                        self.delegate?.showAlert(model)
                    }
                }
        } else {
            let result = await service.searchText(text: text, userLat: mapCenter != nil ? mapCenter?.latitude : userLat, userLong: mapCenter != nil ? mapCenter?.longitude : userLong, queryId: nil)
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
            var searchType = SearchType.search
            if $0.placeId == "myLocation" {
                searchType = .mylocation
            } else if $0.suggestType == .place {
                searchType = .location
            } else {
                searchType = .search
            }
            return SearchCellViewModel(searchType: searchType,
                                placeId: $0.placeId,
                                locationName: $0.name,
                                locationDistance: $0.distance,
                                locationCountry: $0.countryName,
                                locationCity: $0.cityName,
                                label: $0.fullLocationAddress,
                                long: $0.placeLong, lat: $0.placeLat,
                                queryId: $0.queryId, queryType: $0.queryType)
        })
        
        return searchCellModel
    }
    
    
    
    func searchSelectedPlaceWith(_ selectedItem: SearchCellViewModel, lat: Double?, long: Double?) async throws -> Bool {
        if selectedItem.searchType == .mylocation {
            return true
        }
        
        if selectedItem.placeId != nil  {
            let mapModel = MapModel(placeId: selectedItem.placeId, placeName: selectedItem.locationName, placeAddress: selectedItem.label, placeCity: selectedItem.locationCity, placeCountry: selectedItem.locationCountry, placeLat: selectedItem.lat, placeLong: selectedItem.long, distance: selectedItem.locationDistance)
                // cache the latest result for future usage
                self.cachedMapModel = mapModel
                try await self.delegate?.selectedPlaceResult(mapModel: [mapModel])
            return false
        } else if selectedItem.lat != nil {
            return true
        } else {
            let result = await service.searchText(text: selectedItem.locationName ?? "", userLat: lat, userLong: long, queryId: selectedItem.queryId)
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
    
    func getCurrentNavigationRouteWith(_ type: RouteTypes) -> Result<GeoRoutesClientTypes.Route?, Error> {
        let currentModel = getModel(for: type)
        switch currentModel {
        case .success(let presentation):
            return .success(presentation.route)
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
            return (Double(presentation.route.summary!.distance), Double(presentation.route.summary!.duration))
        case .failure, .none:
            return (0.0, 0.0)
        }
    }
    
    func calculateRouteWith(destinationPosition:  CLLocationCoordinate2D,
                            departurePosition: CLLocationCoordinate2D,
                            travelMode: RouteTypes,
                            avoidFerries: Bool = false,
                            avoidTolls: Bool = false,
                            avoidUturns: Bool = false,
                            avoidTunnels: Bool = false,
                            avoidDirtRoads: Bool = false,
                            leaveNow: Bool?,
                            leaveTime: Date?,
                            arrivalTime: Date?) async throws -> ([Data], DirectionVM)? {
        selectedTravelMode = travelMode
        self.avoidFerries = avoidFerries
        self.avoidTolls = avoidTolls
        self.avoidUturns = avoidUturns
        self.avoidTunnels = avoidTunnels
        self.avoidDirtRoads = avoidDirtRoads
        self.leaveNow = leaveNow
        self.leaveTime = leaveTime
        self.arrivalTime = arrivalTime
        let result = try await routingService.calculateRouteWith(depaturePosition: departurePosition,
                                          destinationPosition: destinationPosition,
                                                                 travelModes: [GeoRoutesClientTypes.RouteTravelMode(rawValue: travelMode.title)!],
                                                                 avoidFerries: avoidFerries,
                                                                 avoidTolls: avoidTolls,
                                                                 avoidUturns: avoidUturns,
                                                                 avoidTunnels: avoidTunnels,
                                                                 avoidDirtRoads: avoidDirtRoads,
                                                                 departNow: leaveNow,
                                                                 departureTime: leaveTime,
                                                                 arrivalTime: arrivalTime)
        var directionVM: DirectionVM = DirectionVM()
            
            result.values.forEach { data in
                switch data {
                case .success(let model):
                    self.defaultTravelMode[model.travelMode] = data
                    directionVM.leaveType = model.leaveType
                    var routeTime = ""
                    if model.travelMode == .pedestrian, let time = model.leaveType == .arriveAt ? model.route.legs?.first?.pedestrianLegDetails?.departure?.time :
                        model.route.legs?.last?.pedestrianLegDetails?.arrival?.time {
                        routeTime = time
                    }
                    else if let time = model.leaveType == .arriveAt ?
                                model.route.legs?.first?.vehicleLegDetails?.departure?.time :
                                model.route.legs?.last?.vehicleLegDetails?.arrival?.time {
                        routeTime = time
                    }
                    routeTime = Date.convertStringToDate(routeTime, format: "yyyy-MM-dd'T'HH:mm:ssXXX")?.convertTimeString() ?? ""
                    switch model.travelMode {
                    case .car:
                        directionVM.carTypeDistane = model.route.summary?.distance.formatToKmString() ?? ""
                        directionVM.carTypeDuration = model.route.summary?.duration.convertSecondsToMinString() ?? ""
                        directionVM.carTypeTime = routeTime
                    case .scooter:
                        directionVM.scooterTypeDistance = model.route.summary?.distance.formatToKmString() ?? ""
                        directionVM.scooterTypeDuration = model.route.summary?.duration.convertSecondsToMinString() ?? ""
                        directionVM.scooterTypeTime = routeTime
                    case .pedestrian:
                        directionVM.walkingTypeDistance = model.route.summary?.distance.formatToKmString() ?? ""
                        directionVM.walkingTypeDuration = model.route.summary?.duration.convertSecondsToMinString() ?? ""
                        directionVM.walkingTypeTime = routeTime
                    case .truck:
                        directionVM.truckTypeDistance = model.route.summary?.distance.formatToKmString() ?? ""
                        directionVM.truckTypeDuration = model.route.summary?.duration.convertSecondsToMinString() ?? ""
                        directionVM.truckTypeTime = routeTime
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
                    var jsonDatas: [Data] = []
                    if let legDetails = travelMode.route.legs {
                        for leg in legDetails {
                            let jsonData = try encoder.encode(leg.geometry?.getPolylineGeoData())
                            jsonDatas.append(jsonData)
                        }
                    }
                    return (jsonDatas, directionVM)
                } catch {
                    print(String.errorJSONDecoder)
                }
            case .failure, .none:
                print(StringConstant.failedToCalculateRoute)
            }
        return nil
    }
    
    
    private func getModel(for type: RouteTypes) -> Result<DirectionPresentation, Error>? {
        let locationTravelMode = convertToLocationTravelMode(type: type)
        let model = defaultTravelMode[locationTravelMode]
        return model
    }
    
    private func convertToLocationTravelMode(type: RouteTypes) -> GeoRoutesClientTypes.RouteTravelMode {
        return GeoRoutesClientTypes.RouteTravelMode(rawValue: type.title) ?? .pedestrian
    }
}
