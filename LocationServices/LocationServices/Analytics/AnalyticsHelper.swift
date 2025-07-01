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
        do {
            if pinpointClient == nil {
                try await initialise()
            }
            
            if let appId = analyticsAppId {
                
                var events: [AnalyticsEventInput] = []
                
                if eventName == AnalyticsEventType.sessionStop.eventType {
                    let session = AnalyticsEventSession(id: sessionData.id!, startTimeStamp: sessionData.startTimeStamp!, stopTimeStamp: Date().convertDateToIsoString()!)
                    events = [AnalyticsEventInput(eventType: AnalyticsEventType.sessionStop.eventType, attributes: [:], session: session)]
                }
                else {
                    events = [AnalyticsEventInput(eventType: eventName, attributes: [:])]
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
                    events.append(AnalyticsEventInput(eventType: AnalyticsEventType.sessionEnd.eventType, attributes: sessionStopEvent!.attributes))
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
        } catch {
            print("Analytics recording failed: \(error)")
            throw error
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
