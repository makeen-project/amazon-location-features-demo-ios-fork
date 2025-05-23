//
//  StringConstants.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation


extension String {
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
    
    static var greatDistanceErrorTitle: String {  LanguageManager.shared.localizedString(forKey:"Distance is greater than 400 km") }
       static var greatDistanceErrorMessage: String {  LanguageManager.shared.localizedString(forKey:"Can't calculate via Esri, kindly switch to HERE provider") }
       static var invalidUrlError: String {  LanguageManager.shared.localizedString(forKey:"URL is invalid. Can't open it") }
       
       // strings:
       static var directions: String {  LanguageManager.shared.localizedString(forKey:"Directions") }
       static var maybeLater: String {  LanguageManager.shared.localizedString(forKey:"Maybe later") }
       static var checkYourConnection: String {  LanguageManager.shared.localizedString(forKey:"Check your internet connection and try again") }
       static var amazonLocatinCannotReach: String {  LanguageManager.shared.localizedString(forKey:"Amazon Location can't reach the internet") }
       static var terminate: String {  LanguageManager.shared.localizedString(forKey:"Ok") }
       static var failedToCalculateRoute: String {  LanguageManager.shared.localizedString(forKey:"Failed to calculate route") }
       static var noInternetConnection: String {  LanguageManager.shared.localizedString(forKey:"No internet connection") }
       static var trackers: String {  LanguageManager.shared.localizedString(forKey:"Trackers") }
       static var trackingChangeToHere: String {  LanguageManager.shared.localizedString(forKey:"You can use any data provider except Esri for your asset management or device tracking use cases. If you want to use Esri for your asset management or tracking user case, please read terms and conditions.") }
       static var enableTrackingDescription: String {  LanguageManager.shared.localizedString(forKey:"Enabling the feature will allow you to track your device and get notified when the device enters or exits any of your geofences.") }
       
       static var startTracking: String {  LanguageManager.shared.localizedString(forKey:"Start Tracking") }
       static var stopTracking: String {  LanguageManager.shared.localizedString(forKey:"Stop Tracking") }
       static var startSimulation: String {  LanguageManager.shared.localizedString(forKey:"Try Trackers & Geofences simulation") }
       static var simulation: String {  LanguageManager.shared.localizedString(forKey:"Simulation") }
       static var trackersGeofences: String {  LanguageManager.shared.localizedString(forKey:"Trackers and Geofences") }
       static var trackersGeofencesHeader: String {  LanguageManager.shared.localizedString(forKey:"Tracking and Geofence simulation") }
       static var trackersGeofencesDetail: String {  LanguageManager.shared.localizedString(forKey:"Enter the Trackers simulation to view the path across Vancouver streets that crosses Geofences") }
       static var startTrackingSimulation: String {  LanguageManager.shared.localizedString(forKey:"Try Trackers & Geofences Simulation") }
       static var trackersDetail: String {  LanguageManager.shared.localizedString(forKey:"Visualize your location history on the map") }
       static var geofences: String {  LanguageManager.shared.localizedString(forKey:"Geofences") }
       static var geofencesDetail: String {  LanguageManager.shared.localizedString(forKey:"Define virtual boundaries around a specific area to detect entry and exit events") }
       static var notifications: String {  LanguageManager.shared.localizedString(forKey:"Notifications") }
       static var notificationsDetail: String {  LanguageManager.shared.localizedString(forKey:"Get geofence messages when you enter and leave locations") }
       static var routesNotifications: String {  LanguageManager.shared.localizedString(forKey:"Routes notifications") }
       
       static var emptyTrackingHistory: String {  LanguageManager.shared.localizedString(forKey:"No tracking history available") }
       
       static var tracker: String {  LanguageManager.shared.localizedString(forKey:"Tracker") }
       static var entered: String {  LanguageManager.shared.localizedString(forKey:"Entered") }
       static var exited: String {  LanguageManager.shared.localizedString(forKey:"Exited") }
       static var exit: String {  LanguageManager.shared.localizedString(forKey:"Exit") }
       
       static var change: String {  LanguageManager.shared.localizedString(forKey:"Change") }
       
