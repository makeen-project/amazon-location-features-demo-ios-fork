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
    var ferryStep: GeoRoutesClientTypes.RouteFerryTravelStep?
    
    init(model: NavigationPresentation, stepState: StepState? = .first) {
        self.vehicleStep = model.vehicleStep
        self.pedestrianStep = model.pedestrianStep
        self.ferryStep = model.ferryStep
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
    
    func getStepImage() -> UIImage? {
        if let step = self.pedestrianStep {
            return step.image
        }
        else if let step = self.ferryStep {
            return step.image
        }
        else if let step = self.vehicleStep {
            return step.image
        }
        return nil
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
            self.distanceLabel.text = model.distance+" m"

            switch model.stepState {
            case .first, .last:
                self.stepImage.image = model.getStepImage()?.withTintColor(.lsPrimary)
                stepLine.isHidden = false
                if model.stepState == .last {
                    stepLine.isHidden = true
                }
            }
        }
    }
    
    private var streetLabel: UILabel = {
        let label = UILabel()
        label.text = "2 min"
        label.textAlignment = .left
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .lsTetriary
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var distanceLabel = {
        let label = UILabel()
        label.text = "300 m"
        label.textAlignment = .left
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .lsGrey
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var stepLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lsLight3
        return view
    }()
    
    private var stepImage: UIImageView = {
        let imageView = UIImageView(image: .stepIcon)
        imageView.tintColor = .lsPrimary
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
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview().offset(52)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.top.equalTo(streetLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(52)
            $0.height.equalTo(18)
        }
        
        stepImage.snp.makeConstraints {
            $0.centerY.equalTo(streetLabel.snp.centerY)
            $0.leading.equalToSuperview().offset(20.5)
            $0.height.equalTo(24)
        }
        
        stepLine.snp.makeConstraints {
            $0.centerX.equalTo(stepImage.snp.centerX)
            //$0.top.equalTo(distanceLabel.snp.top)
            //$0.bottom.equalTo(distanceLabel.snp.bottom).offset(5)
            $0.centerY.equalTo(distanceLabel.snp.centerY)
            $0.width.equalTo(2)
            $0.height.equalTo(16)
        }
    }
}
