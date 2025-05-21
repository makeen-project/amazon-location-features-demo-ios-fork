//
//  StringConstants.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation


extension String {
    // LSFaux3DUserLocationAnnotationView
    
    // errors:
    static let errorInitWithCoder = "init(coder:) has not been implemented"
    static let errorAnimatorNotSet = "Somehow the offset animator was not set"
    static let errorCannotInitializeView = "Couldn't initiliza view"
    
    //static let errorDelegeGeofence = "Delete Geofence error:"
    static let errorUserDefaultsSave = "User Default save error:"
    static let errorUserDefaultsGet = "User Default get error:"
    //static let errorCannotReadDefaultConfiguration = "Can't read default configuration from awsconfiguration.json"
    
    static let errorCellCannotBeInititalized = "Cell can't be initilized"
    static let errorJSONDecoder = "JSON Decoder Error"
    static let cellCanNotBeDequed = "Cell can't be dequed"
    
    //static let errorToBeImplemented = "to be implemented"
    // errors
    static let domainErrorLocalizedDescription = "The operation couldn’t be completed. (kCLErrorDomain error 0.)"
    static let testExpectationError = "expectation not matched after waiting"
    static let sessionExpiredError = "Session is expired. Please sign out and sign in back to continue access all features. Otherwise you could face unexpected behaviour in the app"
   
    static let awsStackInvalidTitle = "Invalid AWS Stack"
    static let awsStackInvalidExplanation = "Stack is not invalid anymore or deleted, app will disconnect from AWS and restart"
}

// Strings
enum StringConstant {
    
    //urls
    static let baseDomain: String = "https://location.aws.com"
    static var termsAndConditionsURL: String { baseDomain + "/demo/terms/" }
    static let esriDataProviderLearnMoreURL = "https://www.esri.com/en-us/legal/terms/data-attributions"
    static let hereDataProviderLearnMoreURL = "https://legal.here.com/en-gb/terms/general-content-supplier-terms-and-notices"
    static var softwareAttributionLearnMoreURL: String { baseDomain + "/demo/software-attributions" }
    static let termsAndConditionsTrackingURL = "https://aws.amazon.com/service-terms/#82._Amazon_Location_Service"
    static var helpURL: String { StringConstant.baseDomain + "/demo/help" }
    
    // urls constant:
    static var developmentUrl: String {
        let regionName = Bundle.main.object(forInfoDictionaryKey: "AWSRegion") as! String
        return "maps.geo.\(regionName).amazonaws.com"
    }
    static let developmentSchema = "https"
    
    static let greatDistanceErrorTitle = LanguageManager.shared.localizedString(forKey:"Distance is greater than 400 km")
    static let greatDistanceErrorMessage = LanguageManager.shared.localizedString(forKey:"Can't calculate via Esri, kindly switch to HERE provider")
    static let invalidUrlError = LanguageManager.shared.localizedString(forKey:"URL is invalid. Can't open it")
    
    // strings:
    static let directions = LanguageManager.shared.localizedString(forKey:"Directions")
    static let maybeLater = LanguageManager.shared.localizedString(forKey:"Maybe later")
    static let checkYourConnection = LanguageManager.shared.localizedString(forKey:"Check your internet connection and try again")
    static let amazonLocatinCannotReach = LanguageManager.shared.localizedString(forKey:"Amazon Location can't reach the internet")
    static let terminate = LanguageManager.shared.localizedString(forKey:"Ok")
    static let failedToCalculateRoute = LanguageManager.shared.localizedString(forKey:"Failed to calculate route")
    static let noInternetConnection = LanguageManager.shared.localizedString(forKey:"No internet connection")
    static let trackers = LanguageManager.shared.localizedString(forKey:"Trackers")
    static let trackingChangeToHere = LanguageManager.shared.localizedString(forKey:"You can use any data provider except Esri for your asset management or device tracking use cases. If you want to use Esri for your asset management or tracking user case, please read terms and conditions.")
    static let enableTrackingDescription = LanguageManager.shared.localizedString(forKey:"Enabling the feature will allow you to track your device and get notified when the device enters or exits any of your geofences.")
    
    static let startTracking = LanguageManager.shared.localizedString(forKey:"Start Tracking")
    static let stopTracking = LanguageManager.shared.localizedString(forKey:"Stop Tracking")
    static let startSimulation = LanguageManager.shared.localizedString(forKey:"Try Trackers & Geofences simulation")
    static let simulation = LanguageManager.shared.localizedString(forKey:"Simulation")
    static let trackersGeofences = LanguageManager.shared.localizedString(forKey:"Trackers and Geofences")
    static let trackersGeofencesHeader = LanguageManager.shared.localizedString(forKey:"Tracking and Geofence simulation")
    static let trackersGeofencesDetail = LanguageManager.shared.localizedString(forKey:"Enter the Trackers simulation to view the path across Vancouver streets that crosses Geofences")
    static let startTrackingSimulation = LanguageManager.shared.localizedString(forKey:"Try Trackers & Geofences Simulation")
    static let trackersDetail = LanguageManager.shared.localizedString(forKey:"Visualize your location history on the map")
    static let geofences = LanguageManager.shared.localizedString(forKey:"Geofences")
    static let geofencesDetail = LanguageManager.shared.localizedString(forKey:"Define virtual boundaries around a specific area to detect entry and exit events")
    static let notifications = LanguageManager.shared.localizedString(forKey:"Notifications")
    static let notificationsDetail = LanguageManager.shared.localizedString(forKey:"Get geofence messages when you enter and leave locations")
    static let routesNotifications = LanguageManager.shared.localizedString(forKey:"Routes Notifications")
    
