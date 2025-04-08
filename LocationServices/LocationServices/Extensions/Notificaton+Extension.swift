//
//  Notificaton+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

extension Notification {
    //TODO: All notification Hard coded values will be moved here
    static let geofenceEditScene = Notification.Name("GeofenceEditSceneNotification")
    static let refreshMapView = Notification.Name("RefreshMapView")
    static let addGeofenceCircle = Notification.Name("GeofenceCircleNotification")
    static let deleteGeofenceData = Notification.Name("GeofenceDeleteNotification")
    static let geofenceMapLayerUpdate = Notification.Name("geofenceMapLayerUpdate")
    static let updateMapLayerItems = Notification.Name("updateMaplayerItems")
    static let resetMapLayerItems = Notification.Name("resetMaplayerItems")
    static let updateTrackingHeader = Notification.Name("UpdateTrackingHeader")
    static let updateStartTrackingButton = Notification.Name("UpdateStartTrackingButton")
    static let updateTrackingHistory = Notification.Name("updateTrackingHistory")
    static let updateSearchTextBarIcon = Notification.Name("updateSearchTextBarIcon")
    static let updateSearchTextBarIconLogoutState = Notification.Name("updateSearchTextBarIconLogoutState")
    static let deselectMapAnnotation = Notification.Name("DeselectMapAnnotation")
    static let refreshGeofence = Notification.Name("RefreshGeofence")
    static let geofenceAdded = Notification.Name("GeofenceDeleted")
    static let enableGeofenceDrag = Notification.Name("EnableGeofenceDrag")
    static let trackingEvent = Notification.Name("TrackingEvent")
    static let userLocation = Notification.Name("UserLocation")
    static let selectedPlace = Notification.Name("SelectedPlace")
    static let wasResetToDefaultConfig = Notification.Name("WasResetToDefaultConfig")
    static let tabSelected = Notification.Name("TabSelected")
    static let grantedLocationPermissions = Notification.Name("GrantedLocationPermissions")
    static let validateMapColor = Notification.Name("ValidateMapColor")
    static let validatePoliticalView = Notification.Name("ValidatePoliticalView")
    static let focusOnLocation = Notification.Name("FocusOnLocation")
    
    static let searchAppearanceChanged = Notification.Name("SearchAppearanceChanged")
    static let trackingAppearanceChanged = Notification.Name("TrackingAppearanceChanged")
    static let geofenceAppearanceChanged = Notification.Name("GeofenceAppearanceChanged")
    
    static let authorizationStatusChanged = Notification.Name("AuthorizationStatusChanged")
    static let exploreActionButtonsVisibilityChanged = Notification.Name("ExploreActionButtonsVisibilityChanged")
    static let geofenceRadiusDragged = Notification.Name("GeofenceRadiusDragged")
    
    static let dismissTrackingSimulation = Notification.Name("DismissTrackingSimulation")
    static let shownSearchResults = Notification.Name("ShownSearchResults")
    static let poiCardDismissed = Notification.Name("POICardDismissed")
    static let directionViewDismissed = Notification.Name("DirectionViewDismissed")
    static let navigationViewDismissed = Notification.Name("NavigationViewDismissed")
    static let updateMapViewButtons = Notification.Name("UpdateMapViewButtons")
    static let updateMapViewValues = Notification.Name("UpdateMapViewValues")
    static let navigationStepsUpdated = Notification.Name("NavigationStepsUpdated")
    static let navigationSteps = Notification.Name("NavigationSteps")
    static let directionLineString = Notification.Name("DirectionLineString")
    
}
