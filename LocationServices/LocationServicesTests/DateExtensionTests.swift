//
//  DateExtensionTests.swift
//  LocationServicesTests
//
//  Created by Zeeshan Sheikh on 17/04/2023.
//

import XCTest
@testable import LocationServices

final class DateExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConvertStringToDate() throws {
       let date = Date.convertStringToDate("2023-03-17T10:00:00Z")
        XCTAssertNotEqual(date, nil, "Expected string to date")
    }
    
    func testConvertTimeString() throws {
       let date = Date.convertStringToDate("2023-03-17T10:00:00Z")
        XCTAssertEqual(date?.convertTimeString(), "10:00 AM", "Expected string time")
    }
    
    func testConvertDateString() throws {
       let date = Date.convertStringToDate("2023-03-17T10:00:00Z")
        XCTAssertEqual(date?.convertDateString(), "Mar 17, 2023", "Expected string date")
    }
    
    func testConvertToString() throws {
       let date = Date.convertStringToDate("2023-03-17T10:00:00Z")
        XCTAssertEqual(date?.convertToString(format: "dd-MM-yyyy hh:mm:ss"), "17-03-2023 10:00:00", "Expected date to string")
    }
    
    func testConvertToRelativeString() throws {
       let date = Date.convertStringToDate("2023-03-17T10:00:00Z")
        XCTAssertEqual(date?.convertToRelativeString(), "Mar 17, 2023", "Expected relative date string")
    }
    
    func testTruncateTime() throws {
       let date = Date.convertStringToDate("2023-03-17T10:00:00Z")
        XCTAssertEqual(date?.truncateTime().convertToString(format: "dd-MM-yyyy hh:mm:ss"), "17-03-2023 12:00:00", "Expected truncated date")
    }

}
