//
//  Endpoint.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol Endpoint {
    var scheme: String { get }
    var baseURL: String { get }
    var path: String { get }
    var httpMethod: HttpMethod { get }
    var header: [String: String]? { get }
    var body: [String: String]? { get }
}

extension Endpoint {
    var scheme: String {
        NetworkCore.shared.enviroment.scheme
    }
    
    var baseURL: String {
        NetworkCore.shared.enviroment.baseURL
    }
}
