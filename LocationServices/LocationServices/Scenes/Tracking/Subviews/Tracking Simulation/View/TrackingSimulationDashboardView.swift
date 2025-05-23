//
//  TrackingSimulationDashboardView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

enum TrackingSimulationDashoardConstant {
    static let titleFont = UIFont.amazonFont(type: .bold, size: 24)
    static let title2Font = UIFont.amazonFont(type: .regular, size: 16)
    static let detailLabelFont = UIFont.amazonFont(type: .regular, size: 13)
}

final class TrackingSimulationDashboardView: UIView {
    var dashboardButtonHandler: VoidHandler?
    var maybeButtonHandler: VoidHandler?
    private var isiPad = UIDevice.current.userInterfaceIdiom == .pad
    
    private let backgroundIcon: UIImageView = {
        let imageView = UIImageView(image: .simulationBackground)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let simulationLabel = AmazonLocationLabel(labelText: StringConstant.simulation,
                                                      font: TrackingSimulationDashoardConstant.title2Font,
                                                      isMultiline: true,
                                                      fontColor: .lsGrey,
                                                      textAlignment: .center)
    
    private let mainLabel = AmazonLocationLabel(labelText: StringConstant.trackersGeofences,
                                                 font: TrackingSimulationDashoardConstant.titleFont,
                                                 fontColor: .black,
                                                 textAlignment: .center)
    
    private let mainDetailLabel = AmazonLocationLabel(labelText: StringConstant.trackersGeofencesDetail,
                                                  font: TrackingSimulationDashoardConstant.detailLabelFont,
                                                  isMultiline: true,
                                                  fontColor: .lsGrey,
                                                  textAlignment: .center)
    
    private let trackersView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let trackersIcon: UIImageView = {
        let iv = UIImageView(image: .trackingIcon.withTintColor(.lsPrimary))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let trackersLabel = AmazonLocationLabel(labelText: StringConstant.trackers,
                                                 font: TrackingSimulationDashoardConstant.title2Font,
                                                 fontColor: .black,
                                                 textAlignment: .left)

    private let trackersDetailLabel = AmazonLocationLabel(labelText: StringConstant.trackersDetail,
                                                  font: TrackingSimulationDashoardConstant.detailLabelFont,
                                                  isMultiline: true,
                                                  fontColor: .lsGrey,
                                                  textAlignment: .left)
    
    private let geofencesView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let geofencesIcon: UIImageView = {
        let iv = UIImageView(image: .geofenceIcon.withTintColor(.lsPrimary))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let geofencesLabel = AmazonLocationLabel(labelText: StringConstant.geofences,
                                                 font: TrackingSimulationDashoardConstant.title2Font,
                                                 fontColor: .black,
                                                 textAlignment: .left)
    
    private let geofencesDetailLabel = AmazonLocationLabel(labelText: StringConstant.geofencesDetail,
                                                  font: TrackingSimulationDashoardConstant.detailLabelFont,
                                                  isMultiline: true,
                                                  fontColor: .lsGrey,
                                                  textAlignment: .left)
    
    private let notificationsView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let notificationsIcon: UIImageView = {
        let iv = UIImageView(image: .notificationIcon?.withTintColor(.lsPrimary))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let notificationsLabel = AmazonLocationLabel(labelText: StringConstant.notifications,
                                                 font: TrackingSimulationDashoardConstant.title2Font,
                                                 fontColor: .black,
                                                 textAlignment: .left)
    
    private let notificationsDetailLabel = AmazonLocationLabel(labelText: StringConstant.notificationsDetail,
                                                  font: TrackingSimulationDashoardConstant.detailLabelFont,
                                                  isMultiline: true,
                                                  fontColor: .lsGrey,
                                                  textAlignment: .left)
    
    private lazy var startButton: AmazonLocationButton =  {
        let button = AmazonLocationButton(title: StringConstant.startSimulation)
        button.accessibilityIdentifier = ViewsIdentifiers.Tracking.startTrackingSimulationButton
        button.addTarget(self, action: #selector(commonButtonAction), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    convenience init() {
        self.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorCannotInitializeView)
    }
    
    @objc private func simulationDismiss() {
        maybeButtonHandler?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    private func setupViews() {
        self.backgroundColor = .white

        self.addSubview(backgroundIcon)
        self.addSubview(simulationLabel)
        self.addSubview(mainLabel)
        self.addSubview(mainDetailLabel)
        
        self.addSubview(trackersView)
        self.addSubview(geofencesView)
        self.addSubview(notificationsView)
        
        self.addSubview(startButton)
        
        trackersView.addSubview(trackersIcon)
        trackersView.addSubview(trackersLabel)
        trackersView.addSubview(trackersDetailLabel)
        
        geofencesView.addSubview(geofencesIcon)
        geofencesView.addSubview(geofencesLabel)
        geofencesView.addSubview(geofencesDetailLabel)
        
        notificationsView.addSubview(notificationsIcon)
        notificationsView.addSubview(notificationsLabel)
        notificationsView.addSubview(notificationsDetailLabel)
        
        backgroundIcon.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            $0.height.equalTo(246)
        }
        
        simulationLabel.snp.makeConstraints {
            $0.top.equalTo(backgroundIcon.snp.bottom)
            $0.centerX.equalToSuperview()
        }
        
        mainLabel.snp.makeConstraints {
            $0.top.equalTo(simulationLabel.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
        }
        
        mainDetailLabel.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(329)
            $0.height.equalTo(36)
        }
        
        trackersView.snp.makeConstraints {
            $0.top.equalTo(mainDetailLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            $0.height.equalTo(32)
        }
        
        trackersIcon.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.width.equalTo(32)
        }
        
        trackersLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(trackersIcon.snp.trailing).offset(16)
        }
        
        trackersDetailLabel.snp.makeConstraints {
            $0.top.equalTo(trackersLabel.snp.bottom).offset(6)
            $0.leading.equalTo(trackersIcon.snp.trailing).offset(16)
        }
        
        geofencesView.snp.makeConstraints {
            $0.top.equalTo(trackersView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            $0.height.equalTo(32)
        }
        
        geofencesIcon.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.width.equalTo(32)
        }
        
        geofencesLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(geofencesIcon.snp.trailing).offset(16)
            $0.trailing.equalToSuperview()
        }
        
        geofencesDetailLabel.snp.makeConstraints {
            $0.top.equalTo(geofencesLabel.snp.bottom).offset(6)
            $0.leading.equalTo(geofencesIcon.snp.trailing).offset(16)
            $0.trailing.equalToSuperview()
        }
        
        notificationsView.snp.makeConstraints {
            $0.top.equalTo(geofencesView.snp.bottom).offset(48)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            $0.height.equalTo(32)
        }
        
        notificationsIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.width.equalTo(32)
        }
        
        notificationsLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(notificationsIcon.snp.trailing).offset(16)
            $0.trailing.equalToSuperview()
        }
        
        notificationsDetailLabel.snp.makeConstraints {
            $0.top.equalTo(notificationsLabel.snp.bottom).offset(6)
            $0.leading.equalTo(notificationsIcon.snp.trailing).offset(16)
            $0.trailing.equalToSuperview()
        }
        
        startButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(notificationsView.snp.bottom).offset(64)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
        }
    }
    
    @objc func commonButtonAction() {
        dashboardButtonHandler?()
    }
}