    static let emptyTrackingHistory = LanguageManager.shared.localizedString(forKey:"No tracking history available")
    
    static let tracker = LanguageManager.shared.localizedString(forKey:"Tracker")
    static let entered = LanguageManager.shared.localizedString(forKey:"Entered")
    static let exited = LanguageManager.shared.localizedString(forKey:"Exited")
    static let exit = LanguageManager.shared.localizedString(forKey:"Exit")
    
    static let change = LanguageManager.shared.localizedString(forKey:"Change")
    
    static let go = LanguageManager.shared.localizedString(forKey:"Go")
    static let preview = LanguageManager.shared.localizedString(forKey:"Preview")
    static let info = LanguageManager.shared.localizedString(forKey:"Info")
    static let done = LanguageManager.shared.localizedString(forKey:"Done")
    
    static let locationPermissionDenied = LanguageManager.shared.localizedString(forKey:"Location permission denied")
    static let locationPermissionDeniedDescription = LanguageManager.shared.localizedString(forKey:"Distance can't be calculated if location permission is not granted. Please enable location permission for Amazon Location from Settings")
    static let esriDistanceError = LanguageManager.shared.localizedString(forKey:"In DataSource Esri, all waypoints must be within 400km")
    static let locationPermissionEnableLocationAction = LanguageManager.shared.localizedString(forKey:"Enable Location")
    static let locationPermissionAlertTitle = LanguageManager.shared.localizedString(forKey:"Allow \"LocationServices\" to use your location")
    static let locationPermissionAlertText = LanguageManager.shared.localizedString(forKey:"Amazon Location will use your location to create a route to the selected location")
    
    // location manager
    static let locationManagerAlertTitle = LanguageManager.shared.localizedString(forKey:"Allow \"LocationServices\" to use your location?")
    static let locationManagerAlertText = LanguageManager.shared.localizedString(forKey:"We need your location to detect your location in map")
    static let cancel = LanguageManager.shared.localizedString(forKey:"Cancel")
    static let settigns = LanguageManager.shared.localizedString(forKey:"Settings")
    static let error = LanguageManager.shared.localizedString(forKey:"Error")
    static let warning = LanguageManager.shared.localizedString(forKey:"Warning")
    static let ok = LanguageManager.shared.localizedString(forKey:"OK")
    
    // dispatch queue
    static let dispatchReachabilityLabel = LanguageManager.shared.localizedString(forKey:"Reachability")
    
    // coordinate label text
    static let coordinateLabelText = LanguageManager.shared.localizedString(forKey:"50.54943, 30.21989")
    static let timeLabelText = LanguageManager.shared.localizedString(forKey:"11:22 pm")
    
    // Tracking Simulation
    static let exitTracking = LanguageManager.shared.localizedString(forKey:"")
    static let exitTrackingAlertMessage = LanguageManager.shared.localizedString(forKey:"Are you sure you want to exit simulation?")
    
    enum AboutTab {
        static let title = LanguageManager.shared.localizedString(forKey:"More")
        static let cellAttributionTitle = LanguageManager.shared.localizedString(forKey:"Attribution")
        static let cellLegalTitle = LanguageManager.shared.localizedString(forKey:"Terms & Conditions")
        static let cellVersionTitle = LanguageManager.shared.localizedString(forKey:"Version")
        static let cellHelpTitle = LanguageManager.shared.localizedString(forKey:"Help")
    }
    
    enum About {
        static let descriptionTitle = LanguageManager.shared.localizedString(forKey:"DownloadTermsConditions")
        static let appTermsOfUse = LanguageManager.shared.localizedString(forKey:"Terms & Conditions")
        static let appTermsOfUseURL = termsAndConditionsURL
        static let copyright = LanguageManager.shared.localizedString(forKey:"© \(Calendar.current.component(.year, from: Date())), Amazon Web Services, Inc. or its affiliates. All rights reserved.")
    }
    
    enum Tracking {
        static let noTracking = LanguageManager.shared.localizedString(forKey:"Device tracking inactive")
        static let isTracking = LanguageManager.shared.localizedString(forKey:"Device tracking is active")
    }
    
    enum TabBar {
        static let explore: String = LanguageManager.shared.localizedString(forKey:"Navigate")
        static let tracking: String = LanguageManager.shared.localizedString(forKey: "Trackers") //LanguageManager.shared.localizedString(forKey:"Trackers")
        static let settings: String = LanguageManager.shared.localizedString(forKey:"Settings")
        static let about: String = LanguageManager.shared.localizedString(forKey:"More")
    }
    
