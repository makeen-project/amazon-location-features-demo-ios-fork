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
    
    private var titleTopOffset: CGFloat = 27
    
    private let titleLabel: LargeTitleLabel = {
        let label = LargeTitleLabel(labelText: StringConstant.trackingHistory)
        label.accessibilityIdentifier = ViewsIdentifiers.Tracking.trackingStartedLabel
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = ViewsIdentifiers.Tracking.trackingStoppedLabel
        label.font = .amazonFont(type: .regular, size: 13)
        label.textAlignment = .left
        label.textColor = .searchBarTintColor
        label.text = StringConstant.Tracking.noTracking
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var trackingActionButton: AmazonLocationButton =  {
        let button = AmazonLocationButton(title: StringConstant.startTracking)
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
        toggleTrackingStatus()
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
            
            detailLabel.text = StringConstant.Tracking.isTracking
            detailLabel.textColor = .navigationRedButton
        } else {
            trackingActionButton.setTitle(StringConstant.startTracking, for: .normal)
            trackingActionButton.backgroundColor = .lsPrimary
            trackingActionButton.titleLabel?.font = .amazonFont(type: .bold, size: 16)
            
            detailLabel.text = StringConstant.Tracking.noTracking
            detailLabel.textColor = .searchBarTintColor
        }
    }
    
    convenience init(titleTopOffset: CGFloat) {
        self.init()
        self.titleTopOffset = titleTopOffset
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        self.addSubview(titleLabel)
        self.addSubview(detailLabel)
        self.addSubview(trackingActionButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(titleTopOffset)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(30)
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(trackingActionButton.snp.leading).offset(-5)
            $0.height.equalTo(18)
            $0.bottom.equalToSuperview()
        }
        
        trackingActionButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
            $0.width.equalTo(132)
        }
    }
}
