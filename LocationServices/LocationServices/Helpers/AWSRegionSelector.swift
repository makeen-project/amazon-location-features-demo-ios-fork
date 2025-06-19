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

    func getBundleRegions() -> [String]? {
        let regions = (Bundle.main.object(forInfoDictionaryKey: "AWSRegions") as? String)?.components(separatedBy: ",")
        return regions
    }

    func getCachedRegion() -> String? {
        return UserDefaultsHelper.get(for: String.self, key: .fastestAWSRegion)
    }
    
    func isAutoRegion() -> Bool? {
        return UserDefaultsHelper.get(for: Bool.self, key: .isAutoRegion)
    }
    
    func saveCachedRegion(region: String, isAutoRegion: Bool) {
        UserDefaultsHelper.save(value: region, key: .fastestAWSRegion)
        UserDefaultsHelper.save(value: isAutoRegion, key: .isAutoRegion)
    }
    
    func clearCachedRegion() {
        UserDefaultsHelper.removeObject(for: .fastestAWSRegion)
    }
    
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
                self.saveCachedRegion(region: fastest, isAutoRegion: true)
            }
            completion(fastestAWSRegion)
        }
    }
    
    func getFastestAWSRegion() -> String? {
        return UserDefaultsHelper.get(for: String.self, key: .fastestAWSRegion)
    }
}
