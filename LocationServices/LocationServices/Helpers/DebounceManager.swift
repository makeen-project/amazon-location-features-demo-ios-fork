//
//  DebounceManager.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

class DebounceManager {
    
    private let debounceDuration: TimeInterval
    private var timer: Timer?
    
    init(debounceDuration: TimeInterval) {
        self.debounceDuration = debounceDuration
    }
    
    func debounce(action: @escaping ()->()) {
        stopTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: debounceDuration, repeats: false) { _ in
            action()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
