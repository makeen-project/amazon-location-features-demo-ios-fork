//
//  WelcomeVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class WelcomeVC: UIViewController {
    
    // MARK: - Views
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .appLogo
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .amazonFont(type: .bold, size: 24)
        label.textColor = .lsTetriary
        label.numberOfLines = 0
        label.text = StringConstant.welcomeTitle
        label.textAlignment = .center
        return label
    }()
    
    private let bottomView: WelcomeBottomView = {
        let view = WelcomeBottomView()
        return view
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(StringConstant.continueString, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .amazonFont(type: .bold, size: 16)
        button.backgroundColor = .lsPrimary
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ViewsIdentifiers.General.welcomeContinueButton
        return button
    }()
    
    // MARK: - Properties
    var continueHandler: VoidHandler?
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never
        setupNavigationItems()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Functions
    private func setupNavigationItems() {
        navigationController?.navigationBar.tintColor = .lsTetriary
        self.title = StringConstant.attribution
    }
    
    private func setupViews() {
        view.addSubview(iconView)
        view.addSubview(titleLabel)
        view.addSubview(bottomView)
        view.addSubview(continueButton)
        
        iconView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(72)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(56)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        bottomView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        continueButton.snp.makeConstraints {
            $0.top.equalTo(bottomView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            $0.height.equalTo(48)
        }
    }
    
    private func termsAndConditionsWereAgreed() {
        let currentVersion = UIApplication.appVersion()
        UserDefaultsHelper.save(value: currentVersion, key: .termsAndConditionsAgreedVersion)
    }
    
    // NARK: - Actions
    @objc func continueButtonTapped() {
        termsAndConditionsWereAgreed()
        continueHandler?()
    }
}
