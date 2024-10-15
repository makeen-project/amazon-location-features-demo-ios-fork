//
//  ErrorHandler.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

class ErrorHandler {
    
    static func isAWSStackDeletedError(error: any Error) -> Bool {
        let errorMessage = error.localizedDescription.lowercased()
        return errorMessage.contains("not found") || errorMessage.contains("security token included in the request is invalid")
    }
    
    static func handleAWSStackDeletedError(delegate: AlertPresentable?) {
        DispatchQueue.main.async {
            let model = AlertModel(title: StringConstant.awsStackInvalidTitle, message: StringConstant.awsStackInvalidExplanation, cancelButton: nil, okButton: StringConstant.terminate)
            model.okHandler = {
                UserDefaultsHelper.setAppState(state: .prepareDefaultAWSConnect)
                
                // remove custom configuration
                UserDefaultsHelper.removeObject(for: .awsConnect)
            }
            delegate?.showAlert(model)
        }
    }
}
