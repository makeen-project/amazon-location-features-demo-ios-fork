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
        static let waitExpectationDuration: TimeInterval = 10
        static let expectationTimeout: TimeInterval = 10
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
        let myDelegateExpectation = expectation(description: "The delegate method was called")
        pOICardViewModel.setUserLocation(lat: userLocation.latitude, long: userLocation.longitude)
        pOICardViewModel.fetchDatas()
        
        // Wait for myDelegateFunction to be called
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.waitExpectationDuration) {
            myDelegateExpectation.fulfill()
        }
        
        wait(for: [myDelegateExpectation], timeout: Constants.expectationTimeout)
        XCTAssertEqual(delegate.populateDatasErrorMessage, "In DataSource Esri, all waypoints must be within 400km", "Expected max distance error true")
    }
    
    func testFetchDatasWithSuccess() throws {
        let myDelegateExpectation = expectation(description: "The delegate method was called")
        pOICardViewModel.setUserLocation(lat: 40.4400930458457, long: -80.00348250162394)
        pOICardViewModel.fetchDatas()
        
        // Wait for myDelegateFunction to be called
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.waitExpectationDuration) {
            myDelegateExpectation.fulfill()
        }
        
        wait(for: [myDelegateExpectation], timeout: Constants.expectationTimeout)
        XCTAssertEqual(pOICardViewModel.getMapModel()?.distance, 1664, "Expected distance value")
    }
    
    func testFetchDatasWithFailure() throws {
        let myDelegateExpectation = expectation(description: "The delegate method was called")
        pOICardViewModel.setUserLocation(lat: 0, long: -100)
        pOICardViewModel.fetchDatas()
        
        // Wait for myDelegateFunction to be called
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.waitExpectationDuration) {
            myDelegateExpectation.fulfill()
        }
        
        wait(for: [myDelegateExpectation], timeout: Constants.expectationTimeout)
        XCTAssertEqual(delegate.populateDatasErrorMessage, "In DataSource Esri, all waypoints must be within 400km", "Expected max distance error true")
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
