//
//  DirectionVC+Tableview.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import CoreLocation

extension DirectionVC {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchCell.self, forCellReuseIdentifier: SearchCell.reuseId)
    }
}

extension DirectionVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension DirectionVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let destination: DirectionTextFieldModel?
        if isDestination {
            destination = secondDestionation
        } else {
            destination = firstDestionation
        }
        let isMyLocationSelected = destination?.placeName == "My Location"
        
        if viewModel.numberOfRowsInSection() == 0 && !isInitalState && !isMyLocationSelected {
            tableView.setEmptyView()
        } else {
            tableView.restore()
        }
        
        return viewModel.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.reuseId, for: indexPath) as? SearchCell else {
            fatalError("Search Cell Can't be found")
        }
        
        cell.applyStyles(style: SearchCellStyle(style: directionScreenStyle))
        let data = viewModel.getSearchCellModel()
        if indexPath.row < data.count {
            let model =  data[indexPath.row]
            tableView.separatorStyle = model.searchType == .mylocation ? .none : .singleLine
            cell.model = model
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.getSearchCellModel()
        let currentModel = model[indexPath.row]
        
        let searchTextModel = DirectionTextFieldModel(placeName: currentModel.locationName ?? "", placeAddress: currentModel.label, lat: currentModel.lat, long: currentModel.long)
        
        if self.isDestination {
            secondDestionation = searchTextModel
        } else {
            firstDestionation = searchTextModel
        }
        
        self.directionSearchView.changeSearchRouteName(with: currentModel.locationName ?? "", isDestination: self.isDestination)
        
        if currentModel.searchType == .mylocation {
            viewModel.myLocationSelected()
        }
        
        let state = viewModel.searchSelectedPlaceWith(currentModel, lat: userLocation?.lat, long: userLocation?.long)
        
        let canSearch = firstDestionation != nil && secondDestionation != nil
        
        if state && canSearch {
            self.sheetPresentationController?.selectedDetentIdentifier = .medium
            calculateGenericRoute(currentModel: currentModel, avoidFerries: viewModel.avoidFerries, avoidTolls: viewModel.avoidTolls)
        }
    }
    
    func sendDirectionsToExploreVC(data: Data,
                                   departureLocation: CLLocationCoordinate2D,
                                   destinationLocation: CLLocationCoordinate2D,
                                   routeType: RouteTypes) {
        let datas: [String: Any] = ["LineString" : data,
                                    "DepartureLocation": departureLocation,
                                    "DestinationLocation": destinationLocation,
                                    "routeType": routeType]
        NotificationCenter.default.post(name: Notification.Name("DirectionLineString"), object: nil, userInfo: datas)
        NotificationCenter.default.post(name: Notification.Name("updateMapViewButtons"), object: nil, userInfo: nil)
    }
}