       static var go: String {  LanguageManager.shared.localizedString(forKey:"Go") }
       static var preview: String {  LanguageManager.shared.localizedString(forKey:"Preview") }
       static var info: String {  LanguageManager.shared.localizedString(forKey:"Info") }
       static var done: String {  LanguageManager.shared.localizedString(forKey:"Done") }
       
       static var search: String {  LanguageManager.shared.localizedString(forKey:"Search") }
       static var searchDestination: String {  LanguageManager.shared.localizedString(forKey:"Search Destination") }
       static var searchStartingPoint: String {  LanguageManager.shared.localizedString(forKey:"Search starting Point") }
       static var noMatchingPlacesFound: String {  LanguageManager.shared.localizedString(forKey: "No matching places found") }
       static var searchSpelledCorrectly: String {  LanguageManager.shared.localizedString(forKey: "Make sure your search is spelled correctly. Try adding a city, postcode, or country.") }
       
       static var locationPermissionDenied: String {  LanguageManager.shared.localizedString(forKey:"Location permission denied") }
       static var locationPermissionDeniedDescription: String {  LanguageManager.shared.localizedString(forKey:"Distance can't be calculated if location permission is not granted. Please enable location permission for Amazon Location from Settings") }
       static var esriDistanceError: String {  LanguageManager.shared.localizedString(forKey:"In DataSource Esri, all waypoints must be within 400km") }
       static var locationPermissionEnableLocationAction: String {  LanguageManager.shared.localizedString(forKey:"Enable Location") }
       static var locationPermissionAlertTitle: String {  LanguageManager.shared.localizedString(forKey:"Allow \"LocationServices\" to use your location") }
       static var locationPermissionAlertText: String {  LanguageManager.shared.localizedString(forKey:"Amazon Location will use your location to create a route to the selected location") }
       
       // location manager
       static var locationManagerAlertTitle: String {  LanguageManager.shared.localizedString(forKey:"Allow \"LocationServices\" to use your location?") }
       static var locationManagerAlertText: String {  LanguageManager.shared.localizedString(forKey:"We need your location to detect your location in map") }
       static var cancel: String {  LanguageManager.shared.localizedString(forKey:"Cancel") }
       static var settigns: String {  LanguageManager.shared.localizedString(forKey:"Settings") }
       static var error: String {  LanguageManager.shared.localizedString(forKey:"Error") }
       static var warning: String {  LanguageManager.shared.localizedString(forKey:"Warning") }
       static var ok: String {  LanguageManager.shared.localizedString(forKey:"OK") }
       
       // dispatch queue
       static var dispatchReachabilityLabel: String {  LanguageManager.shared.localizedString(forKey:"Reachability") }
       
       // coordinate label text
       static var coordinateLabelText: String {  LanguageManager.shared.localizedString(forKey:"50.54943, 30.21989") }
       static var timeLabelText: String {  LanguageManager.shared.localizedString(forKey:"11:22 pm") }
       
       // Tracking Simulation
       static var exitTracking: String {  LanguageManager.shared.localizedString(forKey:"") }
       static var exitTrackingAlertMessage: String {  LanguageManager.shared.localizedString(forKey:"Are you sure you want to exit simulation?") }
       
       enum AboutTab {
           static var title: String {  LanguageManager.shared.localizedString(forKey:"More") }
           static var cellAttributionTitle: String {  LanguageManager.shared.localizedString(forKey:"Attribution") }
           static var cellLegalTitle: String {  LanguageManager.shared.localizedString(forKey:"Terms & Conditions") }
           static var cellVersionTitle: String {  LanguageManager.shared.localizedString(forKey:"Version") }
           static var cellHelpTitle: String {  LanguageManager.shared.localizedString(forKey:"Help") }
       }
       
       enum About {
           static var descriptionTitle: String {  LanguageManager.shared.localizedString(forKey:"DownloadTermsConditions") }
           static var appTermsOfUse: String {  LanguageManager.shared.localizedString(forKey:"Terms & Conditions") }
           static var appTermsOfUseURL = termsAndConditionsURL
           static var copyright: String {  LanguageManager.shared.localizedString(forKey:"© \(Calendar.current.component(.year, from: Date())), Amazon Web Services, Inc. or its affiliates. All rights reserved.") }
       }
       
