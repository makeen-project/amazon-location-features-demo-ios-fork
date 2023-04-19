//
//  POICardViewModelTests.swift
//  POICardViewModelTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices
import CoreLocation

final class POICardViewModelTests: XCTestCase {

    let userLocation = CLLocationCoordinate2D(latitude: 40.7487776237092, longitude: -73.98554260340953)
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetMapModels() throws {
        let mapModel = MapModel(placeName: "Times Square", placeAddress: "Manhattan, NY 10036, United States", placeLat: 40.758112753330224, placeLong: -73.98556408012698)
        let pOICardViewModel = POICardViewModel(routingService: RoutingAPIService(), datas: [mapModel], userLocation: userLocation)
        XCTAssertEqual(pOICardViewModel.getMapModel()?.placeLat, mapModel.placeLat, "Expected mapModel placeLat equal")
    }
    
//    func testFetchDatasWithUserLocation() throws {
//        let mapModel = MapModel(placeName: "Times Square", placeAddress: "Manhattan, NY 10036, United States", placeLat: 40.758112753330224, placeLong: -73.98556408012698)
//        let pOICardViewModel = POICardViewModel(routingService: RoutingAPIService(), datas: [mapModel], userLocation: userLocation)
//        pOICardViewModel.fetchDatas()
//        sleep(5)
//        XCTAssertEqual(pOICardViewModel.getMapModel()?.distance, 12, "Expected mapModel placeLat equal")
//    }

}
