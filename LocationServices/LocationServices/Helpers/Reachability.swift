//
//  Reachability.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import Network

class Reachability {
    
    static let shared = Reachability()
    
    private let monitor: NWPathMonitor
    
    private(set) var currentStatus: NWPath.Status?
    var isInternetReachable: Bool {
        return currentStatus == .satisfied
    }
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.currentStatus = path.status
        }
        let queue = DispatchQueue(label: StringConstant.dispatchReachabilityLabel)
        monitor.start(queue: queue)
    }
}
