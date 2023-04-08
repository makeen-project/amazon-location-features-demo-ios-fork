//
//  TrackHistoryCell.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

struct TrackHistoryCellModel {
    var stepType: StepType
    var coordinates: String
    var time: String
    var date: String
    
    init(model: TrackingHistoryPresentation) {
        self.coordinates = model.cooordinates
        self.time = model.time
        self.date = model.date
        self.stepType = model.stepType
    }
}

final class TrackHistoryCell: UITableViewCell {
    static let reuseId: String = "trackingHistoryCell"
    
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    
    var model: TrackHistoryCellModel! {
        didSet {
            self.coordinateLabel.text = model.coordinates
            self.timeLabel.text = model.time
            stepImage.image = .stepIcon
            
            switch model.stepType {
            case .first:
                stepLineStackView.isHidden = false
            case .last:
                stepLineStackView.isHidden = true
            }
        }
    }
    
    private var coordinateLabel: UILabel = {
        let label = UILabel()
        label.text = StringConstant.coordinateLabelText
        label.textAlignment = .left
        label.font = .amazonFont(type: .medium, size: 13)
        label.textColor = .black
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var timeLabel = {
        let label = UILabel()
        label.text = StringConstant.timeLabelText
        label.textAlignment = .left
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .searchBarTintColor
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var informationStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillEqually
        return sv
    }()
    
    private var stepLine: UIView = {
        let view = UIView()
        view.backgroundColor = .mapElementDiverColor
        view.layer.cornerRadius = 4
        return view
    }()
    
    private var stepBottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .mapElementDiverColor
        view.layer.cornerRadius = 4
        return view
    }()
    
    private var stepTopLine: UIView = {
        let view = UIView()
        view.backgroundColor = .mapElementDiverColor
        view.layer.cornerRadius = 4
        return view
    }()
    
    private var stepLineStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .equalSpacing
        return sv
    }()
    
    private var stepImage: UIImageView = {
        let imageView = UIImageView(image: .stepIcon)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    
    private func setupViews() {
        
        informationStackView.removeArrangedSubViews()
        informationStackView.addArrangedSubview(coordinateLabel)
        informationStackView.addArrangedSubview(timeLabel)
        
        stepLineStackView.removeArrangedSubViews()
        stepLineStackView.addArrangedSubview(stepLine)
        stepLineStackView.addArrangedSubview(stepBottomLine)
        stepLineStackView.addArrangedSubview(stepTopLine)
        
        
        self.addSubview(containerView)
        containerView.addSubview(informationStackView)
        containerView.addSubview(stepImage)
        containerView.addSubview(stepLineStackView)
        
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(8)
            $0.bottom.trailing.equalToSuperview()
        }
        
        informationStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview().offset(36)
            $0.bottom.equalToSuperview().offset(-5)
            $0.trailing.equalToSuperview()
        }
        
        stepLine.snp.makeConstraints {
            $0.height.width.equalTo(8)
        }
        
        stepBottomLine.snp.makeConstraints {
            $0.height.width.equalTo(8)
        }
        
        stepTopLine.snp.makeConstraints {
            $0.height.width.equalTo(8)
        }
        
        stepImage.snp.makeConstraints {
            $0.top.equalTo(informationStackView.snp.centerY)
            $0.leading.equalToSuperview()
            $0.height.width.equalTo(16)
        }
        
        stepLineStackView.snp.makeConstraints {
            $0.top.equalTo(stepImage.snp.bottom).offset(4)
            $0.centerX.equalTo(stepImage.snp.centerX)
            $0.height.equalTo(35)
            $0.width.equalTo(8)
        }
    }
    
}
