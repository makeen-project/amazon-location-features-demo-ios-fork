//
//  PostLoginView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class PostLoginView: UIView {
    var delegate: PostLoginViewOutputDelegate?
    
    private var containerView: UIView = UIView()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.closeIcon, for: .normal)
        button.tintColor = .closeButtonTintColor
        button.backgroundColor = .closeButtonBackgroundColor
        button.isUserInteractionEnabled = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        return button
    }()
    
    private var logoView: UIImageView = {
        let iv = UIImageView(image: .loginSuccessLogo)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private var postLoginTitle: UILabel = {
        let label = UILabel()
        label.text = "You are connected"
        label.font = .amazonFont(type: .medium, size: 20)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private var postLoginSubTitle: UILabel = {
        let label = UILabel()
        label.text = """
        Sign in to access Tracking and Geofence features or
        proceed to Explore the map
        """
        label.font = .amazonFont(type: .regular, size: 13)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .searchBarTintColor
        return label
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lsPrimary
        button.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 10
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isUserInteractionEnabled = true
        button.titleLabel?.font = .amazonFont(type: .bold, size: 16)
        button.addTarget(self, action: #selector(signInAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.lsPrimary.withAlphaComponent(0.3)
        button.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 8
        button.setTitle("Continue to Explore", for: .normal)
        button.setTitleColor(.lsPrimary, for: .normal)
        button.titleLabel?.font = .amazonFont(type: .medium, size: 16)
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(exploreAction), for: .touchUpInside)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lsPrimary.cgColor
        return button
    }()
    
    private let postLoginStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        return stackView
    }()
    
     
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackViews()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    @objc private func signInAction() {
        delegate?.signInAction()
    }
    
    @objc private func exploreAction() {
        delegate?.dismissAction()
    }
    
    @objc private func dismissAction() {
        delegate?.dismissAction()
    }
    
    private func setupStackViews() {
        postLoginStackView.removeArrangedSubViews()
        postLoginStackView.addArrangedSubview(logoView)
        postLoginStackView.addArrangedSubview(postLoginTitle)
        postLoginStackView.addArrangedSubview(postLoginSubTitle)
        postLoginStackView.addArrangedSubview(signInButton)
        postLoginStackView.addArrangedSubview(continueButton)
    }
    
    private func setupViews() {
        self.addSubview(containerView)
        self.addSubview(closeButton)
       
        containerView.addSubview(postLoginStackView)
        
        
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.leading.equalToSuperview().offset(16)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-10)
            $0.height.width.equalTo(30)
        }
        
        
        logoView.snp.makeConstraints {
            $0.height.width.equalTo(104)
        }
        
        postLoginStackView.setCustomSpacing(32, after: logoView)
        
        postLoginTitle.snp.makeConstraints {
            $0.height.equalTo(28)
            $0.width.equalTo(150)
        }
        
        postLoginSubTitle.snp.makeConstraints {
            $0.height.equalTo(36)
            $0.width.equalTo(150)
        }
        
        postLoginStackView.setCustomSpacing(48, after: postLoginSubTitle)
        
        signInButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        postLoginStackView.setCustomSpacing(8, after: signInButton)
        
        continueButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        postLoginStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
    }
}
