//
//  AttributionVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SafariServices
import SnapKit

final class AttributionVC: UIViewController {
    
    // MARK: - Views
    private var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .closeButtonBackgroundColor
        return view
    }()
    
    private var partnerAttributionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .amazonFont(type: .bold, size: 20)
        label.textColor = .lsTetriary
        label.numberOfLines = 0
        label.text = StringConstant.partnerAttributionTitle
        
        return label
    }()
    
    private var partnerAttributionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .lsGrey
        label.numberOfLines = 0
        
        let localData = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        switch localData?.type {
        case .esri, .none:
            label.text = StringConstant.partnerAttributionESRIDescription
        case .here:
            label.text = StringConstant.partnerAttributionHEREDescription
        }
        
        return label
    }()
    
    private lazy var partnerAttributionControlStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(partnerAttributionlearnButton)
        stackView.addArrangedSubview(UIView())
        return stackView
    }()
    
    private lazy var partnerAttributionlearnButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(StringConstant.learnMore, for: .normal)
        button.setTitleColor(.lsPrimary, for: .normal)
        button.titleLabel?.font = .amazonFont(type: .bold, size: 16)
        button.backgroundColor = .lsPrimary.withAlphaComponent(0.1)
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.lsPrimary.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(partnerLearnButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var softwareAttributionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .amazonFont(type: .bold, size: 20)
        label.textColor = .lsTetriary
        label.numberOfLines = 0
        label.text = StringConstant.softwareAttributionTitle
        
        return label
    }()
    
    private var softwareAttributionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .lsGrey
        label.numberOfLines = 0
        label.text = StringConstant.softwareAttributionDescription
        return label
    }()
    
    private lazy var softwareAttributionControlStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(softwareAttributionlearnButton)
        stackView.addArrangedSubview(UIView())
        return stackView
    }()
    
    private lazy var softwareAttributionlearnButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(StringConstant.learnMore, for: .normal)
        button.setTitleColor(.lsPrimary, for: .normal)
        button.titleLabel?.font = .amazonFont(type: .bold, size: 16)
        button.backgroundColor = .lsPrimary.withAlphaComponent(0.1)
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.lsPrimary.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(softwareLearnButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationItems()
        setupViews()
        updateSpacerViews()
        if UIDevice.current.userInterfaceIdiom == .pad {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(deviceOrientationDidChange(_:)),
                                                   name: UIDevice.orientationDidChangeNotification,
                                                   object: nil)
        }
    }
    
    // MARK: - Functions
    private func setupNavigationItems() {
        navigationController?.navigationBar.tintColor = .lsTetriary
        title = UIDevice.current.userInterfaceIdiom == .phone ? StringConstant.attribution : ""
    }
    
    private func setupViews() {
        view.addSubview(separatorView)
        view.addSubview(partnerAttributionTitleLabel)
        view.addSubview(partnerAttributionDescriptionLabel)
        view.addSubview(partnerAttributionControlStackView)
        view.addSubview(softwareAttributionTitleLabel)
        view.addSubview(softwareAttributionDescriptionLabel)
        view.addSubview(softwareAttributionControlStackView)
        
        let horizontalPadding = 24
        let descriptionTopPadding = 10
        let learnMoreButtonTopPadding = 24
        let learnMoreButtonHeight = 48
        
        separatorView.isHidden = UIDevice.current.userInterfaceIdiom == .pad
        separatorView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        partnerAttributionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(horizontalPadding)
        }
        
        partnerAttributionDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(partnerAttributionTitleLabel.snp.bottom).offset(descriptionTopPadding)
            $0.horizontalEdges.equalToSuperview().inset(horizontalPadding)
        }
        
        partnerAttributionControlStackView.snp.makeConstraints {
            $0.top.equalTo(partnerAttributionDescriptionLabel.snp.bottom).offset(learnMoreButtonTopPadding)
            $0.horizontalEdges.equalToSuperview().inset(horizontalPadding)
            $0.height.equalTo(learnMoreButtonHeight)
        }
        
        softwareAttributionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(partnerAttributionlearnButton.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(horizontalPadding)
        }
        
        softwareAttributionDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(softwareAttributionTitleLabel.snp.bottom).offset(descriptionTopPadding)
            $0.horizontalEdges.equalToSuperview().inset(horizontalPadding)
        }
        
        softwareAttributionControlStackView.snp.makeConstraints {
            $0.top.equalTo(softwareAttributionDescriptionLabel.snp.bottom).offset(learnMoreButtonTopPadding)
            $0.horizontalEdges.equalToSuperview().inset(horizontalPadding)
            $0.height.equalTo(learnMoreButtonHeight)
        }
    }
    
    private func openSafariBrowser(with url: URL?) {
        guard let url else { return }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    @objc private func deviceOrientationDidChange(_ notification: Notification) {
        updateSpacerViews()
    }
    
    private func updateSpacerViews() {
        let orientation = UIDevice.current.getDeviceOrientation()
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            partnerAttributionControlStackView.arrangedSubviews.last?.isHidden = false
            softwareAttributionControlStackView.arrangedSubviews.last?.isHidden = false
        default:
            partnerAttributionControlStackView.arrangedSubviews.last?.isHidden = true
            softwareAttributionControlStackView.arrangedSubviews.last?.isHidden = true
        }
    }
    
    // NARK: - Actions
    @objc func partnerLearnButtonTapped() {
        let providerURL: String
        let localData = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        switch localData?.type {
        case .esri, .none:
            providerURL = StringConstant.esriDataProviderLearnMoreURL
        case .here:
            providerURL = StringConstant.hereDataProviderLearnMoreURL
        }
        
        let url = URL(string: providerURL)
        openSafariBrowser(with: url)
    }
    
    @objc func softwareLearnButtonTapped() {
        let url = URL(string: StringConstant.softwareAttributionLearnMoreURL)
        openSafariBrowser(with: url)
    }
}
