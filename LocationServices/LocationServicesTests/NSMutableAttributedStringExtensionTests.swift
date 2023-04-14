//
//  NSMutableAttributedStringExtensionTests.swift
//  NSMutableAttributedStringExtensionTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class NSMutableAttributedStringExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testHighlightAsLinkWithNoOccurance() throws {
        let attributedString = NSMutableAttributedString(string: "Click here to run a CloudFormation template to securely create required resources.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.amazonFont(type: .bold, size: 13)])
        let linkWasSet = attributedString.highlightAsLink(textOccurances: "Tap Here")
        XCTAssertEqual(linkWasSet, false, "No occurances found")
    }
    
    func testHighlightAsLinkWithWithOccurances() throws {
        let attributedString = NSMutableAttributedString(string: "Click here to run a CloudFormation template to securely create required resources.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.amazonFont(type: .bold, size: 13)])
        let linkWasSet = attributedString.highlightAsLink(textOccurances: "Click here")
        XCTAssertEqual(linkWasSet, true, "Single occurance found and link was set")
    }
    
    func testHighlightAsLinkWithWithMultipleOccurances() throws {
        let attributedString = NSMutableAttributedString(string: "Click here to run a CloudFormation template to securely create required resources. Or Click here to see the details", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.amazonFont(type: .bold, size: 13)])
        let linkWasSet = attributedString.highlightAsLink(textOccurances: "Click here")
        XCTAssertEqual(linkWasSet, true, "Multiple occurances found and links were set")
    }
}
