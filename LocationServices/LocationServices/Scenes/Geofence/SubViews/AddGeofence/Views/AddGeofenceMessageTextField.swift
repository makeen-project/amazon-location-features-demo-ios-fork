//
//  AddGeofenceMessageTextField.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class AddGeofenceMessageTextField: UIView {
    private let titleLabel = AmazonLocationLabel(labelText: "Message",
                                                 font: .amazonFont(type: .bold, size: 13),
                                                 isMultiline: false,
                                                 fontColor: .black,
                                                 textAlignment: .left)
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let messageFirstLineTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.tintColor = .lsPrimary
        textField.textColor = .mapDarkBlackColor
        textField.font = .amazonFont(type: .medium, size: 14)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter geofence message",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchBarTintColor, NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 14)]
        )
        textField.isUserInteractionEnabled = true
        textField.clearButtonMode = .whileEditing
        textField.layer.borderColor = UIColor.textfieldBorderColor.cgColor
        return textField
    }()
    
    private let messageSecondLineTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.tintColor = .lsPrimary
        textField.textColor = .mapDarkBlackColor
        textField.font = .amazonFont(type: .medium, size: 14)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Exit geofence message",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchBarTintColor, NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 14)]
        )
        textField.isUserInteractionEnabled = true
        textField.clearButtonMode = .whileEditing
        textField.layer.borderColor = UIColor.textfieldBorderColor.cgColor
        return textField
    }()
    
    private var seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        messageFirstLineTextField.addPadding(.left(8))
        messageSecondLineTextField.addPadding(.left(8))
        self.addSubview(titleLabel)
        self.addSubview(containerView)
        containerView.addSubview(messageFirstLineTextField)
        containerView.addSubview(seperatorView)
        containerView.addSubview(messageSecondLineTextField)
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.width.equalTo(36)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(81)
        }
        
        messageFirstLineTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        seperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.trailing.leading.equalToSuperview()
            $0.top.equalTo(messageFirstLineTextField.snp.bottom)
        }
        
        messageSecondLineTextField.snp.makeConstraints {
            $0.top.equalTo(seperatorView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
}
