//
//  SearchViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation

final class SearchViewModel: SearchViewModelProcotol {
    
    private var presentation: [SearchPresentation] = []
    private var searchCellModel: [SearchCellViewModel] = []
    var delegate: SearchViewModelOutputDelegate?
    var service: LocationServiceable
    
    var mapModels: [MapModel] {
        return presentation.map(MapModel.init)
    }
    
    init(service: LocationServiceable) {
        self.service = service
    }
    
    func searchWithSuggestion(text: String, userLat: Double?, userLong: Double?) async throws {
        guard !text.isEmpty else {
            self.presentation = []
            self.delegate?.searchResult(mapModel: [], shouldDismiss: false, showOnMap: false)
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
                    self.delegate?.searchResult(mapModel: model, shouldDismiss: false, showOnMap: false)
                case .failure(let error):
                    DispatchQueue.main.async {
                        let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                        self.delegate?.showAlert(model)
                    }
                }
        } else {
            let response = await service.searchWithSuggest(text: text, userLat: mapCenter != nil ? mapCenter?.latitude : userLat, userLong: mapCenter != nil ? mapCenter?.longitude : userLong)
            switch response {
            case .success(let results):
                self.presentation = results
                let model = results.map(MapModel.init)
                self.delegate?.searchResult(mapModel: model, shouldDismiss: false, showOnMap: false)
            case .failure(let error):
                DispatchQueue.main.async {
                    let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                    self.delegate?.showAlert(model)
                }
            }
        }
    }
    
    func searchWith(text: String, userLat: Double?, userLong: Double?) async throws {
        guard !text.isEmpty else {
            self.presentation = []
            self.delegate?.searchResult(mapModel: [], shouldDismiss: false, showOnMap: false)
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
                    self.delegate?.searchResult(mapModel: model, shouldDismiss: false, showOnMap: true)
                case .failure(let error):
                    let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                    self.delegate?.showAlert(model)
                }
        } else {
            let result = await service.searchText(text: text, userLat: mapCenter != nil ? mapCenter?.latitude : userLat, userLong: mapCenter != nil ? mapCenter?.longitude : userLong, queryId: nil)
                let resultValue = try result.get()
                self.presentation = resultValue
                let model = resultValue.map(MapModel.init)
                self.delegate?.searchResult(mapModel: model, shouldDismiss: false, showOnMap: true)
        }
    }
    
    func numberOfRowsInSection() -> Int {
        return presentation.count
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
    
    func searchSelectedPlaceWith(_ indexPath: IndexPath, lat: Double?, long: Double?) -> Bool {
        let selectedItem = searchCellModel[indexPath.row]
        if let id = selectedItem.placeId  {
            Task {
                let result = try await service.getPlace(with: id)
                if let result = result {
                    let model = SearchPresentation(model: result)
                    let mapModel = MapModel(model: model)
                    self.delegate?.selectedPlaceResult(mapModel: mapModel)
                }
                return true
            }
        } else if selectedItem.lat != nil {
            let currentModel = presentation[indexPath.row]
            let model = MapModel(model: currentModel)
            self.delegate?.selectedPlaceResult(mapModel: model)
            return true
        } else {
            Task {
                let mapCenter = UserDefaultsHelper.getObject(value: LocationCoordinate2D.self, key: .mapCenter)
                let result = await service.searchText(text: selectedItem.locationName ?? "", userLat: mapCenter != nil ? mapCenter?.latitude : lat, userLong: mapCenter != nil ? mapCenter?.longitude : long, queryId: selectedItem.queryId)
                let resultValue = try result.get()
                self.presentation = []
                self.presentation = resultValue
                let model = resultValue.map(MapModel.init)
                if model.count == 1, let data = model[safe: 0] {
                    self.delegate?.searchResult(mapModel: [data], shouldDismiss: false, showOnMap: false)
                } else {
                    self.delegate?.searchResult(mapModel: model, shouldDismiss: false, showOnMap: false)
                }
                return false
            }
        }
        return false
    }
}