    enum NotificationsInfoField {
        static let geofenceIsHidden = LanguageManager.shared.localizedString(forKey:"geofenceIsHidden")
        static let mapStyleIsHidden = LanguageManager.shared.localizedString(forKey:"mapStyleIsHidden")
        static let directionIsHidden = LanguageManager.shared.localizedString(forKey:"directionIsHidden")
    }
    
    static let units = LanguageManager.shared.localizedString(forKey:"Units")
    static let dataProvider = LanguageManager.shared.localizedString(forKey:"Data Provider")
    static let mapStyle = LanguageManager.shared.localizedString(forKey:"Map style")
    static let defaultRouteOptions = LanguageManager.shared.localizedString(forKey:"Default route options")
    static let partnerAttributionTitle = LanguageManager.shared.localizedString(forKey:"Partner Attribution")
    static let partnerAttributionHEREDescription = LanguageManager.shared.localizedString(forKey:"© AWS, HERE")
    static let softwareAttributionTitle = LanguageManager.shared.localizedString(forKey:"Software Attribution")
    static let softwareAttributionDescription = LanguageManager.shared.localizedString(forKey:"Click learn more for software attribution")
    static let learnMore = LanguageManager.shared.localizedString(forKey:"Learn More")
    static let attribution = LanguageManager.shared.localizedString(forKey:"Attribution")
    static let about = LanguageManager.shared.localizedString(forKey:"More")
    static let version = LanguageManager.shared.localizedString(forKey:"Version")
    static let welcomeTitle = LanguageManager.shared.localizedString(forKey:"Welcome to\nAmazon Location Demo")
    static let continueString = LanguageManager.shared.localizedString(forKey:"Continue")
    static let avoidTolls = LanguageManager.shared.localizedString(forKey:"Avoid tolls")
    static let avoidFerries = LanguageManager.shared.localizedString(forKey:"Avoid ferries")
    static let avoidUturns = LanguageManager.shared.localizedString(forKey:"Avoid uturns")
    static let avoidTunnels = LanguageManager.shared.localizedString(forKey:"Avoid tunnels")
    static let avoidDirtRoads = LanguageManager.shared.localizedString(forKey:"Avoid dirt roads")
    static let myLocation = LanguageManager.shared.localizedString(forKey:"My Location")
    static let appVersion = LanguageManager.shared.localizedString(forKey:"App version: ")
    static let termsAndConditions = LanguageManager.shared.localizedString(forKey:"Terms & Conditions")
    //static let disconnect = LanguageManager.shared.localizedString(forKey:"Disconnect")
    static let demo = LanguageManager.shared.localizedString(forKey:"Demo")
    static let routeOverview = LanguageManager.shared.localizedString(forKey:"Route Overview")
    
    static let viewRoute = LanguageManager.shared.localizedString(forKey:"View Route")
    static let hideRoute = LanguageManager.shared.localizedString(forKey:"Hide Route")
    
    static let trackingNotificationTitle = LanguageManager.shared.localizedString(forKey:"Amazon Location")

    static let arrivalCardTitle = LanguageManager.shared.localizedString(forKey:"You've arrived!")
    static let poiCardSchedule = LanguageManager.shared.localizedString(forKey:"Schedule")
    static let language = LanguageManager.shared.localizedString(forKey:"Language")
    static let politicalView = LanguageManager.shared.localizedString(forKey:"Political view")
    static let mapRepresentation = LanguageManager.shared.localizedString(forKey:"Map representation for different countries")
    static let mapLanguage = LanguageManager.shared.localizedString(forKey:"Map language")
    static let selectLanguage = LanguageManager.shared.localizedString(forKey:"Select Language")
    static let leaveNow = LanguageManager.shared.localizedString(forKey:"Leave now")
    static let leaveAt = LanguageManager.shared.localizedString(forKey:"Leave at")
    static let arriveBy = LanguageManager.shared.localizedString(forKey:"Arrive by")
    static let routeOptions = LanguageManager.shared.localizedString(forKey:"Route Options")
    static let options = LanguageManager.shared.localizedString(forKey:"Options")
    static let selected = LanguageManager.shared.localizedString(forKey:"Selected")
    static let routesActive = LanguageManager.shared.localizedString(forKey:"routes active")
    static let politicalLight = LanguageManager.shared.localizedString(forKey:"Light")
    static let politicalDark = LanguageManager.shared.localizedString(forKey:"Dark")
    
    // Languages
    static let deutsch = "Deutsch"
    static let spanish = "Español"
    static let english = "English"
    static let french = "Français"
    static let italian = "Italiano"
    static let protugeseBrasil = "Português Brasileiro"
    static let simplifiedChinese = "简体中文"
    static let traditionalChinese = "繁体中文"
    static let japanese = "日本語"
    static let korean = "한국어"
    static let arabic = "العربية"
    static let hebrew = "עברית"
    static let hindi = "हिन्दी"

}
