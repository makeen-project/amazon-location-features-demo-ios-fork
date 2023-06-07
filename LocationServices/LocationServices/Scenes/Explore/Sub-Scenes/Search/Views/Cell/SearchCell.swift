//
//  SearchCell.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

struct SearchCellStyle {
    var backgroundColor: UIColor
    
    init(style: DirectionScreenStyle) {
        self.backgroundColor = style.backgroundColor
    }
    
    init(style: SearchScreenStyle) {
        self.backgroundColor = style.backgroundColor
    }
}

final class SearchCell: UITableViewCell {
    static let reuseId: String = "SearchCell"
    
    private let containerView: UIView = UIView()
    private let contentCellView: UIView = UIView()
    
    var model: SearchCellViewModel! {
        didSet {
            switch model.searchType {
            case .location:
                self.searchTypeImage.image = .searchResultPinIcon
            case .search:
                self.searchTypeImage.image = UIImage(systemName: "magnifyingglass")
            case .mylocation:
                self.searchTypeImage.image = .locateMeMapIcon
            }
            
            self.locationTitle.text = model.locationName
            
            // for suggestions we have city and country just after name
            if let city = model.locationCity, let country = model.locationCountry {
                self.locationAddress.text = "\(city), \(country)"
                self.locationTitle.text = model.locationName
            } else if model.label != model.locationName {
                self.locationAddress.text = model.label
            }
            
            if let distance = model.locationDistance {
                self.locationDistance.isHidden = false
                self.locationDistance.text = distance.convertToKm()
            } else {
                self.locationDistance.isHidden = true
                self.locationAddress.isHidden = true
                // updateConstraintsForTitle(shouldAlingCenter: true)
            }
        }
    }
    
    private let searchTypeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .searchBarTintColor
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let locationTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .amazonFont(type: .regular, size: 16)
        label.textColor = .tertiaryColor
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    private let locationAddress: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = ViewsIdentifiers.Search.cellAddressLabel
        label.textAlignment = .left
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .gray
        label.numberOfLines = 2
        return label
    }()
    
    private let locationDistance: UILabel = {
        let label = UILabel()
        label.font = .amazonFont(type: .regular, size: 13)
        label.textAlignment = .right
        label.textColor = .tertiaryColor
        label.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellProperties()
        setupViews()
    }
    
    func updateConstraintsForTitle(shouldAlingCenter: Bool) {
        if shouldAlingCenter {
            locationTitle.snp.remakeConstraints {
                $0.leading.equalToSuperview()
                $0.centerY.equalTo(searchTypeImage.snp.centerY)
                $0.trailing.lessThanOrEqualToSuperview().offset(-12)
            }
            locationAddress.snp.remakeConstraints{
                $0.width.equalTo(0)
                $0.height.equalTo(0)
            }
        } else {
            locationTitle.snp.remakeConstraints {
                $0.top.equalToSuperview()
                $0.trailing.lessThanOrEqualTo(locationDistance.snp.leading).offset(-8)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        searchTypeImage.image = nil
        locationTitle.text = nil
        locationAddress.text = nil
        locationDistance.text = nil
    }
    
    func applyStyles(style: SearchCellStyle) {
        backgroundColor = style.backgroundColor
    }
}

private extension SearchCell {
    func setupCellProperties() {
        self.backgroundColor = .searchBarBackgroundColor
        self.selectionStyle = .none
    }
    
    func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(contentCellView)
        containerView.addSubview(searchTypeImage)
        contentCellView.addSubview(locationTitle)
        contentCellView.addSubview(locationAddress)
        contentCellView.addSubview(locationDistance)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        contentCellView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalTo(searchTypeImage.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(10)
        }
        
        searchTypeImage.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
        }
        
        locationDistance.snp.makeConstraints {
            $0.centerY.equalTo(locationTitle.snp.centerY)
            $0.trailing.equalToSuperview()
        }
        
        locationTitle.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(locationDistance.snp.leading).offset(-12)
        }

        locationAddress.snp.makeConstraints {
            $0.top.equalTo(locationTitle.snp.bottom).offset(5)
            $0.leading.equalTo(locationTitle.snp.leading)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
}
