//
//  StringConstants.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

// Strings
enum StringConstant {
    
    static func getLocalizedString(_ key: String) -> String {
        return LanguageManager.shared.localizedString(forKey: key)
    }
    
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
    
    enum AboutTab {
        static var title: String { getLocalizedString("more") }
        static var cellAttributionTitle: String { getLocalizedString("attribution") }
        static var cellLegalTitle: String { getLocalizedString("termsConditions") }
        static var cellVersionTitle: String { getLocalizedString("version") }
        static var cellHelpTitle: String { getLocalizedString("help") }
    }
    
    enum About {
        static var downloadTermsTitle: String { getLocalizedString("downloadTermsTitle") }
        static var appTermsOfUse: String { getLocalizedString("termsConditions") }
        static var appTermsOfUseURL = termsAndConditionsURL
        static var copyright: String { return "© \(Calendar.current.component(.year, from: Date())) \(getLocalizedString("copyright"))" }
    }
    
    enum Tracking {
        static var noTracking: String { getLocalizedString("noTracking") }
        static var isTracking: String { getLocalizedString("isTracking") }
    }
    
    enum TabBar {
        static var navigate: String { getLocalizedString("navigate") }
        static var tracking: String { getLocalizedString("trackers") }
        static var settings: String { getLocalizedString("settings") }
        static var more: String { getLocalizedString("more") }
    }
    
    enum NotificationsInfoField {
        static var geofenceIsHidden: String { "geofenceIsHidden" }
        static var mapStyleIsHidden: String { "mapStyleIsHidden" }
        static var directionIsHidden: String { "directionIsHidden" }
    }
    
