//
//  AddGeofenceSearchView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

enum AddGeofenceConstant {
    static let radiusValue: Float = 80
}

final class AddGeofenceSearchView: UIView {
    
    var radiusValueHander: IntHandler?
    var coordinateValueHandler: Handler<(Double, Double)>?
    var searchTextValue: StringHandler?
    var searchTextClose: VoidHandler?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let searchIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .searchIcon
        imageView.tintColor = .searchBarTintColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.accessibilityIdentifier = ViewsIdentifiers.Geofence.searchGeofenceTextField
        textField.tintColor = .lsPrimary
        textField.textColor = .mapDarkBlackColor
        textField.font = .amazonFont(type: .medium, size: 14)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchBarTintColor, NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 14)]
        )
        textField.isUserInteractionEnabled = true
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
        return textField
    }()
    
    
    private var seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        return view
    }()
    
    private var radiusTitle = AmazonLocationLabel(labelText: "Radius",
                                                  font: .amazonFont(type: .bold, size: 14),
                                                  textAlignment: .left)
    
    private lazy var radiusSlider: UISlider = {
        let slider = UISlider()
        slider.accessibilityIdentifier = ViewsIdentifiers.Geofence.radiusGeofenceSliderField
        slider.tintColor = .lsPrimary
        slider.minimumValue = 10
        slider.maximumValue = 10000
        slider.addTarget(self, action: #selector(radiusSliderValuChanged), for: .valueChanged)
        return slider
    }()
    
    private var radiusSliderValue = AmazonLocationLabel(labelText: "\(Int(AddGeofenceConstant.radiusValue)) m",
                                                        font: .amazonFont(type: .regular, size: 14),
                                                        isMultiline: false,
                                                        fontColor: .searchBarTintColor,
                                                        textAlignment: .center)
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(geofenceRadiusDragged(_:)), name: Notification.geofenceRadiusDragged, object: nil)
    }
    
    @objc private func geofenceRadiusDragged(_ notification: Notification){
        let radius = notification.userInfo?["radius"] as! Double
        radiusSlider.value = Float(radius)
        radiusSliderValue.text = Int(radius).convertToKm()
        radiusValueHander?(Int(radius))
    }
    
    func hideRadiusViews(state: Bool) {
        self.radiusSliderValue.isHidden = state
        self.radiusSlider.isHidden = state
        self.radiusTitle.isHidden = state
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        searchTextField.delegate = self
        setupViews()
        setupNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    func resignResponserSearchText() {
        self.searchTextField.resignFirstResponder()
    }
    
    func updateFields(model: GeofenceDataModel) {
        DispatchQueue.main.async { [weak self] in
            if let lat = model.lat, let long = model.long {
                self?.searchTextField.text = "\(lat), \(long)"
            }
            
            if let radius = model.radius {
                self?.radiusSlider.value = Float(radius)
                self?.radiusSliderValue.text = radius.convertToKm()
            }            
        }
    }
    
    private func setupViews() {
        radiusSlider.value = AddGeofenceConstant.radiusValue
        self.addSubview(containerView)
        containerView.addSubview(searchIcon)
        containerView.addSubview(searchTextField)
        containerView.addSubview(seperatorView)
        containerView.addSubview(radiusTitle)
        containerView.addSubview(radiusSliderValue)
        containerView.addSubview(radiusSlider)
        
        containerView.snp.makeConstraints {
            $0.top.leading.bottom.trailing.equalToSuperview()
        }
        
        searchIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(12)
            $0.height.width.equalTo(20)
        }
        
        searchTextField.snp.makeConstraints {
            $0.centerY.equalTo(searchIcon.snp.centerY)
            $0.leading.equalTo(searchIcon.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
        }
        
        seperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.trailing.leading.equalToSuperview()
            $0.top.equalTo(searchTextField.snp.bottom).offset(10)
        }
        
        radiusTitle.snp.makeConstraints {
            $0.top.equalTo(seperatorView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(18)
            $0.width.equalTo(51)
        }
        
        radiusSliderValue.snp.makeConstraints {
            $0.top.equalTo(radiusTitle.snp.top)
            $0.height.equalTo(17)
            $0.width.equalTo(60)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        radiusSlider.snp.makeConstraints {
            $0.top.equalTo(radiusTitle.snp.top)
            $0.leading.equalTo(radiusTitle.snp.trailing).offset(24)
            $0.trailing.equalTo(radiusSliderValue.snp.leading).offset(-16)
            $0.height.equalTo(28)
        }
    }
}

extension AddGeofenceSearchView {
    @objc func radiusSliderValuChanged(sender: UISlider) {
        let value = Int(radiusSlider.value)
        self.radiusSliderValue.text = value.convertToKm()
        radiusValueHander?(value)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, text.count >= 1 {
            self.searchTextValue?(text)
        }
    }
}

extension AddGeofenceSearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.count >= 1 {
            self.searchTextValue?(text)
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        self.searchTextClose?()
        
        return true
    }
}


