//
//  DirectionView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

struct DirectionVM {
    var carTypeDistane: String = ""
    var carTypeDuration: String = ""
    var scooterTypeDuration: String = ""
    var scooterTypeDistance: String = ""
    var walkingTypeDuration: String = ""
    var walkingTypeDistance: String = ""
    var truckTypeDistance: String = ""
    var truckTypeDuration: String = ""
}

struct LeaveOptions {
    var leaveNow: Bool = true
    var leaveTime: Date? = nil
    var arrivalTime: Date? = nil
}

final class DirectionView: UIView {
    var delegate: DirectionViewOutputDelegate?
    
    private var isPreview = false
    
    private var model: DirectionVM!
    
    private var routeOptionHeight = NumberConstants.routeOptionHeight

    private var routeOptions: RouteOptionsView = RouteOptionsView()
    
    var avoidFerries: BoolHandler?
    var avoidTolls: BoolHandler?
    var avoidUturns: BoolHandler?
    var avoidTunnels: BoolHandler?
    var avoidDirtRoads: BoolHandler?
    var leaveOptionsHandler: Handler<LeaveOptions>?
    
    private var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = true
        return view
    }()
    
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.lsLight2.cgColor
        view.layer.borderWidth = 1
        view.layer.masksToBounds = true
        return view
    }()
    
    private var carRouteTypeView: RouteTypeView = RouteTypeView(viewType: .car, isSelected: true)
    private var carSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        return view
    }()
    private var pedestrianRouteTypeView: RouteTypeView = RouteTypeView(viewType: .pedestrian)
    private var pedestrianSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        return view
    }()
    private var scooterRouteTypeView: RouteTypeView = RouteTypeView(viewType: .scooter)
    private var scooterSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        return view
    }()
    private var truckRouteTypeView: RouteTypeView = RouteTypeView(viewType: .truck)
    
    private var routeTypeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.isHidden = true
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 1
        return stackView
    }()
    
    private let distanceErrorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = StringConstant.greatDistanceErrorTitle
        label.textColor = .lsTetriary
        label.font = .amazonFont(type: .bold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let distanceErrorMessageLabel: UILabel = {
        let label = UILabel()
        label.text = StringConstant.greatDistanceErrorMessage
        label.numberOfLines = 2
        label.textColor = .lsGrey
        label.font = .amazonFont(type: .regular, size: 13)
        label.textAlignment = .center
        return label
    }()
    
    private var errorIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.triangle")
        imageView.tintColor = .searchBarTintColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var errorContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .clear
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.accessibilityIdentifier = ViewsIdentifiers.Routing.routeTypesContainer
        routeOptions.changeRouteOptionHeight = { [weak self] value in
            self?.routeOptionHeight = value
            self?.updateRouteOptionHeight()
        }
        
        setupViews()
        setupHandlers()
        setupErrorViews()
    }
    
    func setLocalValues(toll: Bool, ferries: Bool, uturns: Bool, tunnels: Bool, dirtRoads: Bool) {
        routeOptions.setLocalValues(toll: toll, ferries: ferries, uturns: uturns, tunnels: tunnels, dirtRoads: dirtRoads)
    }
    
    func setup(model: DirectionVM, isPreview: Bool, routeType: RouteTypes) {
        self.isPreview = isPreview
        if self.model == nil {
            self.model = DirectionVM()
        }
        switch routeType {
        case .car:
            self.model.carTypeDistane = model.carTypeDistane
            self.model.carTypeDuration = model.carTypeDuration
            carRouteTypeView.setDatas(distance: model.carTypeDistane, duration: model.carTypeDuration, isPreview: isPreview)
        case .pedestrian:
            self.model.walkingTypeDistance = model.walkingTypeDistance
            self.model.walkingTypeDuration = model.walkingTypeDuration
            pedestrianRouteTypeView.setDatas(distance: model.walkingTypeDistance, duration: model.walkingTypeDuration, isPreview: isPreview)
        case .scooter:
            self.model.scooterTypeDistance = model.scooterTypeDistance
            self.model.scooterTypeDuration = model.scooterTypeDuration
            scooterRouteTypeView.setDatas(distance: model.scooterTypeDistance, duration: model.scooterTypeDuration, isPreview: isPreview)
        case .truck:
            self.model.scooterTypeDistance = model.truckTypeDistance
            self.model.truckTypeDuration = model.truckTypeDuration
            truckRouteTypeView.setDatas(distance: model.truckTypeDistance, duration: model.truckTypeDuration, isPreview: isPreview)
        }
    }
    
    func showOptionsStackView() {
        routeTypeStackView.isHidden = false
        errorContainer.isHidden = true
    }
    
    func showErrorStackView() {
        routeTypeStackView.isHidden = true
        errorContainer.isHidden = false
    }
    
    private func setupHandlers() {
        carRouteTypeView.isSelectedHandle = { [weak self] state in
            self?.changeSelectedTextFor(carType: state)
            Task {
                try await self?.delegate?.changeRoute(type: .car)
            }
        }
        
        carRouteTypeView.goButtonHandler =  { [weak self] in
            self?.delegate?.startNavigation(type: .car)
        }
        
        pedestrianRouteTypeView.isSelectedHandle = { [weak self] state in
            self?.changeSelectedTextFor(walkingType: state)
            Task {
                try await self?.delegate?.changeRoute(type: .pedestrian)
            }
        }
        
        pedestrianRouteTypeView.goButtonHandler =  { [weak self]  in
            self?.delegate?.startNavigation(type: .pedestrian)
        }
        
        scooterRouteTypeView.isSelectedHandle = { [weak self] state in
            self?.changeSelectedTextFor(scooterType: state)
            Task {
                try await self?.delegate?.changeRoute(type: .scooter)
            }
        }
        
        scooterRouteTypeView.goButtonHandler =  { [weak self]  in
            self?.delegate?.startNavigation(type: .scooter)
        }
        
        truckRouteTypeView.isSelectedHandle = { [weak self] state in
            self?.changeSelectedTextFor(truckType: state)
            Task {
                try await self?.delegate?.changeRoute(type: .truck)
            }
        }
        
        truckRouteTypeView.goButtonHandler =  { [weak self]  in
            self?.delegate?.startNavigation(type: .truck)
        }
        
        routeOptions.avoidTolls = { [weak self] state in
            self?.avoidTolls?(state)
        }
        
        routeOptions.avoidFerries = { [weak self] state in
            self?.avoidFerries?(state)
        }
        
        routeOptions.avoidUturns = { [weak self] state in
            self?.avoidUturns?(state)
        }
        
        routeOptions.avoidTunnels = { [weak self] state in
            self?.avoidTunnels?(state)
        }
        
        routeOptions.avoidDirtRoads = { [weak self] state in
            self?.avoidDirtRoads?(state)
        }
        
        routeOptions.leaveOptionHandler = { [weak self] options in
            self?.leaveOptionsHandler?(options)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateRouteContainerConstraint(_:)), name: Notification.updateMapLayerItems, object: nil)
    }
    
    @objc private func updateRouteContainerConstraint(_ notification: Notification) {
        let height = (notification.userInfo?["height"] as? CGFloat) ?? NumberConstants.routeContainerHeightConstraint
        if(height < NumberConstants.routeContainerHeightConstraint) {
            routeOptions.isHidden = true
            containerView.isHidden = true
        }
        else {
            routeOptions.isHidden = false
            containerView.isHidden = false
        }
    }
    
    private func changeSelectedTextFor(carType: Bool = false,
                                       walkingType: Bool = false,
                                       scooterType: Bool = false,
                                       truckType: Bool = false) {
        carRouteTypeView.isDotViewVisible(carType)
        pedestrianRouteTypeView.isDotViewVisible(walkingType)
        scooterRouteTypeView.isDotViewVisible(scooterType)
        truckRouteTypeView.isDotViewVisible(truckType)
    }
    
    private func updateRouteOptionHeight() {
        routeOptions.snp.updateConstraints {
            $0.height.equalTo(routeOptionHeight)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        carRouteTypeView.accessibilityIdentifier = ViewsIdentifiers.Routing.carContainer
        pedestrianRouteTypeView.accessibilityIdentifier = ViewsIdentifiers.Routing.pedestrianContainer
        scooterRouteTypeView.accessibilityIdentifier = ViewsIdentifiers.Routing.scooterContainer
        truckRouteTypeView.accessibilityIdentifier = ViewsIdentifiers.Routing.truckContainer
        
        routeTypeStackView.removeArrangedSubViews()
        routeTypeStackView.addArrangedSubview(carRouteTypeView)
        routeTypeStackView.addArrangedSubview(carSeperatorView)
        routeTypeStackView.addArrangedSubview(pedestrianRouteTypeView)
        routeTypeStackView.addArrangedSubview(pedestrianSeperatorView)
        routeTypeStackView.addArrangedSubview(scooterRouteTypeView)
        routeTypeStackView.addArrangedSubview(scooterSeperatorView)
        routeTypeStackView.addArrangedSubview(truckRouteTypeView)
    
        self.addSubview(scrollView)
        scrollView.addSubview(routeOptions)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(routeTypeStackView)
    
//        self.snp.makeConstraints {
//            $0.height.equalToSuperview()
//        }
        
        scrollView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalToSuperview()
        }
        
        routeOptions.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(routeOptions.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.lessThanOrEqualToSuperview()
        }
        
        carRouteTypeView.snp.makeConstraints {
            $0.height.equalTo(72)
        }
        
        carSeperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        pedestrianRouteTypeView.snp.makeConstraints {
            $0.height.equalTo(72)
        }
        
        pedestrianSeperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        scooterRouteTypeView.snp.makeConstraints {
            $0.height.equalTo(72)
        }
        
        scooterSeperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        truckRouteTypeView.snp.makeConstraints {
            $0.height.equalTo(72)
        }
        
        routeTypeStackView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupErrorViews() {
        containerView.addSubview(errorContainer)
        errorContainer.addSubview(errorIconImageView)
        errorContainer.addSubview(distanceErrorTitleLabel)
        errorContainer.addSubview(distanceErrorMessageLabel)
        
        errorContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        errorIconImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(40)
        }
        
        distanceErrorTitleLabel.snp.makeConstraints {
            $0.top.equalTo(errorIconImageView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        distanceErrorMessageLabel.snp.makeConstraints {
            $0.top.equalTo(distanceErrorTitleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
    }
}
