//
//  TrackingHistoryHeaderView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class TrackingHistoryHeaderView: UIView {
    
    private var isTrackingStarted: Bool = false
    var trackingButtonHandler: BoolHandler?
    var showAlertCallback: ((AlertModel)->())?
    var showAlertControllerCallback: ((UIAlertController)->())?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = ViewsIdentifiers.Tracking.trackingStartedLabel
        label.font = .amazonFont(type: .bold, size: 20)
        label.textAlignment = .left
        label.text = "Tracking History"
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = ViewsIdentifiers.Tracking.trackingStoppedLabel
        label.font = .amazonFont(type: .regular, size: 13)
        label.textAlignment = .left
        label.textColor = .searchBarTintColor
        label.text = "Not tracking your activity"
        return label
    }()
    
    private lazy var trackingActionButton: AmazonLocationButton =  {
        let button = AmazonLocationButton(title: "Start Tracking")
        button.accessibilityIdentifier = ViewsIdentifiers.Tracking.trackingActionButton
        button.addTarget(self, action: #selector(trackingButtonAction), for: .touchUpInside)
        return button
    }()
    
    @objc func trackingButtonAction() {
        if !Reachability.shared.isInternetReachable && !isTrackingStarted {
            let alertModel = AlertModel(title: StringConstant.error, message: StringConstant.noInternetConnection, cancelButton: nil)
            showAlertCallback?(alertModel)
            return
        }
        
        let mapStyle = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        if mapStyle?.type != .here && UserDefaultsHelper.getAppState() == .loggedIn && !isTrackingStarted {
            showChangeStyleAlert()
        } else {
            toggleTrackingStatus()
        }
    }
    
    private func showChangeStyleAlert() {
        //TODO: AlertModel can be updated to be more flexible and be suited for this case
        let alert = UIAlertController(title: StringConstant.enableTracking,
                                      message: StringConstant.trackingChangeToHere, preferredStyle: UIAlertController.Style.alert)
        
        let termsAndConditionsAction = UIAlertAction(title: StringConstant.viewTermsAndConditions,
                                                     style: .default,
                                                     handler: { [weak self] _ in
            guard let url = URL(string: StringConstant.termsAndConditionsTrackingURL) else { return }
            UIApplication.shared.open(url)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self?.showChangeStyleAlert()
            })
        })
        alert.addAction(termsAndConditionsAction)
        
        
        let continueAction = UIAlertAction(title: StringConstant.continueToTracker,
                                           style: .default,
                                           handler: { [weak self] _ in
            self?.trackingButtonHandler?(true)
        })

        alert.addAction(continueAction)
        
        showAlertControllerCallback?(alert)
    }
    
    private func toggleTrackingStatus() {
        if UserDefaultsHelper.getAppState() == .loggedIn {
            isTrackingStarted.toggle()
        }
        
        trackingButtonHandler?(isTrackingStarted)
    }
    
    func updateButtonStyle(isTrackingStarted: Bool) {
        self.isTrackingStarted = isTrackingStarted
        
        if isTrackingStarted {
            trackingActionButton.setTitle(StringConstant.stopTracking, for: .normal)
            trackingActionButton.backgroundColor = .navigationRedButton
            trackingActionButton.titleLabel?.font = .amazonFont(type: .bold, size: 16)
            
            detailLabel.text = "Tracking your activity"
            detailLabel.textColor = .navigationRedButton
        } else {
            trackingActionButton.setTitle(StringConstant.startTracking, for: .normal)
            trackingActionButton.backgroundColor = .tabBarTintColor
            trackingActionButton.titleLabel?.font = .amazonFont(type: .bold, size: 16)
            
            detailLabel.text = "Not tracking your activity"
            detailLabel.textColor = .searchBarTintColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.addSubview(titleLabel)
        self.addSubview(detailLabel)
        self.addSubview(trackingActionButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(27)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(28)
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(18)
        }
        
        trackingActionButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(31)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
            $0.width.equalTo(152)
        }
    }
}
