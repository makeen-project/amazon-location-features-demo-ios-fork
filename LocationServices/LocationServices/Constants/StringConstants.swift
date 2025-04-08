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
    
    static let errorDelegeGeofence = "Delete Geofence error:"
    static let errorUserDefaultsSave = "User Default save error:"
    static let errorCannotReadDefaultConfiguration = "Can't read default configuration from awsconfiguration.json"
    
    static let errorCellCannotBeInititalized = "Cell can't be initilized"
    static let errorJSONDecoder = "JSON Decoder Error"
    static let cellCanNotBeDequed = "Cell can't be dequed"
    
    static let errorToBeImplemented = "to be implemented"
}

// Strings
enum StringConstant {
    
    //urls
    static let baseDomain: String = "https://location.aws.com"
    static let cfTemplateURL = "https://us-west-2.console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/create?stackName=amazon-location-resources-setup&templateURL=https://amazon-location-demo-resources.s3.amazonaws.com/location-services.yaml"
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
    
    
    // strings:
    static let directions = "Directions"
    static let geofence = "Geofence"
    static let login = "Login"
    static let amazonLocationDetail = """
                                                  Add a geofence to get notified when your device
                                                  enters or exits it
                                                  """
    static let addGeofence = "Add Geofence"
    static let maybeLater = "Maybe later"
    static let checkYourConnection = "Check your internet connection and try again"
    static let amazonLocatinCannotReach = "Amazon Location can't reach the internet"
    static let navigationNotAvailable = "Navigation is not available"
    static let selectYourCurrentLocation = "Select your current location as starting point to enable navigation"
    static let cantCreateARoute = "Can't create a route"
    static let trackingDataStorage = "Tracking Data Storage"
    static let trackingDisplayData = "We only display data for the last 3 paths that you track with Amazon Location."
    static let deleteTrackingData = "Delete Tracking Data"
    static let restartAppTitle = "Restart Amazon Location App "
    static let restartAppExplanation = "Amazon Location app must be closed and reopened to apply the new configuration"
    static let terminate = "Ok"
    static let resetToDefaultConfigTitle = "Reset stack"
    static let resetToDefaultConfigExplanation = "Stack is corrupted, switching back to default stack"
    static let awsStackInvalidTitle = "Invalid AWS Stack"
    static let awsStackInvalidExplanation = "Stack is not invalid anymore or deleted, app will disconnect from AWS and restart"
    static let notAllFieldsAreConfigured = "Not all the fields are configured"
    static let incorrectIdentityPoolIdMessage = "Failed to connect AWS account, invalid IdentityPoolId or region"
    static let failedToCalculateRoute = "Failed to calculate route"
    static let geofenceNoIdentifier = "Couldn't delete geofence, no identifier exists"
    static let deleteGeofence = "Delete geofence"
    static let deleteGeofenceAlertMessage = "Are you sure you want to delete geofence?"
    static let logout = "Logout"
    static let logoutAlertMessage = "Are you sure you want to logout?"
    static let disconnectAWS = "Disconnect AWS"
    static let disconnectAWSAlertMessage = "Are you sure you want to Disconnect AWS?"
    static let noInternetConnection = "No internet connection"
    static let enableTracking = "Enable Tracker"
    static let trackers = "Trackers"
    static let trackingChangeToHere = "You can use any data provider except Esri for your asset management or device tracking use cases. If you want to use Esri for your asset management or tracking user case, please read terms and conditions."
    static let viewTermsAndConditions = "View Terms and Conditions"
    static let continueToTracker = "Continue"
    static let enableTrackingDescription = "Enabling the feature will allow you to track your device and get notified when the device enters or exits any of your geofences."
    
    static let startTracking = "Start Tracking"
    static let stopTracking = "Stop Tracking"
    static let startSimulation = "Start Simulation"
    static let simulation = "Simulation"
    static let trackersGeofences = "Trackers and Geofences"
    static let trackersGeofencesHeader = "Tracking and Geofence simulation"
    static let trackersGeofencesDetail = "Enter the tracking simulation to view the path across Vacouver streets that crosses geofences"
    static let startTrackingSimulation = "Try Trackers & Geofences Simulation"
    static let trackersDetail = "Visualize your location history on the map"
    static let geofences = "Geofences"
    static let geofencesDetail = "Define virtual boundaries around a specific area to detect entry and exit events"
    static let notifications = "Notifications"
    static let notificationsDetail = "Get geofence messages when you enter and leave locations"
    static let routesNotifications = "Routes Notifications"
    
