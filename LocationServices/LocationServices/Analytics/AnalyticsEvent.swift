//
//  AnalyticsEvent.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

struct AnalyticsEvent {
    static let screenOpen = "SCREEN_OPEN"
    static let screenClose = "SCREEN_CLOSE"
    
    static let applicationError = "APPLICATION_ERROR"
    
    static let mapStyleChange = "MAP_STYLE_CHANGE"
    static let placeSearch = "PLACES_SEARCH"
    static let routeSearch = "ROUTE_SEARCH"
    static let routeOptionChanged = "ROUTE_OPTION_CHANGED"
    static let mapUnitChange = "MAP_UNIT_CHANGE"
    
    // Simulation
    static let startTracking = "START_TRACKING"
    static let stopTracking = "STOP_TRACKING"
    static let changeBusTrackingHistory = "CHANGE_BUS_TRACKING_HISTORY"
    static let enableNotification = "ENABLE_NOTIFICATION"
    static let disableNotification = "DISABLE_NOTIFICATION"
    static let startSimulation = "START_SIMULATION"
    
    // General
    static let languageChanged = "LANGUAGE_CHANGED"
}

struct AnalyticsAttribute {
    static let userAWSAccountConnectionStatus = "userAWSAccountConnectionStatus"
    static let userAuthenticationStatus = "userAuthenticationStatus"
    static let userAWSAccountConnectionStatusNotConnected = "Not connected"
    static let userAWSAccountConnectionStatusUnauthenticated = "Unauthenticated"
    static let screenName = "screenName"
    static let travelMode = "travelMode"
    static let distanceUnit = "distanceUnit"
    static let triggeredBy = "triggeredBy"
    static let provider = "provider"
    static let value = "value"
    static let type = "type"
    static let action = "action"
    static let avoidFerries = "AvoidFerries"
    static let avoidTolls = "AvoidTolls"
    static let avoidDirtRoads = "AvoidDirtRoads"
    static let avoidUturns = "AvoidUTurns"
    static let avoidTunnels = "AvoidTunnels"
    static let error = "error"
    static let busName = "busName"
    static let language = "language"
}

struct AnalyticsAttributeValue {
    static let explorer = "Explorer"
    static let settings = "Settings"
    static let about = "About"
    static let simulation = "Simulation"
    static let units = "Units"
    static let mapStyle = "Map style"
    static let languages = "Languages"
    static let defaultRouteOptions = "Default route options"
    static let attribution = "Attribution"
    static let version = "Version"
    static let termsConditions = "Terms & Conditions"
    static let help = "Help"
    static let placesPopup = "PLACES_POPUP"
    static let coordinates = "Coordinates"
    static let text = "Text"
    static let autocomplete = "Autocomplete"
    static let routeModule = "ROUTE_MODULE"
    static let toSearchAutocomplete = "To search autocomplete"
    static let fromSearchAutocomplete = "From search autocomplete"
}
