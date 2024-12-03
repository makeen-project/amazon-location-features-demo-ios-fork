//
//  POICardViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation

final class POICardViewModel: POICardViewModelProcotol {
    
    private let routingService: RoutingServiceable
    private var datas: [MapModel]
    private var userLocation: CLLocationCoordinate2D?
    
    var delegate: POICardViewModelOutputDelegate?
    
    init(routingService: RoutingServiceable, datas: [MapModel], userLocation: CLLocationCoordinate2D?) {
        self.routingService = routingService
        self.datas = datas
        self.userLocation = userLocation
    }
    
    func setUserLocation(lat: Double?, long: Double?) {
        guard let lat, let long else {
            userLocation = nil
            return
        }
        
        userLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    func getMapModel() -> MapModel? {
        return datas.first
    }
    
    func fetchDatas() async throws {
        guard let cardData = datas.first else { return }
        let isLoading = cardData.distance == nil && cardData.duration == nil
        
        //we don't calculate route as we don't have current location
        guard let userLocation else {
            delegate?.populateDatas(cardData: cardData, isLoadingData: false, errorMessage: StringConstant.locationPermissionDenied, errorInfoMessage: StringConstant.locationPermissionDeniedDescription)
            return
        }
        
        guard let placeLat = cardData.placeLat, let placeLong = cardData.placeLong else { return }
        let destinationPosition = CLLocationCoordinate2D(latitude: placeLat, longitude: placeLong)
        delegate?.populateDatas(cardData: cardData, isLoadingData: isLoading, errorMessage: nil, errorInfoMessage: nil)
        let result = try await routingService.calculateRouteWith(depaturePosition: userLocation, destinationPosition: destinationPosition, travelModes: [.car], avoidFerries: true, avoidTolls: true, avoidUturns: true, avoidTunnels: true, avoidDirtRoads: true)
            
            var responseError: Error? = nil
            switch result[.car] {
            case .success(let direction):
                guard !(self.datas.isEmpty) else { break }
                
                self.datas[0].distance = direction.distance
                self.datas[0].duration = direction.duration.convertSecondsToMinString()
            case .failure(let error):
                responseError = error
            case .none:
                break
            }
            
            if let cardData = self.datas.first {
                self.delegate?.populateDatas(cardData: cardData, isLoadingData: false, errorMessage: responseError?.localizedDescription, errorInfoMessage: nil)
            }
    }
}

