//
//  LoginFormView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class LoginFormView: UIView {
    
    var identityPoolIdHandler: StringHandler?
    var useryPoolIdHandler: StringHandler?
    var userPoolClientIdHandler: StringHandler?
    var userDomainHandler: StringHandler?
    var webSocketHandler: StringHandler?
    
    private let containerView: UIView = UIView()
    
    private let identityPoolTitle: UILabel = {
        let label = UILabel()
        label.text = "IdentityPoolld"
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let identityPoolTextField: UITextField = {
        let textField = UITextField()
        textField.accessibilityIdentifier = ViewsIdentifiers.AWSConnect.identityPoolTextField
        textField.backgroundColor = .textFieldBackgroundColor
        textField.tintColor = .lsPrimary
        textField.textColor = .mapDarkBlackColor
        textField.font = .amazonFont(type: .medium, size: 14)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter IdentityPoolld ",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchBarTintColor, NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 14)]
        )
        textField.isUserInteractionEnabled = true
        textField.clearButtonMode = .whileEditing
        textField.layer.borderColor = UIColor.textfieldBorderColor.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    private let userDomainTitle: UILabel = {
        let label = UILabel()
        label.text = "User Domain"
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let userDomainTextField: UITextField = {
        let textField = UITextField()
        textField.accessibilityIdentifier = ViewsIdentifiers.AWSConnect.userDomainTextField
        textField.backgroundColor = .textFieldBackgroundColor
        textField.tintColor = .lsPrimary
        textField.textColor = .mapDarkBlackColor
        textField.font = .amazonFont(type: .medium, size: 14)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter UserDomain ",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchBarTintColor, NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 14)]
        )
        textField.isUserInteractionEnabled = true
        textField.clearButtonMode = .whileEditing
        textField.layer.borderColor = UIColor.textfieldBorderColor.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    
    private let userPoolClientTitle: UILabel = {
        let label = UILabel()
        label.text = "UserPoolClientid"
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let userPoolClientTextField: UITextField = {
        let textField = UITextField()
        textField.accessibilityIdentifier = ViewsIdentifiers.AWSConnect.userPoolClientTextField
        textField.backgroundColor = .textFieldBackgroundColor
        textField.tintColor = .lsPrimary
        textField.textColor = .mapDarkBlackColor
        textField.font = .amazonFont(type: .medium, size: 14)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter UserPoolClientId",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchBarTintColor, NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 14)]
        )
        textField.isUserInteractionEnabled = true
        textField.clearButtonMode = .whileEditing
        textField.layer.borderColor = UIColor.textfieldBorderColor.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    
    private let userPoolTitle: UILabel = {
        let label = UILabel()
        label.text = "UserPoolld"
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let userPoolTextField: UITextField = {
        let textField = UITextField()
        textField.accessibilityIdentifier = ViewsIdentifiers.AWSConnect.userPoolTextField
        textField.backgroundColor = .textFieldBackgroundColor
        textField.tintColor = .lsPrimary
        textField.textColor = .mapDarkBlackColor
        textField.font = .amazonFont(type: .medium, size: 14)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter UserPoolld",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchBarTintColor, NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 14)]
        )
        textField.isUserInteractionEnabled = true
        textField.clearButtonMode = .whileEditing
        textField.layer.borderColor = UIColor.textfieldBorderColor.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    private let webSocketURLTitle: UILabel = {
        let label = UILabel()
        label.text = "WebSocketUrl"
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let webSocketURLTitleTextField: UITextField = {
        let textField = UITextField()
        textField.accessibilityIdentifier = ViewsIdentifiers.AWSConnect.webSocketURLTitleTextField
        textField.backgroundColor = .textFieldBackgroundColor
        textField.tintColor = .lsPrimary
        textField.textColor = .mapDarkBlackColor
        textField.font = .amazonFont(type: .medium, size: 14)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter WebSocketUrl",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchBarTintColor, NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 14)]
        )
        textField.isUserInteractionEnabled = true
        textField.clearButtonMode = .whileEditing
        textField.layer.borderColor = UIColor.textfieldBorderColor.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    private var activeTextField: UITextField?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDelegates()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    deinit {
        // Remove observer for UIApplication.willEnterForegroundNotification
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func setupDelegates() {
        identityPoolTextField.delegate = self
        userPoolClientTextField.delegate = self
        userPoolTextField.delegate = self
        userDomainTextField.delegate = self
        webSocketURLTitleTextField.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            
            if let text = self.identityPoolTextField.text {
                self.identityPoolIdHandler?(text)
            }
            
            if let text = self.userPoolClientTextField.text {
                self.userPoolClientIdHandler?(text)
            }
            
            if let text = self.userDomainTextField.text {
                self.userDomainHandler?(text)
            }
            
            if let text = self.userPoolTextField.text {
                self.useryPoolIdHandler?(text)
            }
            
            if let text = self.webSocketURLTitleTextField.text {
                self.webSocketHandler?(text)
            }
        }
        
        // Add observer for UIApplication.willEnterForegroundNotification
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppEnteredBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    var isBackgroundModeActive = false
    
    @objc func handleAppWillEnterForeground() {
        // Make the active text field the first responder to show the keyboard
        isBackgroundModeActive = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.activeTextField?.becomeFirstResponder()
        }
    }
    
    @objc func handleAppEnteredBackground() {
        isBackgroundModeActive = true
         self.endEditing(true)
    }
    
    /// Will be enabled in the future, Additional Fields!
    private func hideExtraFields() {
        userDomainTitle.isHidden = true
        userDomainTextField.isHidden = true
        userPoolClientTitle.isHidden = true
        userPoolClientTextField.isHidden = true
        userPoolTitle.isHidden = true
        userPoolTextField.isHidden = true
    }
    
    private func setupViews() {
     
        identityPoolTextField.addPadding(.left(16))
        userPoolClientTextField.addPadding(.left(16))
        userPoolTextField.addPadding(.left(16))
        userDomainTextField.addPadding(.left(16))
        webSocketURLTitleTextField.addPadding(.left(16))
        
        self.addSubview(containerView)
        containerView.addSubview(identityPoolTitle)
        containerView.addSubview(identityPoolTextField)
        containerView.addSubview(userDomainTitle)
        containerView.addSubview(userDomainTextField)
        containerView.addSubview(userPoolClientTitle)
        containerView.addSubview(userPoolClientTextField)
        containerView.addSubview(userPoolTitle)
        containerView.addSubview(userPoolTextField)
        containerView.addSubview(webSocketURLTitle)
        containerView.addSubview(webSocketURLTitleTextField)
        
        
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        identityPoolTitle.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(18)
        }
        
        identityPoolTextField.snp.makeConstraints {
            $0.top.equalTo(identityPoolTitle.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        userDomainTitle.snp.makeConstraints {
            $0.top.equalTo(identityPoolTextField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(18)
        }
        
        userDomainTextField.snp.makeConstraints {
            $0.top.equalTo(userDomainTitle.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        userPoolClientTitle.snp.makeConstraints {
            $0.top.equalTo(userDomainTextField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(18)
        }
        
        userPoolClientTextField.snp.makeConstraints {
            $0.top.equalTo(userPoolClientTitle.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        userPoolTitle.snp.makeConstraints {
            $0.top.equalTo(userPoolClientTextField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(18)
        }
        
        userPoolTextField.snp.makeConstraints {
            $0.top.equalTo(userPoolTitle.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        webSocketURLTitle.snp.makeConstraints {
            $0.top.equalTo(userPoolTextField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(18)
        }

        webSocketURLTitleTextField.snp.makeConstraints {
            $0.top.equalTo(webSocketURLTitle.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview()
        }
    }
}

extension LoginFormView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == identityPoolTextField {
            if let text = identityPoolTextField.text {
                identityPoolIdHandler?(text)
            }
        } else if textField == userPoolClientTextField {
            if let text = userPoolClientTextField.text {
                userPoolClientIdHandler?(text)
            }
        } else if textField == userDomainTextField {
            if let text = userDomainTextField.text {
                userDomainHandler?(text)
            }
        } else if textField == webSocketURLTitleTextField {
            if let text = webSocketURLTitleTextField.text {
                webSocketHandler?(text)
            }
        } else {
            if let text = userPoolTextField.text {
                useryPoolIdHandler?(text)
            }
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(!isBackgroundModeActive) {
            activeTextField = nil
        }
    }
}

