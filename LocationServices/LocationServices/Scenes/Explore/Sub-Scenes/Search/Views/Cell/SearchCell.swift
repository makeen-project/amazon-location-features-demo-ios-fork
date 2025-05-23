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
    static let reuseCompactId: String = "SearchCompactCell"
    
    private let containerView: UIView = UIView()
    private let contentCellView: UIView = UIView()
    private let subView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
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
            
            if model.searchType == .location {
                self.subView.isHidden = false
                self.locationDistance.text = model.locationDistance?.formatDistance()
                subView.snp.remakeConstraints {
                    $0.top.equalTo(locationTitle.snp.bottom).offset(5)
                    $0.leading.trailing.equalToSuperview()
                    $0.bottom.equalTo(contentCellView.snp.bottom)
                    $0.height.equalTo(18)
                }
            } else {
                self.subView.isHidden = true
                updateConstraintsForTitle(shouldAlingCenter: true)
                subView.snp.remakeConstraints{
                    $0.width.equalTo(0)
                    $0.height.equalTo(0)
                }
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
        label.applyLocaleDirection()
        label.font = .amazonFont(type: .regular, size: 16)
        label.textColor = .tertiaryColor
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    private let locationAddress: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = ViewsIdentifiers.Search.cellAddressLabel
        label.applyLocaleDirection()
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .gray
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let locationDistance: UILabel = {
        let label = UILabel()
        label.font = .amazonFont(type: .regular, size: 13)
        label.applyLocaleDirection()
        label.textColor = .gray
        label.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        return label
    }()
    
    private let dotView: UIView = {
        let view = UIView()
        view.backgroundColor = .lsGrey
        view.layer.cornerRadius = 5
        return view
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
        } else {
            locationTitle.snp.remakeConstraints {
                $0.leading.equalToSuperview()
                $0.top.equalToSuperview()
                $0.trailing.lessThanOrEqualToSuperview().offset(-12)
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
        contentCellView.addSubview(subView)
        subView.addSubview(locationDistance)
        subView.addSubview(dotView)
        subView.addSubview(locationAddress)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        contentCellView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalTo(searchTypeImage.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        searchTypeImage.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.leading.equalToSuperview().offset(32)
            $0.centerY.equalToSuperview()
        }
        
        locationTitle.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        subView.snp.makeConstraints {
            $0.top.equalTo(locationTitle.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(contentCellView.snp.bottom)
            $0.height.equalTo(18)
        }
        
        locationDistance.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
        }

        dotView.snp.makeConstraints {
            $0.leading.equalTo(locationDistance.snp.trailing).offset(5)
            $0.height.width.equalTo(5)
            $0.centerY.equalTo(locationDistance.snp.centerY)
        }
        
        locationAddress.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(dotView.snp.trailing).offset(5)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
}

extension SearchCell {
    func hideDistance() {
        locationDistance.isHidden = true
        dotView.isHidden = true
        locationAddress.snp.remakeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
}
