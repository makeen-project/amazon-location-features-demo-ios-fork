//
//  SearchTextField.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class SearchTextField: UIView {
    
    var passChangedText: StringHandler?
    var searchText: StringHandler?
    // when the user tapped to close/clear button
    var textFieldDeactivated: VoidHandler?
    var textFieldActivated: VoidHandler?
    private var searchState: Bool = false
    
    private let debounceManager = DebounceManager(debounceDuration: 0.5)
    
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
        textField.accessibilityIdentifier = ViewsIdentifiers.Search.searchTextField
        textField.tintColor = .lsPrimary
        textField.textColor = .mapDarkBlackColor
        textField.font = .amazonFont(type: .medium, size: 14)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchBarTintColor, NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 14)]
        )
        textField.isUserInteractionEnabled = true
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textFieldTapped), for: .touchDown)
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    func currentText() -> String? {
        return self.searchTextField.text
    }
    
    func setCurrentText(text: String) {
        self.searchTextField.text = text
    }
        
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        return stackView
    }()
    
    @objc func textFieldTapped(textField: UITextField) {
        searchTextField.becomeFirstResponder()
        if !searchState {
            searchTextField.resignFirstResponder()
            textFieldActivated?()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        searchTextField.delegate = self
        configureStackView()
        configure()
    }
    
    func searchViewBecomeFirstResponder(state: Bool) {
        if !state {
            searchState = true
            searchTextField.becomeFirstResponder()
        }
    }
        
    func configureTextFieldWith(text: String) {
        searchTextField.text = text
    }
        
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
}

private extension SearchTextField {
    
    private func configureStackView() {
        stackView.removeArrangedSubViews()
        stackView.addArrangedSubview(searchIcon)
        stackView.addArrangedSubview(searchTextField)
    }
    
    private func configure() {
        self.addSubview(containerView)
        containerView.addSubview(stackView)
        
        containerView.snp.makeConstraints {
            $0.top.trailing.leading.bottom.equalToSuperview()
        }
        
        searchIcon.snp.makeConstraints {
            $0.height.width.equalTo(20)
        }
        
        stackView.setCustomSpacing(16, after: searchIcon)
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
            $0.leading.equalToSuperview().offset(17)
            $0.bottom.equalToSuperview().offset(-8)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        debounceManager.debounce { [weak self] in
            if let text = textField.text, text.count >= 1 {
                self?.passChangedText?(text)
            } else {
                self?.searchText?("")
            }
        }
    }
}

extension SearchTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        debounceManager.debounce { [weak self] in
            if let text = textField.text, text.count >= 1 {
                self?.searchText?(text)
            } else {
                self?.searchText?("")
            }
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.textFieldDeactivated?()
        return true
    }
}
