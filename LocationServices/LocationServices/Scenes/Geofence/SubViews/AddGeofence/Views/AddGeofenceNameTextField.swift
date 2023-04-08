//
//  AddGeofenceNameTextField.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class AddGeofenceNameTextField: UIView {
    
    var passChangedText: StringHandler?
    var validationCallback: ((String?)->Bool)?
    
    private let titleLabel: AmazonLocationLabel = AmazonLocationLabel(labelText: "Name",
                                                                      font: .amazonFont(type: .bold, size: 13),
                                                                      isMultiline: false,
                                                                      fontColor: .black,
                                                                      textAlignment: .left)
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.accessibilityIdentifier = ViewsIdentifiers.Geofence.geofenceNameTextField
        textField.backgroundColor = .white
        textField.tintColor = .tabBarTintColor
        textField.textColor = .mapDarkBlackColor
        textField.font = .amazonFont(type: .medium, size: 14)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Type Geofence Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchBarTintColor, NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 14)]
        )
        textField.isUserInteractionEnabled = true
        textField.clearButtonMode = .whileEditing
        textField.layer.borderColor = UIColor.textfieldBorderColor.cgColor
        textField.layer.cornerRadius = 8
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    private let errorLabel: AmazonLocationLabel = AmazonLocationLabel(labelText: "Name can only contain alphanumeric, underscore, hyphen characters and maximum 20 characters",
                                                                      font: .amazonFont(type: .regular, size: 10),
                                                                      isMultiline: true,
                                                                      fontColor: .red,
                                                                      textAlignment: .left)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nameTextField.delegate = self
        setupViews()
        setupNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        nameTextField.addPadding(.left(8))
        self.addSubview(titleLabel)
        self.addSubview(nameTextField)
        self.addSubview(errorLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(18)
            $0.width.equalTo(36)
        }
        
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        errorLabel.isHidden = true
    }
    
    // in case of we set title we are going to disable editing options for it
    func setTitle(title: String) {
        nameTextField.text = title
        setEditableStatus(false)
    }
    
    func setEditableStatus(_ editable: Bool) {
        let alphaComponent: CGFloat = editable ? 1 : 0.3
        nameTextField.textColor = .mapDarkBlackColor.withAlphaComponent(alphaComponent)
        nameTextField.isUserInteractionEnabled = editable
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateFields(_:)), name: Notification.geofenceEditScene, object: nil)
    }
    
    @objc func updateFields(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            if let model = notification.userInfo?["geofenceModel"] as? GeofenceDataModel {
                self?.nameTextField.text = model.name
            }
        }
       
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let validationCallback {
            errorLabel.isHidden = validationCallback(textField.text)
        }
        
        let text = textField.text ?? ""
        self.passChangedText?(text)
    }
}

extension AddGeofenceNameTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.count >= 1 {
            self.passChangedText?(text)
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
}
