//
//  NetworkCore.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class NetworkCore {
    static var shared: NetworkCore = NetworkCore()

    var enviroment: EnviromentType = .development
}

enum EnviromentType {
    case development
    
    var baseURL: String {
        switch self {
        case .development:
            return StringConstant.developmentUrl
        }
    }
    
    var scheme: String {
        switch self {
        case .development:
            return StringConstant.developmentSchema
        }
    }
}

/// Error Description documentation : https://docs.aws.amazon.com/location/latest/APIReference/CommonErrors.html

enum NetworkRequestError: Error {
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode
    case unknown
    case badRequest
    case accessDeniedException
    case incompleteSignature
    case internalFailure
    case invalidAction
    case invalidClientTokenId
    case invalidParameterCombination
    case invalidParameterValue
    case invalidQueryParameter
    case malformedQueryString
    case missingAction
    case missingAuthenticationToken
    case missingParameter
    case notAuthorized
    case optInRequired
    case requestExpired
    case serviceUnavailable
    case throttlingException
    case validationError

    var errorDescription: String {
        switch self {
            
        case .decode:
            return "Decode Error"
        case .badRequest:
            return "Bad Reques Error"
        case .invalidURL:
            return "Invalid URL"
        case .noResponse:
            return "No Reponse"
        case .unauthorized:
            return "Session Expired"
        case .accessDeniedException:
            return "You do not have sufficient access to perform this action"
            
        case .incompleteSignature:
            return "The request signature does not conform to AWS standards"
        case .internalFailure:
            return "The request processing has failed because of an unknown error, exception or failure"
        case .invalidAction:
            return "The action or operation requested is invalid. Verify that the action is typed correctly."
        case .invalidClientTokenId:
            return "The X.509 certificate or AWS access key ID provided does not exist in our records."
        case .invalidParameterCombination:
            return "Parameters that must not be used together were used together."
        case .invalidParameterValue:
            return "An invalid or out-of-range value was supplied for the input parameter."
        case .invalidQueryParameter:
            return "The AWS query string is malformed or does not adhere to AWS standards."
        case .malformedQueryString:
            return "The query string contains a syntax error."
        case .missingAction:
            return "The request is missing an action or a required parameter"
            
        case .missingAuthenticationToken:
            return "The request must contain either a valid (registered) AWS access key ID or X.509 certificate."
        case .missingParameter:
            return "A required parameter for the specified action is not supplied."
        case .notAuthorized:
            return "You do not have permission to perform this action."
        case .optInRequired:
            return "The AWS access key ID needs a subscription for the service."
        case .requestExpired:
            return "The request reached the service more than 15 minutes after the date stamp on the request or more than 15 minutes after the request expiration date (such as for pre-signed URLs), or the date stamp on the request is more than 15 minutes in the future."
        case .serviceUnavailable:
            return "The request has failed due to a temporary failure of the server."
        case .throttlingException:
            return "The request was denied due to request throttling."
        case .validationError:
            return "The input fails to satisfy the constraints specified by an AWS service."
        default:
            return "Unknown Error"
            
        }
    }
}
