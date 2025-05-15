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
    
    enum Constants {
        static let topStackViewTopOffsetiPhone: CGFloat = 60
        static let topStackViewTopOffsetiPad: CGFloat = -20
        
        static let bottomStackViewHorizontalOffset: CGFloat = 16
        static let bottomStackViewBottomOffset: CGFloat = 16
        static let bottomStackViewWidth: CGFloat = 48
        static let bottomStackViewHeight: CGFloat = 104
    }
    
    var delegate: MapOverlayItemsOutputDelegate?
    
    
    /// UI Elements
    
   private var containerView: UIView = UIView()
    
    private lazy var mapStyleButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .maplightGrayColor
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.setImage(.mapStyleMapIcon, for: .normal)
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 23,
                                                                      leading: 23,
                                                                      bottom: 23,
                                                                      trailing: 23)
        button.addTarget(self, action: #selector(mapStyleButtonAction), for: .touchUpInside)
        button.setShadow(shadowOpacity: 0.3, shadowBlur: 5)
        return button
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
    }
    
    func setupViews() {
        self.addSubview(containerView)
        
        containerView.addSubview(topStackView)
        containerView.addSubview(bottomStackView)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        mapStyleButton.snp.makeConstraints {
            $0.height.width.equalTo(48)
        }
        
        let isiPad = UIDevice.current.userInterfaceIdiom == .pad
        topStackView.snp.makeConstraints {
            if isiPad {
                $0.top.equalTo(self.safeAreaLayoutGuide).offset(Constants.topStackViewTopOffsetiPad)
            }
            else {
                $0.top.equalTo(self.safeAreaLayoutGuide).offset(Constants.topStackViewTopOffsetiPhone)
            }
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(48)
            $0.height.equalTo(48)
        }
        
        bottomStackView.snp.remakeConstraints {
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(Constants.bottomStackViewHorizontalOffset)
            $0.width.equalTo(Constants.bottomStackViewWidth)
            $0.height.equalTo(Constants.bottomStackViewHeight)
        }
    }
}
