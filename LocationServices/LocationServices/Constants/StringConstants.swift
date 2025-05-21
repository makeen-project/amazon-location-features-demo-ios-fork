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
    
    static let greatDistanceErrorTitle = NSLocalizedString("Distance is greater than 400 km", comment: "")
    static let greatDistanceErrorMessage = NSLocalizedString("Can't calculate via Esri, kindly switch to HERE provider", comment: "")
    static let invalidUrlError = NSLocalizedString("URL is invalid. Can't open it", comment: "")
    
    // strings:
    static let directions = NSLocalizedString("Directions", comment: "")
    static let maybeLater = NSLocalizedString("Maybe later", comment: "")
    static let checkYourConnection = NSLocalizedString("Check your internet connection and try again", comment: "")
    static let amazonLocatinCannotReach = NSLocalizedString("Amazon Location can't reach the internet", comment: "")
    static let terminate = NSLocalizedString("Ok", comment: "")
    static let failedToCalculateRoute = NSLocalizedString("Failed to calculate route", comment: "")
    static let noInternetConnection = NSLocalizedString("No internet connection", comment: "")
    static let trackers = NSLocalizedString("Trackers", comment: "")
    static let trackingChangeToHere = NSLocalizedString("You can use any data provider except Esri for your asset management or device tracking use cases. If you want to use Esri for your asset management or tracking user case, please read terms and conditions.", comment: "")
    static let enableTrackingDescription = NSLocalizedString("Enabling the feature will allow you to track your device and get notified when the device enters or exits any of your geofences.", comment: "")
    
    static let startTracking = NSLocalizedString("Start Tracking", comment: "")
    static let stopTracking = NSLocalizedString("Stop Tracking", comment: "")
    static let startSimulation = NSLocalizedString("Try Trackers & Geofences simulation", comment: "")
    static let simulation = NSLocalizedString("Simulation", comment: "")
    static let trackersGeofences = NSLocalizedString("Trackers and Geofences", comment: "")
    static let trackersGeofencesHeader = NSLocalizedString("Tracking and Geofence simulation", comment: "")
    static let trackersGeofencesDetail = NSLocalizedString("Enter the Trackers simulation to view the path across Vancouver streets that crosses Geofences", comment: "")
    static let startTrackingSimulation = NSLocalizedString("Try Trackers & Geofences Simulation", comment: "")
    static let trackersDetail = NSLocalizedString("Visualize your location history on the map", comment: "")
    static let geofences = NSLocalizedString("Geofences", comment: "")
    static let geofencesDetail = NSLocalizedString("Define virtual boundaries around a specific area to detect entry and exit events", comment: "")
    static let notifications = NSLocalizedString("Notifications", comment: "")
    static let notificationsDetail = NSLocalizedString("Get geofence messages when you enter and leave locations", comment: "")
    static let routesNotifications = NSLocalizedString("Routes Notifications", comment: "")
    
    static let emptyTrackingHistory = NSLocalizedString("No tracking history available", comment: "")
    
    static let tracker = NSLocalizedString("Tracker", comment: "")
    static let entered = NSLocalizedString("Entered", comment: "")
    static let exited = NSLocalizedString("Exited", comment: "")
    static let exit = NSLocalizedString("Exit", comment: "")
    
    static let change = NSLocalizedString("Change", comment: "")
    
    static let go = NSLocalizedString("Go", comment: "")
    static let preview = NSLocalizedString("Preview", comment: "")
    static let info = NSLocalizedString("Info", comment: "")
    static let done = NSLocalizedString("Done", comment: "")
    
    static let locationPermissionDenied = NSLocalizedString("Location permission denied", comment: "")
    static let locationPermissionDeniedDescription = NSLocalizedString("Distance can't be calculated if location permission is not granted. Please enable location permission for Amazon Location from Settings", comment: "")
    static let esriDistanceError = NSLocalizedString("In DataSource Esri, all waypoints must be within 400km", comment: "")
    static let locationPermissionEnableLocationAction = NSLocalizedString("Enable Location", comment: "")
    static let locationPermissionAlertTitle = NSLocalizedString("Allow \"LocationServices\" to use your location", comment: "")
    static let locationPermissionAlertText = NSLocalizedString("Amazon Location will use your location to create a route to the selected location", comment: "")
    
    // location manager
    static let locationManagerAlertTitle = NSLocalizedString("Allow \"LocationServices\" to use your location?", comment: "")
    static let locationManagerAlertText = NSLocalizedString("We need your location to detect your location in map", comment: "")
    static let cancel = NSLocalizedString("Cancel", comment: "")
    static let settigns = NSLocalizedString("Settings", comment: "")
    static let error = NSLocalizedString("Error", comment: "")
    static let warning = NSLocalizedString("Warning", comment: "")
    static let ok = NSLocalizedString("OK", comment: "")
    
    // dispatch queue
    static let dispatchReachabilityLabel = NSLocalizedString("Reachability", comment: "")
    
    // coordinate label text
    static let coordinateLabelText = NSLocalizedString("50.54943, 30.21989", comment: "")
    static let timeLabelText = NSLocalizedString("11:22 pm", comment: "")
    
    // Tracking Simulation
    static let exitTracking = NSLocalizedString("", comment: "")
    static let exitTrackingAlertMessage = NSLocalizedString("Are you sure you want to exit simulation?", comment: "")
    
    enum AboutTab {
        static let title = NSLocalizedString("More", comment: "")
        static let cellAttributionTitle = NSLocalizedString("Attribution", comment: "")
        static let cellLegalTitle = NSLocalizedString("Terms & Conditions", comment: "")
        static let cellVersionTitle = NSLocalizedString("Version", comment: "")
        static let cellHelpTitle = NSLocalizedString("Help", comment: "")
    }
    
    enum About {
        static let descriptionTitle = NSLocalizedString("DownloadTermsConditions", comment: "")
        static let appTermsOfUse = NSLocalizedString("Terms & Conditions", comment: "")
        static let appTermsOfUseURL = termsAndConditionsURL
        static let copyright = NSLocalizedString("© \(Calendar.current.component(.year, from: Date())), Amazon Web Services, Inc. or its affiliates. All rights reserved.", comment: "")
    }
    
    enum Tracking {
        static let noTracking = NSLocalizedString("Device tracking inactive", comment: "")
        static let isTracking = NSLocalizedString("Device tracking is active", comment: "")
    }
    
    enum TabBar {
        static let explore: String = NSLocalizedString("Navigate", comment: "")
        static let tracking: String = LanguageManager.shared.localizedString(forKey: "Trackers") //NSLocalizedString("Trackers", comment: "")
        static let settings: String = NSLocalizedString("Settings", comment: "")
        static let about: String = NSLocalizedString("More", comment: "")
    }
    
    enum NotificationsInfoField {
        static let geofenceIsHidden = NSLocalizedString("geofenceIsHidden", comment: "")
        static let mapStyleIsHidden = NSLocalizedString("mapStyleIsHidden", comment: "")
        static let directionIsHidden = NSLocalizedString("directionIsHidden", comment: "")
    }
    
    static let units = NSLocalizedString("Units", comment: "")
    static let dataProvider = NSLocalizedString("Data Provider", comment: "")
    static let mapStyle = NSLocalizedString("Map style", comment: "")
    static let defaultRouteOptions = NSLocalizedString("Default route options", comment: "")
    static let partnerAttributionTitle = NSLocalizedString("Partner Attribution", comment: "")
    static let partnerAttributionHEREDescription = NSLocalizedString("© AWS, HERE", comment: "")
    static let softwareAttributionTitle = NSLocalizedString("Software Attribution", comment: "")
    static let softwareAttributionDescription = NSLocalizedString("Click learn more for software attribution", comment: "")
    static let learnMore = NSLocalizedString("Learn More", comment: "")
    static let attribution = NSLocalizedString("Attribution", comment: "")
    static let about = NSLocalizedString("More", comment: "")
    static let version = NSLocalizedString("Version", comment: "")
    static let welcomeTitle = NSLocalizedString("Welcome to\nAmazon Location Demo", comment: "")
    static let continueString = NSLocalizedString("Continue", comment: "")
    static let avoidTolls = NSLocalizedString("Avoid tolls", comment: "")
    static let avoidFerries = NSLocalizedString("Avoid ferries", comment: "")
    static let avoidUturns = NSLocalizedString("Avoid uturns", comment: "")
    static let avoidTunnels = NSLocalizedString("Avoid tunnels", comment: "")
    static let avoidDirtRoads = NSLocalizedString("Avoid dirt roads", comment: "")
    static let myLocation = NSLocalizedString("My Location", comment: "")
    static let appVersion = NSLocalizedString("App version: ", comment: "")
    static let termsAndConditions = NSLocalizedString("Terms & Conditions", comment: "")
    //static let disconnect = NSLocalizedString("Disconnect", comment: "")
    static let demo = NSLocalizedString("Demo", comment: "")
    static let routeOverview = NSLocalizedString("Route Overview", comment: "")
    
    static let viewRoute = NSLocalizedString("View Route", comment: "")
    static let hideRoute = NSLocalizedString("Hide Route", comment: "")
    
    static let trackingNotificationTitle = NSLocalizedString("Amazon Location", comment: "")

    static let arrivalCardTitle = NSLocalizedString("You've arrived!", comment: "")
    static let poiCardSchedule = NSLocalizedString("Schedule", comment: "")
    static let language = NSLocalizedString("Language", comment: "")
    static let politicalView = NSLocalizedString("Political view", comment: "")
    static let mapRepresentation = NSLocalizedString("Map representation for different countries", comment: "")
    static let mapLanguage = NSLocalizedString("Map language", comment: "")
    static let selectLanguage = NSLocalizedString("Select Language", comment: "")
    static let leaveNow = NSLocalizedString("Leave now", comment: "")
    static let leaveAt = NSLocalizedString("Leave at", comment: "")
    static let arriveBy = NSLocalizedString("Arrive by", comment: "")
    static let routeOptions = NSLocalizedString("Route Options", comment: "")
    static let options = NSLocalizedString("Options", comment: "")
    static let selected = NSLocalizedString("Selected", comment: "")
    static let routesActive = NSLocalizedString("routes active", comment: "")
    static let politicalLight = NSLocalizedString("Light", comment: "")
    static let politicalDark = NSLocalizedString("Dark", comment: "")
    
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
