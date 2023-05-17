//
//  MapviewOverlayItems.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

protocol MapOverlayItemsProtocol: AnyObject {
    var delegate: MapOverlayItemsOutputDelegate? { get set }
}

protocol MapOverlayItemsOutputDelegate: AnyObject {
    func mapLayerButtonAction()
    func directionButtonAction()
    func locateMeButtonAction()
    func geofenceButtonAction()
    func searchTextTapped()
    func loginButtonTapped()
}

final class MapOverlayItems: UIView, MapOverlayItemsProtocol {
    
    var delegate: MapOverlayItemsOutputDelegate?
    
    
    /// UI Elements
    
   private var containerView: UIView = UIView()
    
   private lazy var directonButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .maplightGrayColor
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.setImage(.directionMapIcon, for: .normal)
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 23,
                                                                      leading: 23,
                                                                      bottom: 23,
                                                                      trailing: 23)
        button.addTarget(self, action: #selector(directionAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var locateMeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .maplightGrayColor
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.setImage(.locateMeMapIcon, for: .normal)
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 23,
                                                                      leading: 23,
                                                                      bottom: 23,
                                                                      trailing: 23)
        button.addTarget(self, action: #selector(locateMeAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var geofenceButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .maplightGrayColor
        button.backgroundColor = .white
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        button.layer.cornerRadius = 8
        button.setImage(.geofenceMapIcon, for: .normal)
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 23,
                                                                      leading: 23,
                                                                      bottom: 23,
                                                                      trailing: 23)
        button.addTarget(self, action: #selector(geofenceButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var mapStyleButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .maplightGrayColor
        button.backgroundColor = .white
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        button.layer.cornerRadius = 8
        button.setImage(.mapStyleMapIcon, for: .normal)
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 23,
                                                                      leading: 23,
                                                                      bottom: 23,
                                                                      trailing: 23)
        button.addTarget(self, action: #selector(mapStyleButtonAction), for: .touchUpInside)
        
        return button
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .mapElementDiverColor
        return view
    }()
    
    private let bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.spacing = 8
        return stackView
    }()
    
    private let topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackViews()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
}

extension MapOverlayItems {
    @objc func directionAction() {
        delegate?.directionButtonAction()
    }
 
    @objc func locateMeAction() {
        delegate?.locateMeButtonAction()
    }
    
    @objc func geofenceButtonAction() {
        delegate?.geofenceButtonAction()
    }
    
    @objc func mapStyleButtonAction() {
        delegate?.mapLayerButtonAction()
    }
}

private extension MapOverlayItems {
    func setupStackViews() {
        topStackView.removeArrangedSubViews()
        bottomStackView.removeArrangedSubViews()
        topStackView.addArrangedSubview(mapStyleButton)
        topStackView.addArrangedSubview(dividerView)
        topStackView.addArrangedSubview(geofenceButton)
        bottomStackView.addArrangedSubview(locateMeButton)
        bottomStackView.addArrangedSubview(directonButton)
    }
    
    func setupViews() {
        self.addSubview(containerView)
        
        containerView.addSubview(topStackView)
        containerView.addSubview(bottomStackView)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        geofenceButton.snp.makeConstraints {
            $0.height.width.equalTo(48)
        }
        
        dividerView.snp.makeConstraints {
            $0.height.width.equalTo(1)
        }
        
        mapStyleButton.snp.makeConstraints {
            $0.height.width.equalTo(48)
        }
        
        topStackView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(48)
            $0.height.equalTo(100)
        }
        
        directonButton.snp.makeConstraints {
            $0.height.width.equalTo(48)
        }
        
        locateMeButton.snp.makeConstraints {
            $0.height.width.equalTo(48)
        }
        
        bottomStackView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(48)
            $0.height.equalTo(104)
        }
    }
}
