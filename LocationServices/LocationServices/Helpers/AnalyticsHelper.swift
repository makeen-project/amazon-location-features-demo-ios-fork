//
//  AnalyticsHelper.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSPinpoint
import AmazonLocationiOSAuthSDK
import AWSSDKIdentity

enum AnalyticsSessionStatus: String {
    case notCreated
    case inProgress
    case created
}

class AnalyticsSessionData {
    var id: String?
    var startTimeStamp: String? = nil
    var creationStatus: AnalyticsSessionStatus = .notCreated
}

enum AnalyticsEventType {
    case sessionStart
    case sessionStop
    case sessionEnd

    var eventType: String {
        switch self {
        case .sessionStart: return "_session.start"
        case .sessionStop: return "_session.stop"
        case .sessionEnd: return "_session.end"
        }
    }
}

class EventInput {
    var eventType: String
    var attributes: [String: String]
    var session: EventSession?
    
    init(eventType: String, attributes: [String : String], session: EventSession? = nil) {
        self.eventType = eventType
        self.attributes = attributes
        self.session = session
    }
    
    func toEvent(sessionId: String, sessionStart: String) -> PinpointClientTypes.Event {
        PinpointClientTypes.Event(
            attributes: attributes, eventType: eventType,
            session: PinpointClientTypes.Session(id: sessionId, startTimestamp: sessionStart), timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }
}

class EventSession {
    var id: String
    var startTimeStamp: String
    var stopTimeStamp: String
    
