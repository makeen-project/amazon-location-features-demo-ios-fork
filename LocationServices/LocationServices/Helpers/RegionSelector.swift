//
//  RegionSelector.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

class AWSRegionSelector {
    
    static let shared = AWSRegionSelector()
    private init() {}

    func setFastestAWSRegion(apiRegions: [String], completion: @escaping (String?) -> Void) {
        if let cachedRegion = getFastestAWSRegion(),
           apiRegions.contains(cachedRegion) {
            completion(cachedRegion)
            return
        }
        
        var mapping: [String: TimeInterval] = [:]
        let dispatchGroup = DispatchGroup()
        
        for region in apiRegions {
            dispatchGroup.enter()
            let startTime = Date()
            var request = URLRequest(url: URL(string: "https://dynamodb.\(region).amazonaws.com")!)
            request.httpMethod = "HEAD"

            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if error == nil {
                    let duration = Date().timeIntervalSince(startTime)
                    mapping[region] = duration
                }
                dispatchGroup.leave()
            }
            task.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            let fastestAWSRegion = mapping.min(by: { $0.value < $1.value })?.key
            if let fastest = fastestAWSRegion {
                UserDefaultsHelper.save(value: fastest, key: .fastestAWSRegion)
            }
            completion(fastestAWSRegion)
        }
    }
    
    func getFastestAWSRegion() -> String? {
        return UserDefaultsHelper.get(for: String.self, key: .fastestAWSRegion)
    }
}
