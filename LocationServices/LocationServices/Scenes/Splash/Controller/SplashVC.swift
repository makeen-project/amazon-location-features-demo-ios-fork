//
//  SplashVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class SplashVC: UIViewController, SplashViewModelDelegate {
    
    var setupCompleteHandler: VoidHandler?
    var viewModel: SplashViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        viewModel.delegate = self
        viewModel.setupCompleteHandler = setupCompleteHandler
        viewModel.setupAWS()
    }
}
