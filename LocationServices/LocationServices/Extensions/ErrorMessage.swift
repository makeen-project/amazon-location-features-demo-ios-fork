//
//  ErrorMessage.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

enum ErrorMessage {
    static let errorInitWithCoder = "init(coder:) has not been implemented"
    static let errorAnimatorNotSet = "Somehow the offset animator was not set"
    static let errorCannotInitializeView = "Couldn't initialize view"
    static let errorUserDefaultsSave = "User Default save error:"
    static let errorUserDefaultsGet = "User Default get error:"
    static let errorCellCannotBeInitialized = "Cell can't be initialized"
    static let errorJSONDecoder = "JSON Decoder Error"
    static let cellCanNotBeDequed = "Cell can't be dequed"
    static let domainErrorLocalizedDescription = "The operation couldn’t be completed. (kCLErrorDomain error 0.)"
    static let testExpectationError = "expectation not matched after waiting"
}
