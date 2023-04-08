//
//  SearchCell.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class SearchCell: UITableViewCell {
    static let reuseId: String = "SearchCell"
    
    private let continerView: UIView = UIView()
    
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
                self.dotView.isHidden = false
                self.locationDistance.isHidden = false
                self.locationDistance.text = distance.convertToKm()
                updateConstraitForAddress(shouldAlingLeft: false)
            } else {
                self.dotView.isHidden = true
                self.locationDistance.isHidden = true
                updateConstraitForAddress(shouldAlingLeft: true)
            }
    
            if locationAddress.text == nil  {
                updateConstraintsForTitle(shouldAlingCenter: true)
            } else {
                updateConstraintsForTitle(shouldAlingCenter: false, withAddress: true)
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
        label.textColor = .black
        return label
    }()
    
    private let locationAddress: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = ViewsIdentifiers.Search.cellAddressLabel
        label.textAlignment = .left
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .searchBarTintColor
        label.numberOfLines = 2
        return label
    }()
    
    private let locationDistance: UILabel = {
        let label = UILabel()
        label.font = .amazonFont(type: .regular, size: 13)
        label.textAlignment = .left
        label.textColor = .searchBarTintColor
        label.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        return label
    }()
    
    private let dotView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarTintColor
        view.layer.cornerRadius = 3
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellProperties()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        searchTypeImage.image = nil
        locationTitle.text = nil
        locationAddress.text = nil
        locationDistance.text = nil
    }
}

private extension SearchCell {
    func setupCellProperties() {
        self.backgroundColor = .searchBarBackgroundColor
        self.selectionStyle = .none
    }
    
    func updateConstraintsForTitle(shouldAlingCenter: Bool, withAddress: Bool = false) {
        if shouldAlingCenter {
            locationTitle.snp.remakeConstraints {
                $0.leading.equalTo(searchTypeImage.snp.trailing).offset(16)
                $0.trailing.equalToSuperview().offset(-12)
                $0.top.equalToSuperview().offset(12)
                $0.bottom.equalToSuperview().offset( withAddress ? -35 : -12 )
            }
        } else {
            locationTitle.snp.remakeConstraints {
                $0.leading.equalTo(searchTypeImage.snp.trailing).offset(16)
                $0.trailing.equalToSuperview().offset(-12)
                $0.top.equalToSuperview().offset(6)
                $0.bottom.equalToSuperview().offset( withAddress ? -35 : -12 )
            }
            
        }
        
    }
    
    func updateConstraitForAddress(shouldAlingLeft: Bool) {
        if shouldAlingLeft {
            locationAddress.snp.remakeConstraints {
                $0.trailing.equalToSuperview().offset(-12)
                $0.leading.equalTo(locationTitle.snp.leading)
                $0.width.greaterThanOrEqualTo(200)
                $0.top.equalTo(locationTitle.snp.bottom)
            }
        } else {
            locationAddress.snp.remakeConstraints {
                $0.trailing.equalToSuperview().offset(-12)
                $0.leading.equalTo(dotView.snp.trailing).offset(4)
                $0.centerY.equalTo(locationDistance.snp.centerY)
                $0.width.greaterThanOrEqualTo(200)
            }
        }
    }
    
    func setupViews() {
        self.addSubview(continerView)
        continerView.addSubview(searchTypeImage)
        continerView.addSubview(locationTitle)
        continerView.addSubview(dotView)
        continerView.addSubview(locationAddress)
        continerView.addSubview(locationDistance)
        
        continerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        searchTypeImage.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
        }
        
        locationTitle.snp.makeConstraints {
            $0.leading.equalTo(searchTypeImage.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-12)
            $0.top.equalToSuperview().offset(6)
        }
        
        dotView.snp.makeConstraints {
            $0.leading.equalTo(locationDistance.snp.trailing).offset(4)
            $0.height.width.equalTo(3)
            $0.centerY.equalTo(locationDistance.snp.centerY)
        }
        
        locationAddress.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.leading.equalTo(dotView.snp.trailing).offset(4)
            $0.centerY.equalTo(locationDistance.snp.centerY)
            $0.width.greaterThanOrEqualTo(200)
        }
       
        locationDistance.snp.makeConstraints {
            $0.leading.equalTo(locationTitle.snp.leading)
            $0.trailing.equalTo(dotView.snp.leading).offset(-4)
            $0.top.equalTo(locationTitle.snp.bottom).offset(2)
            $0.bottom.equalToSuperview().offset(-11)
        }
    }
}
