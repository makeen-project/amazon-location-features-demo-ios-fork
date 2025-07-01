//
//  AnalyticsEventInput.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import AWSPinpoint
import Foundation

class AnalyticsEventInput {
    var eventType: String
    var attributes: [String: String]
    var session: AnalyticsEventSession?
    
    init(eventType: String, attributes: [String : String], session: AnalyticsEventSession? = nil) {
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

class AnalyticsEventSession {
    var id: String
    var startTimeStamp: String
    var stopTimeStamp: String
    
    init(id: String, startTimeStamp: String, stopTimeStamp: String) {
        self.id = id
        self.startTimeStamp = startTimeStamp
        self.stopTimeStamp = stopTimeStamp
    }
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

enum AnalyticsSessionStatus: String {
    case notCreated
    case inProgress
    case created
}
