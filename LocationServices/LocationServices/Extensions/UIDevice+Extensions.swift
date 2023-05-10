//
//  UIDevice+Extensions.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension UIDevice {
    func getDeviceOrientation() -> UIDeviceOrientation {
        var orientation = UIDevice.current.orientation
        let interfaceOrientation: UIInterfaceOrientation?
        if #available(iOS 15, *) {
            interfaceOrientation = UIApplication.shared.connectedScenes
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.interfaceOrientation
        } else {
            interfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        }
        guard interfaceOrientation != nil else {
            return orientation
        }

        if !orientation.isValidInterfaceOrientation {
            // UIDeviceOrientation.landscapeRight is assigned to UIInterfaceOrientation.landscapeLeft and UIDeviceOrientation.landscapeLeft is assigned to UIInterfaceOrientation.landscapeRight. The reason for this is that rotating the device requires rotating the content in the opposite direction.
            // Reference : https://developer.apple.com/documentation/uikit/uiinterfaceorientation
            switch interfaceOrientation {
            case .portrait:
                orientation = .portrait
                break
            case .landscapeRight:
                orientation = .landscapeLeft
                break
            case .landscapeLeft:
                orientation = .landscapeRight
                break
            case .portraitUpsideDown:
                orientation = .portraitUpsideDown
                break
            default:
                orientation = .unknown
                break
            }
        }

        return orientation
    }
}
