//
//  UtilTests.swift
//  LocationServicesTests
//
//  Created by Zeeshan Sheikh on 13/04/2023.
//

import XCTest
@testable import LocationServices

final class UtilTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConvertSecondsToMinString() throws {
        let seconds: Double = 3600
       XCTAssertEqual(seconds.convertSecondsToMinString(), "1 hr", "testConvertSecondsToMinString successful")
    }
    
    func testConvertKMToM() throws {
        let km: Double = 1
       XCTAssertEqual(km.convertKMToM(), 1000, "testConvertSecondsToMinString successful")
    }
    
    func testConvertFormattedKMString() throws {
        let km: Double = 1
       XCTAssertEqual(km.convertFormattedKMString(), "1000.0 m", "testConvertSecondsToMinString successful")
    }
    
    func testConvertToKM() throws {
        let km: Int = 1000
       XCTAssertEqual(km.convertToKm(), "1000.0 m", "testConvertSecondsToMinString successful")
    }
    
    func testConvertIdentityPoolIdToRegionType() throws {
        let idpID = "us-east-2:35841fd0-257a-46c5-b44e-fd289ab6e194"
        XCTAssertEqual(idpID.toRegionType(), .USEast2, "testConvertIdentityPoolIdToRegionType successful")
    }

    func testConvertIdentityPoolIdToRegionString() throws {
        let idpID = "us-east-2:35841fd0-257a-46c5-b44e-fd289ab6e194"
        XCTAssertEqual(idpID.toRegionString(), "us-east-2", "testConvertIdentityPoolIdToRegionString successful")
    }
    
    func testCreateInitial() throws {
       let model =  "South America"
        XCTAssertEqual(model.createInitial(), "SA", "testCreateInitial successful")
    }
    
    func testConvertTextToCoordinate() throws {
       let text =  "40.75782863140032, -73.98573463547527"
        XCTAssertEqual(text.convertTextToCoordinate().first?.stringValue, "-73.98573463547527", "testConvertTextToCoordinate successful")
    }

    func testFormatAddressField() throws {
       let address =  "1501 Broadway, New York, NY 10036, United States"
        XCTAssertEqual(address.formatAddressField().first, "1501 Broadway", "testFormatAddressField successful")
    }
    
    func testIsCoordinate() throws {
       let coordinate =  "40.75782863140032, -73.98573463547527"
        XCTAssertEqual(coordinate.isCoordinate(), true, "testIsCoordinate successful")
    }
    
    func testHighlightAsLinkWithNoOccurance() {
        let attributedString = NSMutableAttributedString(string: "Click here to run a CloudFormation template to securely create required resources.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.amazonFont(type: .bold, size: 13)])
        let linkWasSet = attributedString.highlightAsLink(textOccurances: "Tap Here")
        XCTAssertEqual(linkWasSet, false, "testHighlightAsLinkWithNoOccurance successful")
    }
    
    func testHighlightAsLinkWithWithOccurances() {
        let attributedString = NSMutableAttributedString(string: "Click here to run a CloudFormation template to securely create required resources.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.amazonFont(type: .bold, size: 13)])
        let linkWasSet = attributedString.highlightAsLink(textOccurances: "Click here")
        XCTAssertEqual(linkWasSet, true, "testHighlightAsLinkWithWithOccurances successful")
    }
    
    func testHighlightAsLinkWithWithMultipleOccurances() {
        let attributedString = NSMutableAttributedString(string: "Click here to run a CloudFormation template to securely create required resources. Or Click here to see the details", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.amazonFont(type: .bold, size: 13)])
        let linkWasSet = attributedString.highlightAsLink(textOccurances: "Click here")
        XCTAssertEqual(linkWasSet, true, "testHighlightAsLinkWithWithMultipleOccurances successful")
    }
    
}
