//
//  ResetPasswordView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class ResetPasswordView: UIView {
    private let currentPasswordTitle: UILabel = {
        let label = UILabel()
        label.text = "Current Pasword"
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let currentPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .textFieldBackgroundColor
        textField.tintColor = .tabBarTintColor
        textField.textColor = .mapDarkBlackColor
        textField.font = .amazonFont(type: .medium, size: 14)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Current Pasword",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchBarTintColor, NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 14)]
        )
        textField.isUserInteractionEnabled = true
        textField.clearButtonMode = .whileEditing
        textField.layer.borderColor = UIColor.textfieldBorderColor.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    private let newPasswordTitle: UILabel = {
        let label = UILabel()
        label.text = "New Pasword"
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let newPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .textFieldBackgroundColor
        textField.tintColor = .tabBarTintColor
        textField.textColor = .mapDarkBlackColor
        textField.font = .amazonFont(type: .medium, size: 14)
        textField.attributedPlaceholder = NSAttributedString(
            string: "New Pasword",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchBarTintColor, NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 14)]
        )
        textField.isUserInteractionEnabled = true
        textField.clearButtonMode = .whileEditing
        textField.layer.borderColor = UIColor.textfieldBorderColor.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .tabBarTintColor
        button.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 10
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = .amazonFont(type: .bold, size: 16)
        button.setTitleColor(.white, for: .normal)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private var resetPasswordStackView: UIStackView = {
        let sw = UIStackView()
        sw.axis = .vertical
        sw.distribution = .fillProportionally
        sw.spacing = 24
        return sw
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        currentPasswordTextField.addPadding(.left(16))
        newPasswordTextField.addPadding(.left(16))
        resetPasswordStackView.removeArrangedSubViews()
        resetPasswordStackView.addArrangedSubview(currentPasswordTitle)
        resetPasswordStackView.addArrangedSubview(currentPasswordTextField)
        resetPasswordStackView.addArrangedSubview(newPasswordTitle)
        resetPasswordStackView.addArrangedSubview(newPasswordTextField)
        resetPasswordStackView.addArrangedSubview(saveButton)
        
        
        currentPasswordTitle.snp.makeConstraints {
            $0.height.equalTo(18)
        }
        
        currentPasswordTextField.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        newPasswordTitle.snp.makeConstraints {
            $0.height.equalTo(18)
        }
        
        newPasswordTextField.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        saveButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        resetPasswordStackView.setCustomSpacing(2, after: currentPasswordTitle)
        resetPasswordStackView.setCustomSpacing(2, after: newPasswordTitle)
        
        self.addSubview(resetPasswordStackView)
        
        resetPasswordStackView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}