    static let emptyTrackingHistory = "No tracking history available"
    
    static let tracker = "Tracker"
    static let entered = "Entered"
    static let exited = "Exited"
    static let exit = "Exit"
    
    static let change = "Change"
    
    static let go = "Go"
    static let preview = "Preview"
    static let info = "Info"
    static let done = "Done"
    
    static let locationPermissionDenied = "Location permission denied"
    static let locationPermissionDeniedDescription = "Distance can't be calculated if location permission is not granted. Please enable location permission for Amazon Location from Settings"
    static let esriDistanceError = "In DataSource Esri, all waypoints must be within 400km"
    static let locationPermissionEnableLocationAction = "Enable Location"
    static let locationPermissionAlertTitle = "Allow \"LocationServices\" to use your location"
    static let locationPermissionAlertText = "Amazon Location will use your location to create a route to the selected location"
    
    // location manager
    static let locationManagerAlertTitle = "Allow \"LocationServices\" to use your location?"
    static let locationManagerAlertText = "We need your location to detect your location in map"
    static let cancel = "Cancel"
    static let settigns = "Settings"
    static let error = "Error"
    static let warning = "Warning"
    static let ok = "OK"
    
    // dispatch queue
    static let dispatchReachabilityLabel = "Reachability"
    
    // coordinate label text
    static let coordinateLabelText = "50.54943, 30.21989"
    static let timeLabelText = "11:22 pm"
    
    // errors
    static let domainErrorLocalizedDescription = "The operation couldn’t be completed. (kCLErrorDomain error 0.)"
    static let testExpectationError = "expectation not matched after waiting"
    static let sessionExpiredError = "Session is expired. Please sign out and sign in back to continue access all features. Otherwise you could face unexpected behaviour in the app"
    static let greatDistanceErrorTitle = "Distance is greater than 400 km"
    static let greatDistanceErrorMessage = "Can't calculate via Esri, kindly switch to HERE provider"
    static let invalidUrlError = "URL is invalid. Can't open it"
    
    //login
    enum LoginInfo {
        enum DefaultConfig: ConstantsLoginInfoConfig {
            static let mainTitle = "Connect AWS Account"
            static let subHeader = "How to connect:"
            static let firstItemTitle = "Click here to run a CloudFormation template to securely create required resources."
            static let firstItemTitleClickablePart = "Click here"
            static let firstItemText = "You can delete these resources through the stack deletion option or ‘Manage resources’ pages in the menu on the left."
        }
        
        enum CustomConfig: ConstantsLoginInfoConfig {
            static let mainTitle = "You are connected"
            static let subHeader = "How to remove:"
            static let firstItemTitle = "Click here to remove a CloudFormation template"
            static let firstItemTitleClickablePart = "Click here"
            static let firstItemText = "It will securely create all required resources."
        }
        
        enum ClosingAppRequired {
            static let title = "Closing app required"
            static let defaultConfigSubtitle = "Amazon Location app needs to be closed in order to apply your account configuration. This means that you'll need to manually reopen the app after it closes."
            static let customConfigSubtitle = "Amazon Location app needs to be closed in order to apply default configuration. This means that you'll need to manually reopen the app after it closes."
        }
        
        static let continueToExplore = "Continue to Explore"
    }
    
    enum AboutTab {
        static let title = "About"
        static let cellAttributionTitle = "Attribution"
        static let cellLegalTitle = "Terms & Conditions"
        static let cellVersionTitle = "Version"
        static let cellHelpTitle = "Help"
    }
    
    enum About {
        static let descriptionTitle = "By downloading, installing, or using the Amazon Location Demo App, you agree to the App's Terms & Conditions for use."
        static let appTermsOfUse = "Terms & Conditions"
        static let appTermsOfUseURL = termsAndConditionsURL
        static let copyright = "© \(Calendar.current.component(.year, from: Date())), Amazon Web Services, Inc. or its affiliates. All rights reserved."
    }
    
