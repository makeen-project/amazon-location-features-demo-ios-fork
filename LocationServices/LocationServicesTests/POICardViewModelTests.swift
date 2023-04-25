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
    let mapModel = MapModel(placeName: "Pittsburgh", placeAddress: "Pittsburgh, United States", placeLat: 40.4511974790006, placeLong: -80.00247659228356)
    var delegate: MockPOICardViewModelOutputDelegate!
    var pOICardViewModel: POICardViewModel!
    
    enum Constants {
        static let waitRequestDuration: TimeInterval = 10
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        delegate = MockPOICardViewModelOutputDelegate()
        pOICardViewModel = POICardViewModel(routingService: RoutingAPIService(), datas: [mapModel], userLocation: nil)
        pOICardViewModel.delegate = delegate
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetMapModels() throws {
        XCTAssertEqual(pOICardViewModel.getMapModel()?.placeLat, mapModel.placeLat, "Expected mapModel placeLat equal")
    }
    
    func testFetchDatasWithoutUserLocation() throws {
        pOICardViewModel.fetchDatas()
        XCTAssertEqual(delegate.populateDatasErrorMessage, "Location permission denied", "Expected Location permission denied")
    }
    
    func testFetchDatasWithMaxDistance() throws {
        pOICardViewModel.setUserLocation(lat: userLocation.latitude, long: userLocation.longitude)
        pOICardViewModel.fetchDatas()
        
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.populateDatasErrorMessage == "In DataSource Esri, all waypoints must be within 400km"
        }, timeout: Constants.waitRequestDuration, message: "MapModel should've throw max distance error")
    }
    
    func testFetchDatasWithSuccess() throws {
        pOICardViewModel.setUserLocation(lat: 40.4400930458457, long: -80.00348250162394)
        pOICardViewModel.fetchDatas()
        
        XCTWaiter().wait(until: { [weak self] in
            return self?.pOICardViewModel.getMapModel()?.distance == 1664
        }, timeout: Constants.waitRequestDuration, message: "MapModel should've valid distance")
    }
    
    func testFetchDatasWithFailure() throws {
        pOICardViewModel.setUserLocation(lat: 0, long: -100)
        pOICardViewModel.fetchDatas()

        XCTWaiter().wait(until: { [weak self] in
            return (self?.delegate.populateDatasErrorMessage == "In DataSource Esri, all waypoints must be within 400km")
        }, timeout: Constants.waitRequestDuration, message: "populateDatas should've been called with failure")
    }

}


class MockPOICardViewModelOutputDelegate: POICardViewModelOutputDelegate {
    func dismissPoiView() {
        
    }
    
    func showDirectionView(seconDestination: MapModel) {
        
    }
    
    func updateSizeClass(_ sizeClass: POICardVC.DetentsSizeClass) {
        
    }
    
    func showAlert(_ model: AlertModel) {
        
    }
    
    
    var populateDatasCalled = false
    var populateDatasCardData: MapModel? = nil
    var populateDatasIsLoadingData: Bool? = nil
    var populateDatasErrorMessage: String? = nil
    var populateDatasErrorInfoMessage: String? = nil
    
    func populateDatas(cardData: MapModel, isLoadingData: Bool, errorMessage: String?, errorInfoMessage: String?) {
        populateDatasCalled = true
        populateDatasCardData = cardData
        populateDatasIsLoadingData = isLoadingData
        populateDatasErrorMessage = errorMessage
        populateDatasErrorInfoMessage = errorInfoMessage
    }
}