       enum Tracking {
           static var noTracking: String {  LanguageManager.shared.localizedString(forKey:"Device tracking inactive") }
           static var isTracking: String {  LanguageManager.shared.localizedString(forKey:"Device tracking is active") }
       }
       
       enum TabBar {
           static var explore: String {  LanguageManager.shared.localizedString(forKey:"Navigate") }
           static var tracking: String {  LanguageManager.shared.localizedString(forKey: "Trackers") }
           static var settings: String {  LanguageManager.shared.localizedString(forKey:"Settings") }
           static var about: String {  LanguageManager.shared.localizedString(forKey:"More") }
       }
       
       enum NotificationsInfoField {
           static var geofenceIsHidden: String {  LanguageManager.shared.localizedString(forKey:"geofenceIsHidden") }
           static var mapStyleIsHidden: String {  LanguageManager.shared.localizedString(forKey:"mapStyleIsHidden") }
           static var directionIsHidden: String {  LanguageManager.shared.localizedString(forKey:"directionIsHidden") }
       }
       
       static var units: String {  LanguageManager.shared.localizedString(forKey:"Units") }
       static var dataProvider: String {  LanguageManager.shared.localizedString(forKey:"Data Provider") }
       static var mapStyle: String {  LanguageManager.shared.localizedString(forKey:"Map style") }
       static var defaultRouteOptions: String {  LanguageManager.shared.localizedString(forKey:"Default route options") }
       static var partnerAttributionTitle: String {  LanguageManager.shared.localizedString(forKey:"Partner Attribution") }
       static var partnerAttributionHEREDescription: String {  LanguageManager.shared.localizedString(forKey:"© AWS, HERE") }
       static var softwareAttributionTitle: String {  LanguageManager.shared.localizedString(forKey:"Software Attribution") }
       static var softwareAttributionDescription: String {  LanguageManager.shared.localizedString(forKey:"Click learn more for software attribution") }
       static var learnMore: String {  LanguageManager.shared.localizedString(forKey:"Learn More") }
       static var attribution: String {  LanguageManager.shared.localizedString(forKey:"Attribution") }
       static var about: String {  LanguageManager.shared.localizedString(forKey:"More") }
       static var version: String {  LanguageManager.shared.localizedString(forKey:"Version") }
       static var welcomeTitle: String {  LanguageManager.shared.localizedString(forKey:"Welcome to Amazon Location Demo") }
       static var continueString: String {  LanguageManager.shared.localizedString(forKey:"Continue") }
       static var avoidTolls: String {  LanguageManager.shared.localizedString(forKey:"Avoid tolls") }
       static var avoidFerries: String {  LanguageManager.shared.localizedString(forKey:"Avoid ferries") }
       static var avoidUturns: String {  LanguageManager.shared.localizedString(forKey:"Avoid U-turns") }
       static var avoidTunnels: String {  LanguageManager.shared.localizedString(forKey:"Avoid tunnels") }
       static var avoidDirtRoads: String {  LanguageManager.shared.localizedString(forKey:"Avoid dirt roads") }
       static var myLocation: String {  LanguageManager.shared.localizedString(forKey:"My Location") }
       static var appVersion: String {  LanguageManager.shared.localizedString(forKey:"App version:") }
       static var termsAndConditions: String {  LanguageManager.shared.localizedString(forKey:"Terms & Conditions") }
       static var demo: String {  LanguageManager.shared.localizedString(forKey:"Demo") }
       static var routeOverview: String {  LanguageManager.shared.localizedString(forKey:"Route Overview") }
       
       static var viewRoute: String {  LanguageManager.shared.localizedString(forKey:"View Route") }
       static var hideRoute: String {  LanguageManager.shared.localizedString(forKey:"Hide Route") }
       
       static var trackingNotificationTitle: String {  LanguageManager.shared.localizedString(forKey:"Amazon Location") }

