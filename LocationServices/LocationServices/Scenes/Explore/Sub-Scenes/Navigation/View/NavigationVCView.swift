//
//  NavigationVCView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

struct NavigationHeaderViewModel {
    let duration: String
    let distance: String
}

struct NavigationHeaderViewStyle {
    let backgroundColor: UIColor
    let showRouteButton: Bool
    
    static let navigationHeader = NavigationHeaderViewStyle(backgroundColor: .searchBarBackgroundColor, showRouteButton: false)
    
    static let navigationActions = NavigationHeaderViewStyle(backgroundColor: .white, showRouteButton: true)
}

enum RouteButtonState {
    case showRoute
    case hideRoute
    
    var title: String {
        switch self {
        case .showRoute:
            return "Show Route"
        case .hideRoute:
            return "Hide Route"
        }
    }
    
    var oppositeState: RouteButtonState {
        switch self {
        case .showRoute:
            return .hideRoute
        case .hideRoute:
            return .showRoute
        }
    }
}

final class NavigationHeaderView: UIView {
    var dismissHandler: VoidHandler?
    var switchRouteVisibility: ((RouteButtonState)->())?
    var model: NavigationHeaderViewModel! {
        didSet {
            self.durationLabel.text = model.duration
            self.distanceLabel.text = model.distance
        }
    }
    
    private var routeVisibilityButtonState: RouteButtonState = .showRoute
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = NavigationHeaderViewStyle.navigationHeader.backgroundColor
        view.layer.cornerRadius = 10
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let infoContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private var durationLabel: LargeTitleLabel = {
        let label = LargeTitleLabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .searchBarTintColor
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var routeVisibilityButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(routeVisibilityButtonState.title, for: .normal)
        
        button.tintColor = .lsTetriary
        button.backgroundColor = .closeButtonBackgroundColor
        button.isUserInteractionEnabled = true
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(routeVisibilityChanged), for: .touchUpInside)
        button.isHidden = !NavigationHeaderViewStyle.navigationHeader.showRouteButton
        button.titleLabel?.font = .amazonFont(type: .bold, size: 14)
        return button
    }()
    
    private lazy var exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.Navigation.navigationExitButton
        button.setTitle("Exit", for: .normal)
        
        button.tintColor = .white
        button.backgroundColor = .navigationRedButton
        button.isUserInteractionEnabled = true
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(navigationDismiss), for: .touchUpInside)
        button.titleLabel?.font = .amazonFont(type: .bold, size: 14)
        return button
    }()
    
    @objc func navigationDismiss() {
        dismissHandler?()
    }
    
    @objc func routeVisibilityChanged() {
        switchRouteVisibility?(routeVisibilityButtonState)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func updateDatas(distance: String?, duration: String?) {
        distanceLabel.text = distance
        durationLabel.text = duration
    }
    
    func update(style: NavigationHeaderViewStyle) {
        containerView.backgroundColor = style.backgroundColor
        routeVisibilityButton.isHidden = !style.showRouteButton
    }
    
    func updateRouteButton(state: RouteButtonState) {
        routeVisibilityButtonState = state
        routeVisibilityButton.setTitle(routeVisibilityButtonState.title, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(infoContainerStackView)
        infoContainerStackView.addArrangedSubview(durationLabel)
        infoContainerStackView.addArrangedSubview(distanceLabel)
        
        containerView.addSubview(routeVisibilityButton)
        containerView.addSubview(exitButton)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        infoContainerStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        
        durationLabel.snp.makeConstraints {
            $0.height.equalTo(28)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.height.equalTo(18)
        }
        
        routeVisibilityButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.height.equalTo(exitButton.snp.height)
            $0.leading.greaterThanOrEqualTo(infoContainerStackView.snp.trailing).offset(-10)
            $0.trailing.equalTo(exitButton.snp.leading).offset(-16)
            $0.width.equalTo(131).priority(999)
        }
        
        exitButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
            $0.width.equalTo(83)
        }
    }
}