    enum Tracking {
        static let noTracking = "Device tracking inactive"
        static let isTracking = "Device tracking is active"
    }
    
    enum TabBar {
        static let explore: String = "Navigate"
        static let tracking: String = "Trackers"
        static let geofence: String = "Geofences"
        static let settings: String = "Settings"
        static let about: String = "More"
    }
    
    enum Errors {
        static let requestCanceledCode = -999
    }
    
    enum NotificationsInfoField {
        static let geofenceIsHidden = "geofenceIsHidden"
        static let mapStyleIsHidden = "mapStyleIsHidden"
        static let directionIsHidden = "directionIsHidden"
    }
    
    static let units = "Units"
    static let dataProvider = "Data Provider"
    static let mapStyle = "Map style"
    static let resetPassword = "Reset password"
    static let connectYourAWSAccount = "Connect your AWS Account"
    static let defaultRouteOptions = "Default route options"
    static let partnerAttributionTitle = "Partner Attribution"
    static let partnerAttributionESRIDescription = "Esri, HERE, Garmin, FAO, NOAA, USGS, © OpenStreetMap contributors, and the GIS User Community"
    static let partnerAttributionHEREDescription = "© AWS, HERE"
    static let softwareAttributionTitle = "Software Attribution"
    static let softwareAttributionDescription = "Click learn more for software attribution"
    static let learnMore = "Learn More"
    static let attribution = "Attribution"
    static let about = "About"
    static let version = "Version"
    static let welcomeTitle = "Welcome to\nAmazon Location Demo"
    static let continueString = "Continue"
    static let avoidTolls = "Avoid tolls"
    static let avoidFerries = "Avoid ferries"
    static let avoidUturns = "Avoid uturns"
    static let avoidTunnels = "Avoid tunnels"
    static let avoidDirtRoads = "Avoid dirt roads"
    static let myLocation = "My Location"
    static let appVersion = "App version: "
    static let termsAndConditions = "Terms & Conditions"
    static let disconnect = "Disconnect"
    static let demo = "Demo"
    static let routeOverview = "Route Overview"
    
    static let loginVcTitle = "AWS CloudFormation"
    static let trackingHistory = "Tracking History"
    static let viewRoute = "View Route"
    static let hideRoute = "Hide Route"
    
    static let trackingNotificationTitle = "Amazon Location"
}

protocol ConstantsLoginInfoConfig {
    static var mainTitle: String { get }
    static var mainSubtitle: String { get }
    static var subHeader: String { get }
    static var firstNumber: String { get }
    static var secondNumber: String { get }
    static var thirdNumber: String { get }
    static var firstItemTitle: String { get }
    static var firstItemTitleClickablePart: String { get }
    static var firstItemText: String { get }
    static var secondItemTitle: String { get }
    static var secondItemText: String { get }
    static var learnMoreURL: String { get }
    static var secondItemTextClickablePart: String { get }
    static var thirdItemTitle: String { get }
    static var thirdItemText: String { get }
}

extension ConstantsLoginInfoConfig {
    static var mainSubtitle: String { "Connect your AWS account to enable Geofences and Trackers. This will ensure your tracking and geofencing data is only stored in your account. After you log in, all features of the Demo App will run using resources you deploy in your AWS account. Log out if you wish to continue running the Demo App using resources in AWS’s demo app account." }
    static var firstNumber: String { "1" }
    static var secondNumber: String { "2" }
    static var thirdNumber: String { "3" }
    static var learnMoreURL: String { StringConstant.helpURL }
    static var secondItemTitle: String { "Connect the demo app with the recently created AWS resources by copying in input fields." }
    static var secondItemText: String { "From your CloudFormation output section copy the corresponding named values as reflected in the right section form (IdentityPoolId etc.). Learn more" }
    static var secondItemTextClickablePart: String { "Learn more" }
    static var thirdItemTitle: String { "Login using the generated user credentials." }
    static var thirdItemText: String { "Now you should be able to use the geofences and trackers features using data stored in your account." }
}
