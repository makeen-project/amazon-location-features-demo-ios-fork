//
//  MapStyleCell.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

struct MapStyleCellModel {
    var title: String
    var image: UIImage
    var identifier: String
    
    init(model: MapStyleModel) {
        self.title = model.title
        self.image = model.imageType.image
        self.identifier = model.imageType.mapName
    }
}

final class MapStyleCell: UICollectionViewCell {
    static let reuseId: String = "mapStyleCell"
    var model: MapStyleCellModel! {
        didSet {
            accessibilityIdentifier = model.identifier
            self.titleLabel.text = model.title
            self.mapImage.image = model.image
        }
    }
    
    private var containerView: UIView = UIView()
    
    private var mapImage: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        return iv
    }()
    
    private var titleLabel: UILabel = {
        var label = UILabel()
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .mapDarkBlackColor
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isAccessibilityElement = true
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    func isCellSelected(state: Bool) {
        if state {
            accessibilityTraits = [.selected]
            mapImage.layer.borderWidth = 1
            mapImage.layer.borderColor = UIColor.lsPrimary.cgColor
            titleLabel.textColor = .lsPrimary
        } else {
            accessibilityTraits = []
            mapImage.layer.borderWidth = 0
            titleLabel.textColor = .mapDarkBlackColor
        }
    }
    
    
    private func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(mapImage)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(1)
            $0.leading.equalToSuperview().offset(1)
            $0.trailing.equalToSuperview().offset(-1)
            $0.bottom.equalToSuperview().offset(-1)
        }
        
        mapImage.snp.makeConstraints {
            $0.height.equalTo(80)
            $0.top.leading.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(mapImage.snp.bottom).offset(8)
            $0.height.equalTo(18)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
