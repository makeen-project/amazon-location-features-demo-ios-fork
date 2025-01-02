//
//  NavigationVCCell.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import AWSGeoRoutes

enum StepState {
    case first, last
}

struct NavigationCellModel {
    var stepState: StepState
    var instruction: String
    var distance: String
    var vehicleStep: GeoRoutesClientTypes.RouteVehicleTravelStep?
    var pedestrianStep: GeoRoutesClientTypes.RoutePedestrianTravelStep?
    
    init(model: NavigationPresentation, stepState: StepState? = .first) {
        self.vehicleStep = model.vehicleStep
        self.pedestrianStep = model.pedestrianStep
        self.distance = ""
        self.instruction = ""
        if let step = model.pedestrianStep {
            self.distance =  String(step.distance)
            self.instruction = step.instruction!
        }
        else if let step = model.vehicleStep {
            self.distance =  String(step.distance)
            self.instruction = step.instruction!
        }
        self.stepState = stepState ?? .first
    }
}

final class NavigationVCCell: UITableViewCell {
    static let reuseId: String = "navigationCell"
    
    private var containerView: UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var model: NavigationCellModel! {
        didSet {
            self.streetLabel.text = model.instruction
            self.distanceLabel.text = model.distance

            switch model.stepState {
            case .first:
                if let step = model.pedestrianStep {
                    self.stepImage.image = model.pedestrianStep?.type?.image
                }
                else if let step = model.vehicleStep {
                    self.stepImage.image = model.vehicleStep?.type?.image
                }
                stepLine.isHidden = false
            case .last:
                self.stepImage.image = .selectedPlace
                stepLine.isHidden = true
            }
        }
    }
    
    private var streetLabel: UILabel = {
        let label = UILabel()
        label.text = "2 min"
        label.textAlignment = .left
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .black
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var distanceLabel = {
        let label = UILabel()
        label.text = "300 m"
        label.textAlignment = .left
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .searchBarTintColor
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var stepLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lsPrimary
        return view
    }()
    
    private var stepImage: UIImageView = {
        let imageView = UIImageView(image: .stepIcon)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupView() {
        self.addSubview(containerView)
        containerView.addSubview(streetLabel)
        containerView.addSubview(distanceLabel)
        containerView.addSubview(stepImage)
        containerView.addSubview(stepLine)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        streetLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(52)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.top.equalTo(streetLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(52)
            $0.height.equalTo(18)
        }
        
        stepImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalToSuperview().offset(20.5)
            $0.height.width.equalTo(16)
        }
        
        stepLine.snp.makeConstraints {
            $0.top.equalTo(stepImage.snp.bottom)
            $0.centerX.equalTo(stepImage.snp.centerX)
            $0.height.equalTo(49)
            $0.width.equalTo(4)
        }
    }
}
