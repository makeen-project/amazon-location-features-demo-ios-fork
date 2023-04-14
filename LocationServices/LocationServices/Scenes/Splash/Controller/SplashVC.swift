//
//  SplashVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class SplashVC: UIViewController {
    var setupCompleteHandler: VoidHandler?
    
    var viewModel: SplashViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.setupCompleteHandler = setupCompleteHandler
        viewModel.setupAWS()
    }
}
