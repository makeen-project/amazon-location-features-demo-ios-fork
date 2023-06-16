//
//  DirectionView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

struct DirectionVM {
    var carTypeDistane: String
    var carTypeDuration: String
    var walkingTypeDuration: String
    var walkingTypeDistance: String
    var truckTypeDistance: String
    var truckTypeDuration: String
}

final class DirectionView: UIView {
    var delegate: DirectionViewOutputDelegate?
    
    private var isPreview = false
    
    private var model: DirectionVM! {
        didSet {
            carRouteTypeView.setDatas(distance: model.carTypeDistane, duration: model.carTypeDuration, isPreview: isPreview)
            walkRouteTypeView.setDatas(distance: model.walkingTypeDistance, duration: model.walkingTypeDuration, isPreview: isPreview)
            truckRouteTypeView.setDatas(distance: model.truckTypeDistance, duration: model.truckTypeDuration, isPreview: isPreview)
        }
    }
    
    private var routeOptionHeight = 32

    private var routeOptions: RouteOptionsView = RouteOptionsView()
    
    var avoidFerries: BoolHandler?
    var avoidTolls: BoolHandler?
    
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
    private var walkRouteTypeView: RouteTypeView = RouteTypeView(viewType: .walking)
    private var walkingSeperatorView: UIView = {
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
        setupHandlers()
        setupViews()
        setupErrorViews()
    }
    
    func setLocalValues(toll: Bool, ferries: Bool) {
        routeOptions.setLocalValues(toll: toll, ferries: ferries)
    }
    
    func setup(model: DirectionVM, isPreview: Bool) {
        self.isPreview = isPreview
        self.model = model
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
            self?.delegate?.changeRoute(type: .car)
        }
        
        carRouteTypeView.goButtonHandler =  { [weak self] in
            self?.delegate?.startNavigation(type: .car)
    
        }
        
        walkRouteTypeView.isSelectedHandle = { [weak self] state in
            self?.changeSelectedTextFor(walkingType: state)
            self?.delegate?.changeRoute(type: .walking)
        }
        
        walkRouteTypeView.goButtonHandler =  { [weak self]  in
            self?.delegate?.startNavigation(type: .walking)
            
        }
        
        truckRouteTypeView.isSelectedHandle = { [weak self] state in
            self?.changeSelectedTextFor(truckType: state)
            self?.delegate?.changeRoute(type: .truck)
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
        
    }
    
    private func changeSelectedTextFor(carType: Bool = false,
                                       walkingType: Bool = false,
                                       truckType: Bool = false) {
        carRouteTypeView.isDotViewVisible(carType)
        walkRouteTypeView.isDotViewVisible(walkingType)
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
        walkRouteTypeView.accessibilityIdentifier = ViewsIdentifiers.Routing.walkContainer
        truckRouteTypeView.accessibilityIdentifier = ViewsIdentifiers.Routing.truckContainer
        
        routeTypeStackView.removeArrangedSubViews()
        routeTypeStackView.addArrangedSubview(carRouteTypeView)
        routeTypeStackView.addArrangedSubview(carSeperatorView)
        routeTypeStackView.addArrangedSubview(walkRouteTypeView)
        routeTypeStackView.addArrangedSubview(walkingSeperatorView)
        routeTypeStackView.addArrangedSubview(truckRouteTypeView)
        
        self.addSubview(routeOptions)
        self.addSubview(containerView)
        containerView.addSubview(routeTypeStackView)
    
        routeOptions.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(routeOptions.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(219)
        }
        
        carRouteTypeView.snp.makeConstraints {
            $0.height.equalTo(72)
        }
        
        carSeperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        walkRouteTypeView.snp.makeConstraints {
            $0.height.equalTo(72)
        }
        
        walkingSeperatorView.snp.makeConstraints {
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
