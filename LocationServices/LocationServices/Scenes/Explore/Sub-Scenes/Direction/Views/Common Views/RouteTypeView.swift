//
//  RouteTypeView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

enum RouteTypes: Codable {
    case pedestrian, scooter, car, truck
    
    var title: String {
        switch self {
        case .pedestrian:
            return "Pedestrian"
        case .scooter:
            return "Scooter"
        case .car:
            return "Car"
        case .truck:
            return "Truck"
        }
    }
    
    var image: UIImage {
        switch self {
        case .pedestrian:
            return .navigationWalkingIcon.withRenderingMode(.alwaysTemplate)
        case .scooter:
            return .navigationScooterIcon.withRenderingMode(.alwaysTemplate)
        case .car:
            return .navigationCarIcon.withRenderingMode(.alwaysTemplate)
        case .truck:
            return .navigationTruckIcon.withRenderingMode(.alwaysTemplate)
        }
    }
}

final class RouteTypeView: UIView {
    
    var isSelectedHandle: BoolHandler?
    var goButtonHandler: VoidHandler?
    
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var leftContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var selectedViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.tintColor = .clear
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(routeTypeChanged), for: .touchUpInside)
        return button
    }()
    
    private lazy var routeTypeImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .lsTetriary
        return iv
    }()
    
    private lazy var goButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.Routing.navigateButton
        button.setTitle(StringConstant.go, for: .normal)
        button.backgroundColor = .buttonOrangeColor
        button.layer.cornerRadius = 8
        button.tintColor = .white
        button.titleLabel?.font = .amazonFont(type: .bold, size: 16)
        button.addTarget(self, action: #selector(startNavigation), for: .touchUpInside)
        return button
    }()
    
    private var durationLabel: UILabel = {
        let label = UILabel()
        label.font = .amazonFont(type: .bold, size: 14)
        label.textColor = .lsTetriary
        label.textAlignment = .right
        label.text = ""
        label.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(749), for: .horizontal)
        return label
    }()
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.font = .amazonFont(type: .regular, size: 14)
        label.textColor = .lsGrey
        label.text = ""
        label.textAlignment = .left
        return label
    }()
    
    private var leaveLabel: UILabel = {
        let label = UILabel()
        label.font = .amazonFont(type: .regular, size: 14)
        label.textColor = .lsGrey
        label.text = ""
        label.textAlignment = .left
        return label
    }()
    
    private let dotView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarTintColor
        view.layer.cornerRadius = 3
        return view
    }()
    
    private var selectedLabel: UILabel = {
        let label = UILabel()
        label.text = "Selected"
        label.font = .amazonFont(type: .bold, size: 14)
        label.textColor = .lsPrimary
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(UILayoutPriority(748), for: .horizontal)
        return label
    }()
    
    private let loaderContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let firstLoaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .lsLight3
        view.layer.cornerRadius = 4
        return view
    }()
    private let secondLoaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .lsLight3
        view.layer.cornerRadius = 4
        return view
    }()
    private let thirdLoaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .lsLight3
        view.layer.cornerRadius = 8
        return view
    }()
    
    convenience init(viewType: RouteTypes, isSelected: Bool = false) {
        self.init(frame: .zero)
        self.routeTypeImage.image = viewType.image
        isDotViewVisible(isSelected)
        setAccessibilityIdentifier(viewType: viewType)
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setAccessibilityIdentifier(viewType: RouteTypes) {
        containerView.accessibilityIdentifier = ViewsIdentifiers.Routing.routeMainContainer+viewType.title
        leftContainerView.accessibilityIdentifier = ViewsIdentifiers.Routing.routeLeftContainer+viewType.title
        durationLabel.accessibilityIdentifier = ViewsIdentifiers.Routing.routeEstimatedTime+viewType.title
        distanceLabel.accessibilityIdentifier = ViewsIdentifiers.Routing.routeEstimatedDistance+viewType.title
        leaveLabel.accessibilityIdentifier = ViewsIdentifiers.Routing.routeEstimatedLeave+viewType.title
    }
    
    @objc func routeTypeChanged() {
        isSelectedHandle?(true)
    }
    
    @objc func startNavigation() {
       goButtonHandler?()
    }
    
    func setDatas(distance: String, duration: String, time: String, leaveType: LeaveType, isPreview: Bool) {
        containerView.isHidden = false
        loaderContainer.isHidden = true
        self.distanceLabel.text = distance
        self.durationLabel.text = duration
        self.leaveLabel.text = time == "" || leaveType != .arriveAt ? "": "Leave at \(time)"
        let isGoButtonEnabled = !distance.isEmpty && !duration.isEmpty
        self.goButton.backgroundColor = isGoButtonEnabled ? UIColor.buttonOrangeColor : .lsGrey
        self.goButton.isEnabled = isGoButtonEnabled
        self.isUserInteractionEnabled = isGoButtonEnabled
        let goButtonTitle = isPreview ? StringConstant.preview : StringConstant.go
        self.goButton.setTitle(goButtonTitle, for: .normal)
        self.layoutIfNeeded()
    }
    
    func disableRouteType() {
        containerView.isHidden = true
        loaderContainer.isHidden = false
        self.goButton.isEnabled = false
        self.goButton.backgroundColor = .lsGrey
        self.isUserInteractionEnabled = false
    }
    
    func hideLoader( isPreview: Bool) {
        containerView.isHidden = false
        loaderContainer.isHidden = true
        let goButtonTitle = isPreview ? StringConstant.preview : StringConstant.go
        self.goButton.setTitle(goButtonTitle, for: .normal)
    }
    
    func updateSelectedLabel(state: Bool) {
        self.selectedLabel.text = state ? "Selected" : ""
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(routeTypeImage)
        
        containerView.addSubview(leftContainerView)
        leftContainerView.addSubview(durationLabel)
        leftContainerView.addSubview(dotView)
        leftContainerView.addSubview(selectedLabel)
        leftContainerView.addSubview(distanceLabel)
        leftContainerView.addSubview(leaveLabel)
        
        containerView.addSubview(goButton)
        containerView.addSubview(selectedViewButton)
        
        containerView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        leftContainerView.snp.makeConstraints {
            $0.top.equalTo(routeTypeImage.snp.top)
            $0.leading.equalTo(routeTypeImage.snp.trailing).offset(10)
        }
        
        routeTypeImage.snp.makeConstraints {
            $0.width.height.equalTo(16)
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(16)
        }
        
        durationLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        dotView.snp.makeConstraints {
            $0.leading.equalTo(durationLabel.snp.trailing).offset(4)
            $0.height.width.equalTo(3)
            $0.centerY.equalTo(durationLabel.snp.centerY)
        }
    
        selectedLabel.snp.makeConstraints {
            $0.leading.equalTo(dotView.snp.trailing).offset(4)
            $0.height.equalTo(18)
            $0.centerY.equalTo(durationLabel.snp.centerY)
            $0.trailing.equalToSuperview()
        }
                
        distanceLabel.snp.makeConstraints {
            $0.top.equalTo(durationLabel.snp.bottom).offset(4)
            $0.leading.equalTo(durationLabel.snp.leading)
            $0.height.equalTo(18)
        }
        
        leaveLabel.snp.makeConstraints {
            $0.top.equalTo(distanceLabel.snp.bottom)
            $0.leading.equalTo(durationLabel.snp.leading)
            $0.height.equalTo(18)
        }
        
        goButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(77)
            $0.height.equalTo(40)
            $0.centerY.equalToSuperview()
        }
        
        selectedViewButton.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.trailing.equalTo(goButton.snp.leading)
        }
        
        // loader view:
        loaderContainer.addSubview(firstLoaderView)
        loaderContainer.addSubview(secondLoaderView)
        loaderContainer.addSubview(thirdLoaderView)
        self.addSubview(loaderContainer)
        
        
        loaderContainer.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        firstLoaderView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(124)
            $0.height.equalTo(8)
        }
        
        secondLoaderView.snp.makeConstraints {
            $0.top.equalTo(firstLoaderView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(72)
            $0.height.equalTo(8)
        }
        
        thirdLoaderView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(72)
            $0.height.equalTo(16)
        }
    }
    
    func isDotViewVisible(_ state: Bool) {
        dotView.isHidden = !state
        selectedLabel.isHidden = !state
        if state {
            routeTypeImage.tintColor = .lsPrimary
            durationLabel.textColor = .lsPrimary
            dotView.backgroundColor = .lsPrimary
            selectedLabel.textColor = .lsPrimary
        }
        else {
            routeTypeImage.tintColor = .lsTetriary
            durationLabel.textColor = .lsTetriary
            dotView.backgroundColor = .lsTetriary
            selectedLabel.textColor = .lsTetriary
        }
    }
}
