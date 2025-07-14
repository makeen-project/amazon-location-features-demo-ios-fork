//
//  AppDelegate.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // setup initial state of app:
        if UserDefaultsHelper.get(for: Int.self, key: .appState) == nil {
            UserDefaultsHelper.setAppState(state: .initial)
        }
        
        //init keyboard observer
        let _ = KeyboardObserver.shared
        SettingsDefaultValueHelper.shared.createValues()

        
        Reachability.shared.startMonitoring()
        // Install crash handlers early
        installCrashHandlers()
        return true
    }
    
    // Your custom crash handler installer
    private func installCrashHandlers() {
        // Uncaught Objective-C exceptions
        NSSetUncaughtExceptionHandler { exception in
            let properties: [(String, String)] = [(AnalyticsAttribute.error, exception.reason ?? "No reason provided")]
            AnalyticsHelper.shared.recordEvent(AnalyticsEvent.applicationError, properties: properties)
        }
        var lowLevelCrash = ""
        // Handle fatal signals (e.g., SIGABRT, SIGSEGV)
        signal(SIGABRT) { signal in
            let properties: [(String, String)] = [(AnalyticsAttribute.error, "Received SIGABRT")]
            AnalyticsHelper.shared.recordEvent(AnalyticsEvent.applicationError, properties: properties)
         }
        signal(SIGILL) { signal in
            let properties: [(String, String)] = [(AnalyticsAttribute.error, "Received SIGILL")]
            AnalyticsHelper.shared.recordEvent(AnalyticsEvent.applicationError, properties: properties)
        }
        signal(SIGSEGV) { signal in
            let properties: [(String, String)] = [(AnalyticsAttribute.error, "Received SIGSEGV")]
            AnalyticsHelper.shared.recordEvent(AnalyticsEvent.applicationError, properties: properties)
        }
        signal(SIGFPE) { signal in
            let properties: [(String, String)] = [(AnalyticsAttribute.error, "Received SIGFPE")]
            AnalyticsHelper.shared.recordEvent(AnalyticsEvent.applicationError, properties: properties)
        }
        signal(SIGBUS) { signal in
            let properties: [(String, String)] = [(AnalyticsAttribute.error, "Received SIGBUS")]
            AnalyticsHelper.shared.recordEvent(AnalyticsEvent.applicationError, properties: properties)
        }
        signal(SIGPIPE) { signal in
            let properties: [(String, String)] = [(AnalyticsAttribute.error, "Received SIGPIPE")]
            AnalyticsHelper.shared.recordEvent(AnalyticsEvent.applicationError, properties: properties)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
