//
//  PlaceholderAnimatorTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class PlaceholderAnimatorTests: XCTestCase {
    var placeholderAnimator: PlaceholderAnimator!
    
    var dataView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    var placeholderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override func setUp() {
        super.setUp()
        placeholderAnimator = PlaceholderAnimator(dataViews: [dataView], placeholderViews: [placeholderView])
    }

    override func tearDown() {
        placeholderAnimator = nil
        super.tearDown()
    }

    func testAnimationStatus() throws {
        placeholderAnimator.setupAnimationStatus(isActive: true)
        XCTAssertTrue(dataView.isHidden)
        XCTAssertFalse(placeholderView.isHidden)
        
        placeholderAnimator.setupAnimationStatus(isActive: false)
        XCTAssertFalse(dataView.isHidden)
        XCTAssertTrue(placeholderView.isHidden)
    }
}
