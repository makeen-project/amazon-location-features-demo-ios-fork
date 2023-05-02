//
//  AmazonCustomSelectableView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

private enum CustomSelectableConstants {
    static let circleImage = UIImage(systemName: "circle.fill")
    static let checkMarkImage = UIImage(systemName: "checkmark.circle.fill")
}

final class AmazonCustomSelectableView: UIView {
    private var containerView: UIView = UIView()
    private var title: UILabel = {
        var label = UILabel()
        label.font = .amazonFont(type: .regular, size: 16)
        label.textColor = .mapDarkBlackColor
        label.textAlignment = .left
        return label
    }()
    
    private var subtitle: UILabel = {
        var label = UILabel()
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .searchBarTintColor
        label.textAlignment = .left
        return label
    }()
    
    private var selectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(CustomSelectableConstants.circleImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .searchBarBackgroundColor
        button.layer.borderColor = UIColor.searchBarTintColor.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        return button
    }()
    
    private var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(title: String, subTitle: String?, isSelected: Bool = false) {
        self.init(frame: .zero)
        self.isAccessibilityElement = true
        setupViews()
        assignValues(title: title, subTitle: subTitle, isSelected: isSelected)
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func assignValues(title: String, subTitle: String?, isSelected: Bool) {
        accessibilityIdentifier = title
        self.title.text = title
        self.subtitle.text = subTitle
        self.subtitle.isHidden = subTitle != nil ? false : true
        if isSelected {
            selectionButton.setImage(CustomSelectableConstants.checkMarkImage, for: .normal)
            selectionButton.tintColor = .lsPrimary
            selectionButton.layer.borderWidth = 1
            selectionButton.layer.borderColor = UIColor.lsPrimary.cgColor
        } else {
            selectionButton.setImage(CustomSelectableConstants.circleImage, for: .normal)
            selectionButton.tintColor = .searchBarBackgroundColor
            selectionButton.layer.borderWidth = 1
            selectionButton.layer.borderColor = UIColor.searchBarTintColor.cgColor
        }
        
        setupViews()
    }
    
    func setValues(title: String, isSelected: Bool) {
        accessibilityIdentifier = title
        self.title.text = title
        self.subtitle.isHidden = true
        
        if isSelected {
            selectionButton.setImage(CustomSelectableConstants.checkMarkImage, for: .normal)
            selectionButton.tintColor = .lsPrimary
            selectionButton.layer.borderWidth = 1
            selectionButton.layer.borderColor = UIColor.lsPrimary.cgColor
        } else {
            selectionButton.setImage(CustomSelectableConstants.circleImage, for: .normal)
            selectionButton.tintColor = .searchBarBackgroundColor
            selectionButton.layer.borderWidth = 1
            selectionButton.layer.borderColor = UIColor.searchBarTintColor.cgColor
        }
        
        setupViews()
    }
    
    private func setupViews() {
        textStackView.removeArrangedSubViews()
        textStackView.addArrangedSubview(title)
        textStackView.addArrangedSubview(subtitle)
        self.addSubview(containerView)
        containerView.addSubview(selectionButton)
        containerView.addSubview(textStackView)
            
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        selectionButton.snp.makeConstraints {
            $0.height.width.equalTo(20)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        textStackView.snp.makeConstraints {
            $0.height.equalTo(46)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(selectionButton.snp.leading)
            $0.centerY.equalToSuperview()
        }
    }
}
