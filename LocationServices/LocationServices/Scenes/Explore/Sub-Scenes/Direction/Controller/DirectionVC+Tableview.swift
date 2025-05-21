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
        tableView.register(SearchCell.self, forCellReuseIdentifier: SearchCell.reuseCompactId)
    }
}

extension DirectionVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = viewModel.getSearchCellModel()
        if indexPath.row < data.count {
            let model =  data[indexPath.row]

            let cellType = model.searchType
            if(cellType == .location){
                return UITableView.automaticDimension
            }
            else {
                return 70
            }
        }
        else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension DirectionVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let destination: DirectionTextFieldModel?
        if isDestination {
            destination = secondDestination
        } else {
            destination = firstDestination
        }
        let isMyLocationSelected = destination?.placeName == StringConstant.myLocation
        
        if viewModel.numberOfRowsInSection() == 0 && !isInitalState && !isMyLocationSelected {
            tableView.setEmptyView()
        } else {
            tableView.restore()
        }
        
        return viewModel.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = viewModel.getSearchCellModel()
        var model:SearchCellViewModel?
        if indexPath.row < data.count {
            model =  data[indexPath.row]
            tableView.separatorStyle = model?.searchType == .mylocation ? .none : .singleLine
        }
        let reuseId = model?.searchType == .search ? SearchCell.reuseId : SearchCell.reuseCompactId
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as? SearchCell else {
            fatalError("Search Cell Can't be found")
        }
        
        cell.applyStyles(style: SearchCellStyle(style: directionScreenStyle))

        if model != nil {
            cell.model = model
        }
        cell.hideDistance()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.getSearchCellModel()
        let currentModel = model[indexPath.row]
        
        let searchTextModel = DirectionTextFieldModel(placeName: currentModel.locationName ?? "", placeAddress: currentModel.label, lat: currentModel.lat, long: currentModel.long)
        
        if self.isDestination {
            secondDestination = searchTextModel
        } else {
            firstDestination = searchTextModel
        }
        
        if currentModel.searchType == .mylocation {
            let locationAuthStatus = locationManager.getAuthorizationStatus()
            if(locationAuthStatus == .authorizedAlways || locationAuthStatus == .authorizedWhenInUse) {
                self.directionSearchView.changeSearchRouteName(with: currentModel.locationName ?? "", isDestination: self.isDestination)
                viewModel.myLocationSelected()
            }
            else {
                    locationManager.requestPermissions()
            }
        }
        else {
            self.directionSearchView.changeSearchRouteName(with: "\(currentModel.locationName ?? ""), \(currentModel.label ?? "")", isDestination: self.isDestination)
        }
        Task {
            let state = try await viewModel.searchSelectedPlaceWith(currentModel, lat: userLocation?.lat, long: userLocation?.long)
            
            let canSearch = firstDestination != nil && firstDestination?.lat != nil && secondDestination != nil && secondDestination?.lat != nil
            
            if state && canSearch {
                self.sheetPresentationController?.selectedDetentIdentifier = .medium
                try await calculateGenericRoute(currentModel: currentModel, avoidFerries: viewModel.avoidFerries, avoidTolls: viewModel.avoidTolls, avoidUturns: viewModel.avoidUturns, avoidTunnels: viewModel.avoidTunnels, avoidDirtRoads: viewModel.avoidDirtRoads, leaveNow: viewModel.leaveNow, leaveTime: viewModel.leaveTime, arrivalTime: viewModel.arrivalTime)
            }
            tableView.isHidden = true
        }
       
    }
    
    func sendDirectionsToExploreVC(data: [Data],
                                   departureLocation: CLLocationCoordinate2D,
                                   destinationLocation: CLLocationCoordinate2D,
                                   routeType: RouteTypes) {
        let datas: [String: Any] = ["LineString" : data,
                                    "DepartureLocation": departureLocation,
                                    "DestinationLocation": destinationLocation,
                                    "routeType": routeType]
        NotificationCenter.default.post(name: Notification.directionLineString, object: nil, userInfo: datas)
    }
}
