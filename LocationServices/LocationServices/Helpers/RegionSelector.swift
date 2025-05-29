//
//  RegionSelector.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

class RegionSelector {
    
    static let shared = RegionSelector()
    private init() {}

    func getBundleRegions() -> [String]? {
        let regions = (Bundle.main.object(forInfoDictionaryKey: "AWSRegions") as? String)?.components(separatedBy: ",")
        return regions
    }

    func getCachedRegion() -> String? {
        return UserDefaultsHelper.get(for: String.self, key: .awsRegion)
    }
    
    func isAutoRegion() -> Bool? {
        return UserDefaultsHelper.get(for: Bool.self, key: .isAutoRegion)
    }
    
    func saveCachedRegion(region: String, isAutoRegion: Bool) {
        UserDefaultsHelper.save(value: region, key: .awsRegion)
        UserDefaultsHelper.save(value: isAutoRegion, key: .isAutoRegion)
    }
    
    func clearCachedRegion() {
        UserDefaultsHelper.removeObject(for: .awsRegion)
    }
    
    func setClosestRegion(apiRegions: [String], completion: @escaping (String?) -> Void) {
        if let cachedRegion = getCachedRegion(),
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
            let fastestRegion = mapping.min(by: { $0.value < $1.value })?.key
            if let fastest = fastestRegion {
                self.saveCachedRegion(region: fastest, isAutoRegion: true)
            }
            completion(fastestRegion)
        }
    }
    

}
