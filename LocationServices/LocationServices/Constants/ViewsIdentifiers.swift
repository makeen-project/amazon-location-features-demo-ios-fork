//
//  ViewsIdentifiers.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

struct ViewsIdentifiers {
    
    struct General {
        static let mapRendering = "MapRendering"
        static let mapRendered = "MapRendered"
        static let mapHelper = "MapHelper"
        static let welcomeContinueButton = "WelcomeContinueButton"
        static let userLocationAnnotation = "UserLocationAnnotation"
        static let locateMeButton = "LocateMeButton"
        static let exploreTabBarButton = "Navigate"
        static let settingsTabBarButton = "Settings"
        static let trackingTabBarButton = "Tracking"
        static let aboutTabBarButton = "More"
        static let sideBarButton = "SideBarButton"
        static let fullScreenButton = "FullScreenButton"
        static let mapStyles = "MapStyles"
        static let routingButton = "RoutingButton"
        static let closeButton = "CloseButton"
        static let imageAnnotationView = "ImageAnnotationView"
        static let bottomGrabberView = "BottomGrabberView"
        static let sideBarTableView = "SideBarTableView"
        static let mapStyleRow = "MapStyleRow"
        static let politicalViewButton = "politicalViewButton"
        static let politicalViewTable = "politicalViewTable"
        static let politicalViewCell = "politicalViewCell"
        static let politicalViewSubtitle = "politicalViewSubtitle"
        static let politicalViewCloseButton = "politicalViewCloseButton"
        
        static let languageViewTable = "languageViewTable"
        static let languageViewCell = "languageViewCell"
        static let languageViewButton = "languageViewButton"
        static let languageViewSubtitle = "languageViewSubtitle"
        static let languageViewCloseButton = "politicalViewCloseButton"
    }
    
    struct Explore {
        static let exploreView = "ExploreView"
    }
    
    struct Search {
        static let searchRootView = "SearchRootView"
        static let searchBar = "SearchBar"
        static let searchTextField = "SearchTextField"
        static let searchCancelButton = "SearchCancelButton"
        static let noResultsView = "NoResultsView"
        static let cellAddressLabel = "CellAddressLabel"
        static let tableView = "SearchTableView"
    }
    
    struct Routing {
        static let departureTextField = "DepartureTextField"
        static let destinationTextField = "DestinationTextField"
        static let swapButton = "SwapButton"
        
        static let routeOptionsVisibilityButton = "RouteOptionsVisibilityButton"
        static let routeOptionsContainer = "RouteOptionsContainer"
        static let leaveOptionsContainer = "LeaveOptionsContainer"
        static let avoidTollsOptionContainer = "AvoidTollsOptionContainer"
        static let avoidFerriesOptionContainer = "AvoidFerriesOptionContainer"
        static let avoidUturnsOptionContainer = "AvoidUturnsOptionContainer"
        static let avoidTunnelsOptionContainer = "AvoidTunnelsOptionContainer"
        static let avoidDirtRoadsOptionContainer = "AvoidDirtRoadsOptionContainer"
        static let routeOptionSwitchButton = "RouteOptionSwitchButton"
        
        static let routeTypesContainer = "RouteTypesContainer"
        
        static let carContainer = "CarContainer"
        static let pedestrianContainer = "PedestrianContainer"
        static let scooterContainer = "ScooterContainer"
        static let truckContainer = "TruckContainer"
        
        static let routeMainContainer = "RouteMainContainer"
        static let routeLeftContainer = "RouteLeftContainer"
        static let routeEstimatedTime = "RouteEstimatedTime"
        static let routeEstimatedDistance = "RouteEstimatedDistance"
        static let routeEstimatedLeave = "RouteEstimatedLeave"
        
        static let navigateButton = "NavigateButton"
        static let tableView = "DirectionsTableView"
    }
    
    struct Navigation {
        static let navigationRootView = "NavigationRootView"
        static let navigationExitButton = "NavigationExitButton"
        static let navigationRoutesButton = "NavigationRoutesButton"
    }
    
    struct PoiCard {
        static let poiCardView = "POICardView"
        static let travelTimeLabel = "TravelTimeLabel"
        static let directionButton = "DirectionButton"
    }
    
    struct ArrivalCard {
        static let arrivalCardView = "ArrivalCardView"
        static let arrivalLabel = "ArrivalLabel"
        static let doneButton = "DoneButton"
    }

    struct AWSConnect {
        static let awsConnectScrollView = "AWSConnectScrollView"
        static let awsConnectGradientView = "AWSConnectGradientView"
        static let awsConnectTitleLabel = "AWSConnectTitleLabel"
        static let identityPoolTextField = "IdentityPoolTextField"
        static let userDomainTextField = "UserDomainTextField"
        static let userPoolClientTextField = "UserPoolClientTextField"
        static let userPoolTextField = "UserPoolTextField"
        static let webSocketURLTitleTextField = "WebSocketURLTitleTextField"
        static let connectButton = "ConnectButton"
        static let disconnectButton = "DisconnectButton"
        static let signInButton = "SignInButton"
        static let signOutButton = "SignOutButton"
    }
    
    struct Settings {
        static let routeOptionCell = StringConstant.defaultRouteOptions
        static let dataProviderCell = StringConstant.dataProvider
        static let mapStyleCell = StringConstant.mapStyle
    }
    
    struct Geofence {
        static let addGeofenceButtonEmptyList = "AddGeofenceButtonEmptyList"
        static let addGeofenceButton = "AddGeofenceButton"
        static let geofenceTableView = "GeofenceTableView"
        static let deleteGeofenceButton = "DeleteGeofenceButton"
        static let geofenceNameTextField = "GeofenceNameTextField"
        static let saveGeofenceButton = "SaveGeofenceButton"
        static let searchGeofenceTextField = "SearchGeofenceTextField"
        static let radiusGeofenceSliderField = "RadiusGeofenceSliderField"
        static let addGeofenceTableView = "AddGeofenceTableView"
    }
    
    struct Tracking {
        static let startTrackingSimulationButton = "StartTrackingSimulationButton"
        
        static let enableTrackingButton = "EnableTrackingButton"
        static let trackingHeaderView = "TrackingHeaderView"
        static let trackingActionButton = "TrackingActionButton"
        static let trackingPointsTableView  = "TrackingPointsTableView"
        static let trackingStartedLabel = "TrackingStartedLabel"
        static let trackingStoppedLabel = "TrackingStoppedLabel"
        static let trackingAnnotationImage = "TrackingAnnotationImage"
        static let trackingSimulationScrollView  = "TrackingSimulationScrollView"
        
        static let trackingSimulationStartedLabel = "TrackingSimulationStartedLabel"
        static let trackingRoutesExpandButton = "trackingRoutesExpandButton"
        static let trackingPointsExpandButton = "trackingPointsExpandButton"
    }
}
