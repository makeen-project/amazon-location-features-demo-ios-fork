//
//  RouteOptionsView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class RouteOptionsView: UIView {
    
    enum Constants {
        static let collapsedHeight: Int = 32
        static let expandedHeight: Int = 144
    }
    
    var changeRouteOptionHeight: IntHandler?
    var avoidFerries: BoolHandler?
    var avoidTolls: BoolHandler?
    
    private var routeOptionState: Bool = true
    private let containerView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.routeOptionsContainer
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.lsLight2.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var routeOptionToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.Routing.routeOptionsVisibilityButton
        button.tintColor = .black
        button.backgroundColor = .mapElementDiverColor
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(routeOptionExpand), for: .touchUpInside)
        return button
    }()
    
    private var routeOptionImage: UIImageView = {
        let image = UIImage(systemName: "chevron.down")!
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private var routeOptionTitle: UILabel = {
        let label = UILabel()
        label.text = "Route Options"
        label.font = .amazonFont(type: .bold, size: 12)
        return label
    }()
    
    private var routeOptionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false

        return view
    }()
    
    private let tollOption: RouteOptionView = {
        let view = RouteOptionView(title: StringConstant.avoidTolls)
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.avoidTollsOptionContainer
        return view
    }()
    
    private var firstSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        return view
    }()
        
    private let ferriesOption: RouteOptionView = {
        let view = RouteOptionView(title: StringConstant.avoidFerries)
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.avoidFerriesOptionContainer
        return view
    }()
    
    private let optionStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .equalSpacing
        sv.spacing = 0
        return sv
    }()
    
    @objc func routeOptionExpand() {
        routeOptionToggleButton.backgroundColor = routeOptionState ? .white : .mapElementDiverColor
        routeOptionToggleButton.layer.maskedCorners = routeOptionState ? [.layerMinXMinYCorner, .layerMaxXMinYCorner] : [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        containerView.isHidden = !routeOptionState
        routeOptionImage.image = UIImage(systemName: routeOptionState ? "chevron.up" : "chevron.down")
        changeRouteOptionHeight?(routeOptionState ? Constants.expandedHeight : Constants.collapsedHeight)
        routeOptionState.toggle()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHandlers()
        setupViews()
    }
    
    private func setupHandlers() {
        ferriesOption.boolHandler = { [weak self] state in
            self?.avoidFerries?(state)
        }
        
        tollOption.boolHandler = { [weak self] state in
            self?.avoidTolls?(state)
        }
        
    }
    
    func setLocalValues(toll: Bool, ferries: Bool) {
        tollOption.setDefaultState(state: toll)
        ferriesOption.setDefaultState(state: ferries)
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    
    private func setupViews() {
        optionStackView.removeArrangedSubViews()
        optionStackView.addArrangedSubview(tollOption)
        optionStackView.addArrangedSubview(firstSeperatorView)
        optionStackView.addArrangedSubview(ferriesOption)
        
        routeOptionContainerView.addSubview(routeOptionTitle)
        routeOptionContainerView.addSubview(routeOptionImage)
        routeOptionToggleButton.addSubview(routeOptionContainerView)
        
        self.addSubview(routeOptionToggleButton)
        self.addSubview(containerView)
        
        routeOptionContainerView.addSubview(routeOptionTitle)
        routeOptionContainerView.addSubview(routeOptionImage)
        routeOptionToggleButton.addSubview(routeOptionContainerView)
        
        containerView.addSubview(optionStackView)
        
        routeOptionToggleButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(32)
            $0.width.equalTo(152)
        }
        
        routeOptionContainerView.snp.makeConstraints {
            $0.width.equalTo(118)
            $0.height.equalTo(16)
            $0.centerX.centerY.equalToSuperview()
        }
        
        routeOptionTitle.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
        }
        
        routeOptionImage.snp.makeConstraints {
            $0.centerY.equalTo(routeOptionTitle.snp.centerY)
            $0.height.equalTo(4)
            $0.width.equalTo(6)
            $0.trailing.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(routeOptionToggleButton.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        tollOption.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        firstSeperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        ferriesOption.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        optionStackView.snp.makeConstraints {
            $0.top.trailing.leading.bottom.equalToSuperview()
        }
        
        containerView.isHidden = true
    }
}
