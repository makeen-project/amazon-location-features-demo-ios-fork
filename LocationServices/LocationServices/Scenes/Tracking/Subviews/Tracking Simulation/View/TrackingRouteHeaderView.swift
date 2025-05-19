//
//  TrackingHistoryHeaderView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class TrackingRouteHeaderView: UIView {
    
    private var isTrackingStarted: Bool = false
    var trackingButtonHandler: BoolHandler?
    var showAlertCallback: ((AlertModel)->())?
    var showAlertControllerCallback: ((UIAlertController)->())?
    
    private var titleTopOffset: CGFloat = 10
    
    private let titleLabel: LargeTitleLabel = {
        let label = LargeTitleLabel(labelText: StringConstant.trackers)
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
        
        toggleTrackingStatus()
    }

    private func toggleTrackingStatus() {
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
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
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
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(trackingActionButton.snp.leading).offset(-5)
            $0.height.equalTo(18)
            $0.bottom.equalToSuperview()
        }
        
        trackingActionButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(titleTopOffset)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
            $0.width.equalTo(132)
        }
    }
}
