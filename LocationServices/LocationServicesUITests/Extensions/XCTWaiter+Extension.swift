//
//  XCTWaiter+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0


import XCTest

extension XCTWaiter {
    func wait(
        until expression: @escaping () -> Bool,
        timeout: TimeInterval = UITestWaitTime.regular.time,
        message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard !expression() else { return }

        let predicate = NSPredicate { _, _ in
            expression()
        }

        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)

        if result != .completed {
            XCTFail(
                message.isEmpty ? String.testExpectationError : message,
                file: file,
                line: line
            )
        }
    }
}
