//
//  DirectionSearchView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

struct DirectionSeachViewModel {
    var searchText: String
    var isDestination: Bool
}

final class DirectionSearchView: UIView {
    
    var searchTextHandler: Handler<DirectionSeachViewModel>?
    var searchReturnHandler: Handler<DirectionSeachViewModel>?
    var delegate: DirectionSearchViewOutputDelegate?
    
    private let debounceManager = DebounceManager(debounceDuration: 0.5)
    
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()
    
    private var firstDestinationImage: UIImageView = {
        let iv = UIImageView(image: .myLocationIcon)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private var dotDestinationImage: UIImageView = {
        let iv = UIImageView(image: .navigationDashedIcon)
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .searchBarBackgroundColor
        return iv
    }()
    
    private var secondDestinationImage: UIImageView = {
        let iv = UIImageView(image: .selectedPlace)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private lazy var firstDestinationTextField: UITextField = {
        let tf = UITextField()
        tf.accessibilityIdentifier = ViewsIdentifiers.Routing.departureTextField
        tf.font = .amazonFont(type: .medium, size: 14)
        tf.attributedPlaceholder = NSAttributedString(
            string: "Search Starting Point",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchBarTintColor, NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 14)]
        )
        tf.tintColor = .tabBarTintColor
        tf.textColor = .mapDarkBlackColor
        tf.clearButtonMode = .whileEditing
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidBegin)
        return tf
    }()

    
    private var seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        return view
    }()
    
    private lazy var secondDestinationTextField: UITextField = {
        let tf = UITextField()
        tf.accessibilityIdentifier = ViewsIdentifiers.Routing.destinationTextField
        tf.font = .amazonFont(type: .medium, size: 14)
        tf.attributedPlaceholder = NSAttributedString(
            string: "Search Destination",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchBarTintColor, NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 14)]
        )
        tf.tintColor = .tabBarTintColor
        tf.textColor = .mapDarkBlackColor
        tf.clearButtonMode = .whileEditing
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidBegin)
        return tf
    }()
    
    private var directionSearchTitle: UILabel = {
        let label = UILabel()
        label.text = "Direction"
        label.textAlignment = .left
        label.font = .amazonFont(type: .bold, size: 20)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.closeIcon, for: .normal)
        button.tintColor = .closeButtonTintColor
        button.backgroundColor = .closeButtonBackgroundColor
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        return button
    }()
    
    private lazy var swapButton: UIButton = {
        var button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.Routing.swapButton
        button.setImage(.swapDestinations, for: .normal)
        button.tintColor = .searchBarTintColor
        button.addTarget(self, action: #selector(swapLocations), for: .touchUpInside)
        return button
    }()
    
    private var iconStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }()
    
    func setMyLocationText() {
        self.firstDestinationTextField.text = "My Location"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDelegates()
        setupViews()
    }
    
    @objc func closeModal() {
        delegate?.dismissView()
    }
    
    @objc func swapLocations() {
        let destinationText = firstDestinationTextField.text
        let depatureText = secondDestinationTextField.text
        firstDestinationTextField.text = depatureText
        secondDestinationTextField.text = destinationText
        delegate?.swapLocations()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDelegates() {
        firstDestinationTextField.delegate = self
        secondDestinationTextField.delegate = self
    }
    
    func closeKeyboard() {
        secondDestinationTextField.resignFirstResponder()
    }
    
    private func setupViews() {
        iconStackView.removeArrangedSubViews()
        iconStackView.addArrangedSubview(firstDestinationImage)
        iconStackView.addArrangedSubview(dotDestinationImage)
        iconStackView.addArrangedSubview(secondDestinationImage)
        
        self.addSubview(directionSearchTitle)
        self.addSubview(closeButton)
        self.addSubview(containerView)
        containerView.addSubview(iconStackView)
        containerView.addSubview(firstDestinationTextField)
        containerView.addSubview(seperatorView)
        containerView.addSubview(secondDestinationTextField)
        containerView.addSubview(swapButton)
        
        directionSearchTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(28)
        }
        
        closeButton.snp.makeConstraints {
            $0.height.width.equalTo(30)
            $0.top.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(directionSearchTitle.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(80)
        }
        
        firstDestinationImage.snp.makeConstraints {
            $0.height.width.equalTo(16)
        }
        
        dotDestinationImage.snp.makeConstraints {
            $0.height.equalTo(18)
            $0.width.equalTo(2)
        }
        
        secondDestinationImage.snp.makeConstraints {
            $0.height.width.equalTo(16)
        }
        
        iconStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-13)
            $0.width.equalTo(16)
            $0.leading.equalToSuperview().offset(18)
        }
        
        firstDestinationTextField.snp.makeConstraints {
            $0.top.equalTo(iconStackView.snp.top)
            $0.leading.equalTo(iconStackView.snp.trailing).offset(18)
            $0.trailing.equalToSuperview().offset(-40)
            $0.height.equalTo(17)
        }
        
        seperatorView.snp.makeConstraints {
            $0.top.equalTo(firstDestinationTextField.snp.bottom).offset(10)
            $0.height.equalTo(1)
            $0.leading.equalTo(firstDestinationTextField.snp.leading)
            $0.trailing.equalToSuperview()
        }
        
        
        secondDestinationTextField.snp.makeConstraints {
            $0.bottom.equalTo(iconStackView.snp.bottom)
            $0.leading.equalTo(iconStackView.snp.trailing).offset(18)
            $0.trailing.equalToSuperview().offset(-40)
            $0.height.equalTo(17)
        }
        
        swapButton.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalTo(secondDestinationTextField.snp.centerY)
        }
    }
    
    func changeSearchRouteName(with value: String?, isDestination: Bool) {
        guard let value else { return }
        if isDestination {
            secondDestinationTextField.text = value
        } else {
            firstDestinationTextField.text = value
        }
    }
    
    func becomeFirstResponder(isDestination: Bool) {
        if isDestination {
            secondDestinationTextField.becomeFirstResponder()
        } else {
            firstDestinationTextField.becomeFirstResponder()
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let isDestination = textField == secondDestinationTextField
        let model = DirectionSeachViewModel(searchText: textField.text ?? "", isDestination: isDestination)
        
        debounceManager.debounce {
            self.searchTextHandler?(model)
        }
    }
}

extension DirectionSearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstDestinationTextField {
            if let text = firstDestinationTextField.text, text.count >= 1 {
                let model = DirectionSeachViewModel(searchText: text, isDestination: false)
                self.searchReturnHandler?(model)
                return true
            } else {
                let model = DirectionSeachViewModel(searchText: "", isDestination: false)
                self.searchReturnHandler?(model)
                return true
            }
        } else {
            if let secondText = secondDestinationTextField.text, secondText.count >= 1 {
                let model = DirectionSeachViewModel(searchText:secondText, isDestination: true)
                self.searchReturnHandler?(model)
                return true
            } else {
                let model = DirectionSeachViewModel(searchText: "", isDestination: true)
                self.searchReturnHandler?(model)
                return true
            }
        }
    }
}
