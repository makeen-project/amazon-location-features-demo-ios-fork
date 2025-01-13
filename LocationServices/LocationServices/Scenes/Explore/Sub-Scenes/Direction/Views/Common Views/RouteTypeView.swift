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
        iv.tintColor = .searchBarTintColor
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
        label.accessibilityIdentifier = ViewsIdentifiers.Routing.routeEstimatedTime
        label.font = .amazonFont(type: .regular, size: 16)
        label.textColor = .black
        label.textAlignment = .right
        label.text = ""
        label.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(749), for: .horizontal)
        return label
    }()
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = ViewsIdentifiers.Routing.routeEstimatedDistance
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .searchBarTintColor
        label.text = ""
        label.textAlignment = .left
        return label
    }()
    
    private lazy var routeTypeTitle: UILabel = {
        let label = UILabel()
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .mapDarkBlackColor
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
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .searchBarTintColor
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(UILayoutPriority(748), for: .horizontal)
        return label
    }()
    
    convenience init(viewType: RouteTypes, isSelected: Bool = false) {
        self.init(frame: .zero)
        self.routeTypeImage.image = viewType.image
        self.routeTypeTitle.text = viewType.title
        isDotViewVisible(isSelected)
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    @objc func routeTypeChanged() {
        isSelectedHandle?(true)
    }
    
    @objc func startNavigation() {
       goButtonHandler?()
    }
    
    func setDatas(distance: String, duration: String, isPreview: Bool) {
        self.distanceLabel.text = distance
        self.durationLabel.text = duration
        
        let isGoButtonEnabled = !distance.isEmpty && !duration.isEmpty
        self.goButton.alpha = isGoButtonEnabled ? 1 : 0.3
        self.goButton.isEnabled = isGoButtonEnabled
        self.isUserInteractionEnabled = isGoButtonEnabled
        let goButtonTitle = isPreview ? StringConstant.preview : StringConstant.go
        self.goButton.setTitle(goButtonTitle, for: .normal)
        self.layoutIfNeeded()
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
        leftContainerView.addSubview(routeTypeTitle)
        leftContainerView.addSubview(dotView)
        leftContainerView.addSubview(selectedLabel)
        leftContainerView.addSubview(distanceLabel)
        
        containerView.addSubview(goButton)
        containerView.addSubview(durationLabel)
        containerView.addSubview(selectedViewButton)
        
        containerView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        routeTypeImage.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
        }
        
        leftContainerView.snp.makeConstraints {
            $0.centerY.equalTo(routeTypeImage.snp.centerY)
            $0.leading.equalTo(routeTypeImage.snp.trailing).offset(10)
        }
        
        routeTypeTitle.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        dotView.snp.makeConstraints {
            $0.leading.equalTo(routeTypeTitle.snp.trailing).offset(4)
            $0.height.width.equalTo(3)
            $0.centerY.equalTo(routeTypeTitle.snp.centerY)
        }
    
        selectedLabel.snp.makeConstraints {
            $0.leading.equalTo(dotView.snp.trailing).offset(4)
            $0.height.equalTo(18)
            $0.centerY.equalTo(routeTypeTitle.snp.centerY)
            $0.trailing.equalToSuperview()
        }
                
        distanceLabel.snp.makeConstraints {
            $0.top.equalTo(routeTypeTitle.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(18)
        }
        
        goButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)
            $0.width.equalTo(77)
            $0.height.equalTo(40)
            $0.centerY.equalToSuperview()
        }
        
        selectedViewButton.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.trailing.equalTo(goButton.snp.leading)
        }
        
        durationLabel.snp.makeConstraints {
            $0.trailing.equalTo(goButton.snp.leading).offset(-10)
            $0.height.equalTo(28)
            $0.centerY.equalTo(goButton.snp.centerY)
            $0.leading.equalTo(leftContainerView.snp.trailing).offset(5)
        }

    }
    
    func isDotViewVisible(_ state: Bool) {
        dotView.isHidden = !state
        selectedLabel.isHidden = !state
    }
}