       static var arrivalCardTitle: String {  LanguageManager.shared.localizedString(forKey:"You've arrived!") }
       static var poiCardSchedule: String {  LanguageManager.shared.localizedString(forKey:"Schedule") }
       static var language: String {  LanguageManager.shared.localizedString(forKey:"Language") }
       static var politicalView: String {  LanguageManager.shared.localizedString(forKey:"Political view") }
       static var mapRepresentation: String {  LanguageManager.shared.localizedString(forKey:"Map representation for different countries") }
       static var mapLanguage: String {  LanguageManager.shared.localizedString(forKey:"Map language") }
       static var selectLanguage: String {  LanguageManager.shared.localizedString(forKey:"Select Language") }
       static var leaveNow: String {  LanguageManager.shared.localizedString(forKey:"Leave now") }
       static var leaveAt: String {  LanguageManager.shared.localizedString(forKey:"Leave at") }
       static var arriveBy: String {  LanguageManager.shared.localizedString(forKey:"Arrive by") }
       static var routeOptions: String {  LanguageManager.shared.localizedString(forKey:"Route Options") }
       static var options: String {  LanguageManager.shared.localizedString(forKey:"Options") }
       static var selected: String {  LanguageManager.shared.localizedString(forKey:"Selected") }
       static var routesActive: String {  LanguageManager.shared.localizedString(forKey:"routes active") }
       static var politicalLight: String {  LanguageManager.shared.localizedString(forKey:"Light") }
       static var politicalDark: String {  LanguageManager.shared.localizedString(forKey:"Dark") }
       
       static var automaticUnit: String {  LanguageManager.shared.localizedString(forKey:"Automatic") }
       static var imperialUnit: String {  LanguageManager.shared.localizedString(forKey:"Imperial") }
       static var metricUnit: String {  LanguageManager.shared.localizedString(forKey:"Metric") }
       static var imperialSubtitle: String {  LanguageManager.shared.localizedString(forKey:"Miles, pounds") }
       static var metricSubtitle: String {  LanguageManager.shared.localizedString(forKey:"Kilometers, kilograms") }
    
    static var light: String {  LanguageManager.shared.localizedString(forKey:"Light") }
    static var dark: String {  LanguageManager.shared.localizedString(forKey:"Dark") }
    
    static var noPoliticalView: String {  LanguageManager.shared.localizedString(forKey:"No Political View") }
    static var argentinaPoliticalView: String {  LanguageManager.shared.localizedString(forKey:"ArgentinaPoliticalView") }
    static var cyprusPoliticalView: String {  LanguageManager.shared.localizedString(forKey:"CyprusPoliticalView") }
    static var egyptPoliticalView: String {  LanguageManager.shared.localizedString(forKey:"EgyptPoliticalView") }
    static var georgiaPoliticalView: String {  LanguageManager.shared.localizedString(forKey:"GeorgiaPoliticalView") }
    static var greecePoliticalView: String {  LanguageManager.shared.localizedString(forKey:"GreecePoliticalView") }
    static var indiaPoliticalView: String {  LanguageManager.shared.localizedString(forKey:"IndiaPoliticalView") }
    static var kenyaPoliticalView: String {  LanguageManager.shared.localizedString(forKey:"KenyaPoliticalView") }
    static var moroccoPoliticalView: String {  LanguageManager.shared.localizedString(forKey:"MoroccoPoliticalView") }
    static var palestinePoliticalView: String {  LanguageManager.shared.localizedString(forKey:"PalestinePoliticalView") }
    static var russiaPoliticalView: String {  LanguageManager.shared.localizedString(forKey:"RussiaPoliticalView") }
    static var sudanPoliticalView: String {  LanguageManager.shared.localizedString(forKey:"SudanPoliticalView") }
    static var serbiaPoliticalView: String {  LanguageManager.shared.localizedString(forKey:"SerbiaPoliticalView") }
    static var surinamePoliticalView: String {  LanguageManager.shared.localizedString(forKey:"SurinamePoliticalView") }
    static var syriaPoliticalView: String {  LanguageManager.shared.localizedString(forKey:"SyriaPoliticalView") }
    static var turkeyPoliticalView: String {  LanguageManager.shared.localizedString(forKey:"TurkeyPoliticalView") }
    static var tanzaniaPoliticalView: String {  LanguageManager.shared.localizedString(forKey:"TanzaniaPoliticalView") }
    static var uruguayPoliticalView: String {  LanguageManager.shared.localizedString(forKey:"UruguayPoliticalView") }
    
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