    init(id: String, startTimeStamp: String, stopTimeStamp: String) {
        self.id = id
        self.startTimeStamp = startTimeStamp
        self.stopTimeStamp = stopTimeStamp
    }
}

struct EventType {
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
    static let avoidUTurns = "AvoidUTurns"
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


actor AnalyticsHelper {
    static let shared =  AnalyticsHelper()
    
    private(set) var analyticsAppId: String?
    private(set) var pinpointClient: AWSPinpoint.PinpointClient?
    private(set) var platFormType = "iOS"
    private(set) var analyticsIdentityPoolId: String?
    private(set) var endPointId: String = UserDefaultsHelper.get(for: String.self, key: .analyticsEndpointId) ?? ""
    private(set) var sessionData: AnalyticsSessionData = AnalyticsSessionData()
    private(set) var userId: String? = nil
    
    func initialise() async throws {
        guard let awsConfig = GeneralHelper.getAWSConfigurationModel() else {
            throw NSError(domain: "MissingAWSConfiguration", code: 0)
        }
        self.analyticsAppId = awsConfig.analyticsAppId
        self.analyticsIdentityPoolId = awsConfig.analyticsIdentityPoolId
        let region = AmazonLocationRegion.toRegionString(
            identityPoolId: awsConfig.analyticsIdentityPoolId
        )
        
        let analyticsProvider = AnalyticsCredentialsProvider(
            identityPoolId: awsConfig.analyticsIdentityPoolId,
            region: region
        )
        
        try await analyticsProvider.refreshCognitoCredentials()
            
        var resolver: StaticAWSCredentialIdentityResolver?

        if let credentials = analyticsProvider.getCognitoCredentials() {
            let credentialsIdentity = AWSCredentialIdentity(
                accessKey: credentials.accessKeyId,
                secret: credentials.secretKey,
                expiration: credentials.expiration,
                sessionToken: credentials.sessionToken
            )
            resolver = try StaticAWSCredentialIdentityResolver(
                credentialsIdentity
            )
        }
            
        let config = try await PinpointClient.PinpointClientConfiguration(
            awsCredentialIdentityResolver: resolver,
            region: region,
            signingRegion: region
        )
        
        if (endPointId.isEmpty) {
            endPointId = UUID().uuidString
            UserDefaultsHelper.save(value: endPointId, key: .analyticsEndpointId)
        }
            
        let pinpointClient = AWSPinpoint.PinpointClient(config: config)
        self.pinpointClient = pinpointClient

    }
    
    func createOrUpdateEndpoint() async throws {
        do {
            if pinpointClient == nil {
                try await initialise()
            }
            
            let countryCode = Locale.current.region?.identifier
            userId = "AnonymousUser:\(endPointId)"
            
            let endPointRequest = PinpointClientTypes.EndpointRequest(
                demographic: PinpointClientTypes.EndpointDemographic(platform: "\(platFormType) (\(platFormType))"),
                location: PinpointClientTypes.EndpointLocation(country: countryCode),
                user: PinpointClientTypes.EndpointUser(userId: userId)
            )
            
            let input = UpdateEndpointInput(
                applicationId: analyticsAppId,
                endpointId: endPointId,
                endpointRequest: endPointRequest
            )
            
            let result = try await pinpointClient?.updateEndpoint(input: input)
            print(result?.messageBody ?? "No result")
        }
        catch {
            print(error)
            throw error
        }
    }
    
    func recordEvent(_ eventName: String, properties : [(String, String)] = []) async throws {
        if pinpointClient == nil {
            try await initialise()
        }
        
        if let appId = analyticsAppId {
            
            var events: [EventInput] = []
            
            if eventName == AnalyticsEventType.sessionStop.eventType {
                    let session = EventSession(id: sessionData.id!, startTimeStamp: sessionData.startTimeStamp!, stopTimeStamp: Date().convertDateToIsoString()!)
                events = [EventInput(eventType: AnalyticsEventType.sessionStop.eventType, attributes: [:], session: session)]
            }
            else {
                events = [EventInput(eventType: eventName, attributes: [:])]
            }
            
            let mUserId: String? = "AnonymousUser:\(endPointId)"
            
            if mUserId != userId {
                userId = mUserId
                try await createOrUpdateEndpoint()
            }
            let sessionStopEvent = events.first(where: { $0.eventType == AnalyticsEventType.sessionStop.eventType } )
            if sessionData.creationStatus == .notCreated {
                try await startSession()
            }
            
            if sessionStopEvent != nil {
                events.append(EventInput(eventType: AnalyticsEventType.sessionEnd.eventType, attributes: sessionStopEvent!.attributes))
            }
            
            var attributes: [String: String] = [:]
            
            properties.forEach { (key, value) in
                attributes[key] = value
            }
            
            attributes[AnalyticsAttribute.userAWSAccountConnectionStatus] = AnalyticsAttribute.userAWSAccountConnectionStatusNotConnected
            attributes[AnalyticsAttribute.userAuthenticationStatus] = AnalyticsAttribute.userAWSAccountConnectionStatusUnauthenticated
            
            events.forEach { event in
                event.attributes = attributes
            }

            let eventMap = Dictionary(uniqueKeysWithValues: events.map { (UUID().uuidString, $0.toEvent(sessionId: sessionData.id ?? "", sessionStart: sessionData.startTimeStamp ?? "")) })
            let endPoint = PinpointClientTypes.PublicEndpoint()

            
            let eventBatch: PinpointClientTypes.EventsBatch = PinpointClientTypes.EventsBatch(endpoint: endPoint, events: eventMap)
            let batchItem: [String: PinpointClientTypes.EventsBatch] = [endPointId: eventBatch]
            
            let eventRequest = PinpointClientTypes.EventsRequest(batchItem: batchItem)
             
            let input = PutEventsInput(
                applicationId: appId,
                eventsRequest: eventRequest
            )
            let result = try await pinpointClient?.putEvents(input: input)
            result?.eventsResponse?.results?.forEach { print($0) }
            
            if eventName == AnalyticsEventType.sessionStop.eventType {
                sessionData = AnalyticsSessionData()
            }
        }
    }
    
    func startSession() async throws {
        sessionData.creationStatus = .inProgress
        try await createOrUpdateEndpoint()
        sessionData.id = UUID().uuidString
        sessionData.startTimeStamp = Date().convertDateToIsoString()
        try await recordEvent(AnalyticsEventType.sessionStart.eventType)
        sessionData.creationStatus = .created
    }
    
    func stopSession() async throws {
        try await recordEvent(AnalyticsEventType.sessionStop.eventType)
    }
}