    static var greatDistanceErrorTitle: String { getLocalizedString("greatDistanceErrorTitle") }
    static var greatDistanceErrorMessage: String { getLocalizedString("greatDistanceErrorMessage") }
    static var invalidUrlError: String { getLocalizedString("invalidUrlError") }
    static var directions: String { getLocalizedString("directions") }
    static var maybeLater: String { getLocalizedString("maybeLater") }
    static var checkYourConnection: String { getLocalizedString("checkYourConnection") }
    static var amazonLocatinCannotReach: String { getLocalizedString("amazonLocatinCannotReach") }
    static var terminate: String { getLocalizedString("ok") }
    static var failedToCalculateRoute: String { getLocalizedString("failedToCalculateRoute") }
    static var noInternetConnection: String { getLocalizedString("noInternetConnection") }
    static var trackers: String { getLocalizedString("trackers") }
    static var enableTrackingDescription: String { getLocalizedString("enableTrackingDescription") }
    static var startTracking: String { getLocalizedString("startTracking") }
    static var stopTracking: String { getLocalizedString("stopTracking") }
    static var startSimulation: String { getLocalizedString("startSimulation") }
    static var simulation: String { getLocalizedString("simulation") }
    static var trackersGeofences: String { getLocalizedString("trackersGeofences") }
    static var trackersGeofencesHeader: String { getLocalizedString("trackersGeofencesHeader") }
    static var trackersGeofencesDetail: String { getLocalizedString("trackersGeofencesDetail") }
    static var startTrackingSimulation: String { getLocalizedString("startSimulation") }
    static var trackersDetail: String { getLocalizedString("trackersDetail") }
    static var geofences: String { getLocalizedString("geofences") }
    static var geofencesDetail: String { getLocalizedString("geofencesDetail") }
    static var notifications: String { getLocalizedString("notifications") }
    static var notificationsDetail: String { getLocalizedString("notificationsDetail") }
    static var routesNotifications: String { getLocalizedString("routesNotifications") }
    static var tracker: String { getLocalizedString("trackers") }
    static var entered: String { getLocalizedString("entered") }
    static var exited: String { getLocalizedString("exited") }
    static var exit: String { getLocalizedString("exit") }
    static var change: String { getLocalizedString("change") }
    static var go: String { getLocalizedString("go") }
    static var preview: String { getLocalizedString("preview") }
    static var done: String { getLocalizedString("done") }
    static var search: String { getLocalizedString("search") }
    static var searchDestination: String { getLocalizedString("searchDestination") }
    static var searchStartingPoint: String { getLocalizedString("searchStartingPoint") }
    static var noMatchingPlacesFound: String { getLocalizedString( "noMatchingPlacesFound") }
    static var searchSpelledCorrectly: String { getLocalizedString( "searchSpelledCorrectly") }
    static var locationPermissionDenied: String { getLocalizedString("locationPermissionDenied") }
    static var locationPermissionDeniedDescription: String { getLocalizedString("locationPermissionDeniedDescription") }
    static var locationPermissionEnableLocationAction: String { getLocalizedString("enableLocation") }
    static var locationPermissionAlertTitle: String { getLocalizedString("allowLocationServices") }
    static var locationPermissionAlertText: String { getLocalizedString("amazonLocationRoute") }
    static var locationManagerAlertTitle: String { getLocalizedString("allowLocationServices") }
    static var locationManagerAlertText: String { getLocalizedString("locationDetectionExplanation") }
    static var cancel: String { getLocalizedString("cancel") }
    static var settigns: String { getLocalizedString("settings") }
    static var error: String { getLocalizedString("error") }
    static var warning: String { getLocalizedString("warning") }
    static var ok: String { getLocalizedString("ok") }
    static var dispatchReachabilityLabel: String { "Reachability" }
    static var exitTrackingAlertMessage: String { getLocalizedString("exitTrackingAlertMessage") }
    static var units: String { getLocalizedString("units") }
    static var mapStyle: String { getLocalizedString("mapStyle") }
    static var defaultRouteOptions: String { getLocalizedString("defaultRouteOptions") }
    static var partnerAttributionTitle: String { getLocalizedString("partnerAttributionTitle") }
    static var partnerAttributionHEREDescription: String { return "© AWS, HERE" }
    static var softwareAttributionTitle: String { getLocalizedString("softwareAttributionTitle") }
    static var softwareAttributionDescription: String { getLocalizedString("softwareAttributionDescription") }
    static var learnMore: String { getLocalizedString("learnMore") }
    static var attribution: String { getLocalizedString("attribution") }
    static var more: String { getLocalizedString("more") }
    static var version: String { getLocalizedString("version") }
    static var welcomeTitle: String { getLocalizedString("welcomeTitle") }
    static var continueString: String { getLocalizedString("continue") }
    static var avoidTolls: String { getLocalizedString("avoidTolls") }
    static var avoidFerries: String { getLocalizedString("avoidFerries") }
    static var avoidUturns: String { getLocalizedString("avoidUturns") }
    static var avoidTunnels: String { getLocalizedString("avoidTunnels") }
    static var avoidDirtRoads: String { getLocalizedString("avoidDirtRoads") }
    static var myLocation: String { getLocalizedString("myLocation") }
    static var appVersion: String { getLocalizedString("appVersion") }
    static var termsAndConditions: String { getLocalizedString("termsConditions") }
    static var demo: String { getLocalizedString("demo") }
    static var routeOverview: String { getLocalizedString("routeOverview") }
    static var viewRoute: String { getLocalizedString("viewRoute") }
    static var hideRoute: String { getLocalizedString("hideRoute") }
    static var trackingNotificationTitle: String { getLocalizedString("amazonLocation") }
    static var arrivalCardTitle: String { getLocalizedString("arrivalCardTitle") }
    static var poiCardSchedule: String { getLocalizedString("schedule") }
    static var language: String { getLocalizedString("language") }
    static var politicalView: String { getLocalizedString("politicalView") }
    static var mapRepresentation: String { getLocalizedString("mapRepresentation") }
    static var mapLanguage: String { getLocalizedString("mapLanguage") }
    static var selectLanguage: String { getLocalizedString("Select Language") }
    static var leaveNow: String { getLocalizedString("leaveNow") }
    static var leaveAt: String { getLocalizedString("leaveAt") }
    static var arriveBy: String { getLocalizedString("arriveBy") }
    static var routeOptions: String { getLocalizedString("routeOptions") }
    static var options: String { getLocalizedString("options") }
    static var selected: String { getLocalizedString("selected") }
    static var routesActive: String { getLocalizedString("routesActive") }
    static var politicalLight: String { getLocalizedString("light") }
    static var politicalDark: String { getLocalizedString("dark") }
    static var automaticUnit: String { getLocalizedString("automatic") }
    static var imperialUnit: String { getLocalizedString("imperial") }
    static var metricUnit: String { getLocalizedString("metric") }
    static var imperialSubtitle: String { getLocalizedString("imperialSubtitle") }
    static var metricSubtitle: String { getLocalizedString("metricSubtitle") }
    static var light: String { getLocalizedString("light") }
    static var dark: String { getLocalizedString("dark") }
    static var noPoliticalView: String { getLocalizedString("noPoliticalView") }
    static var argentinaPoliticalView: String { getLocalizedString("argentinaPoliticalView") }
    static var cyprusPoliticalView: String { getLocalizedString("cyprusPoliticalView") }
    static var egyptPoliticalView: String { getLocalizedString("egyptPoliticalView") }
    static var georgiaPoliticalView: String { getLocalizedString("georgiaPoliticalView") }
    static var greecePoliticalView: String { getLocalizedString("greecePoliticalView") }
    static var indiaPoliticalView: String { getLocalizedString("indiaPoliticalView") }
    static var kenyaPoliticalView: String { getLocalizedString("kenyaPoliticalView") }
    static var moroccoPoliticalView: String { getLocalizedString("moroccoPoliticalView") }
    static var palestinePoliticalView: String { getLocalizedString("palestinePoliticalView") }
    static var russiaPoliticalView: String { getLocalizedString("russiaPoliticalView") }
    static var sudanPoliticalView: String { getLocalizedString("sudanPoliticalView") }
    static var serbiaPoliticalView: String { getLocalizedString("serbiaPoliticalView") }
    static var surinamePoliticalView: String { getLocalizedString("surinamePoliticalView") }
    static var syriaPoliticalView: String { getLocalizedString("syriaPoliticalView") }
    static var turkeyPoliticalView: String { getLocalizedString("turkeyPoliticalView") }
    static var tanzaniaPoliticalView: String { getLocalizedString("tanzaniaPoliticalView") }
    static var uruguayPoliticalView: String { getLocalizedString("uruguayPoliticalView") }
    static var m: String { getLocalizedString("m") }
    static var km: String { getLocalizedString("km") }
    static var mi: String { getLocalizedString("mi") }
    static var min: String { getLocalizedString("min") }
    static var hr: String { getLocalizedString("hr") }
    static var sec: String { getLocalizedString("sec") }
    static var car: String { getLocalizedString("car") }
    static var pedestrian: String { getLocalizedString("pedestrian") }
    static var scooter: String { getLocalizedString("scooter") }
    static var truck: String { getLocalizedString("truck") }
    static var region: String { getLocalizedString("region") }
    static var euWest1: String = "eu-west-1"
    static var usEast1: String = "us-east-1"
    static var euWest1FullName: String = "Europe (Ireland) \(euWest1)"
    static var usEast1FullName: String = "Us-East (N. Virginia) \(usEast1)"
    static var euWest1ListTitle: String = "Europe"
    static var usEast1ListTitle: String = "Us-East"
}
