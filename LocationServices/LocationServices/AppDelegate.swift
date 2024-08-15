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
    
    var navigationController: UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // setup initial state of app:
        if UserDefaultsHelper.get(for: Int.self, key: .appState) == nil {
            UserDefaultsHelper.setAppState(state: .initial)
        }
        
        //init keyboard observer
        let _ = KeyboardObserver.shared
        SettingsDefaultValueHelper.shared.createValues()
        
        // debug logger for AWS
        //AWSDDLog.sharedInstance.logLevel = .debug
        //AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        
        Reachability.shared.startMonitoring()
        
        return true
    }
    
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        AWSMobileClient.default().handleAuthResponse(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
//        return AWSMobileClient.default().interceptApplication(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
//    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
