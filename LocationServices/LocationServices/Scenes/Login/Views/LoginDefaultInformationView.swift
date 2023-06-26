//
//  LoginDefaultInformationView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class LoginDefaultInformationView: UIView {
   
    var dismissHandler: VoidHandler?
    var learnMoreLinkTappedHandler: StringHandler?
    
    private var logoView: UIImageView = {
        let view = UIImageView(image: .loginLogo)
        view.contentMode = .scaleToFill
        return view
    }()
    
    private var loginVCTitle: UILabel = {
        let label = UILabel()
        label.text = StringConstant.loginVcTitle
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    
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
    
    private let headerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        return view
    }()
    
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lsLight3
        return view
    }()
    
    private var mainTitle: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = ViewsIdentifiers.AWSConnect.awsConnectTitleLabel
        label.text = getConstantsConfig().mainTitle
        label.font = .amazonFont(type: .bold, size: 20)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private var mainSubTitle: UILabel = {
        let label = UILabel()
        label.text = getConstantsConfig().mainSubtitle
        label.font = .amazonFont(type: .regular, size: 13)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .searchBarTintColor
        return label
    }()
    
    private var closeAppAlertView: UIView = {
        let view = LoginCloseAppAlertView()
        return view
    }()
    
    private var subHeader: UILabel = {
        let label = UILabel()
        label.text = getConstantsConfig().subHeader
        label.font = .amazonFont(type: .bold, size: 16)
        label.textColor = .black
        return label
    }()
    
    private var firstNumber: UILabel = {
        let label = UILabel()
        label.text = getConstantsConfig().firstNumber
        label.textAlignment = .center
        label.backgroundColor = .bulletNumberBackgroundColor
        label.layer.cornerRadius = 3
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .black
        return label
    }()
    
    private lazy var firstItemTitle: UILabel = {
        let label = UILabel()

        let text = Self.getConstantsConfig().firstItemTitle
        var attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.amazonFont(type: .bold, size: 13)])
        
        let clickableText = Self.getConstantsConfig().firstItemTitleClickablePart
        let linkWasSet = attributedString.highlightAsLink(textOccurances: clickableText)
        
        if linkWasSet {
            label.attributedText = attributedString
        }
    
        label.font = .amazonFont(type: .bold, size: 13)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private var firstItemText: UITextView = {
        let tw = UITextView()
        tw.text = getConstantsConfig().firstItemText
        tw.font = .amazonFont(type: .regular, size: 13)
        tw.textColor = .searchBarTintColor
        tw.textAlignment = .left
        tw.isScrollEnabled = false
        tw.isUserInteractionEnabled = false
        tw.contentInset = UIEdgeInsets(top: -7, left: -3, bottom: 0, right: 0)
        
        return tw
    }()
    
    private var secondNumber: UILabel = {
        let label = UILabel()
        label.text = getConstantsConfig().secondNumber
        label.backgroundColor = .bulletNumberBackgroundColor
        label.layer.cornerRadius = 3
        label.font = .amazonFont(type: .bold, size: 13)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var secondItemTitle: UILabel = {
        let label = UILabel()
        label.text = getConstantsConfig().secondItemTitle
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private var secondItemText: UITextView = {
        let tw = UITextView()
        
        let text = getConstantsConfig().secondItemText
        let attributedString = NSMutableAttributedString(string: text)
        if let url = URL(string: getConstantsConfig().learnMoreURL) {
            let clickableText = getConstantsConfig().secondItemTextClickablePart
            let range = (attributedString.string as NSString).range(of: clickableText)
            attributedString.setAttributes([.link: url], range: range)
        }
        
        tw.linkTextAttributes = [
            .foregroundColor: UIColor.lsPrimary,
            .font: UIFont.amazonFont(type: .bold, size: 13)
        ]
        
        tw.attributedText = attributedString
        tw.font = .amazonFont(type: .regular, size: 13)
        tw.textColor = .searchBarTintColor
        tw.textAlignment = .left
        tw.isScrollEnabled = false
        tw.contentInset = UIEdgeInsets(top: -7, left: -3, bottom: 0, right: 0)
        tw.isUserInteractionEnabled = true
        tw.isEditable = false
        return tw
    }()
    
    private var thirdNumber: UILabel = {
        let label = UILabel()
        label.text = getConstantsConfig().thirdNumber
        label.backgroundColor = .bulletNumberBackgroundColor
        label.layer.cornerRadius = 3
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private var thirdItemTitle: UILabel = {
        let label = UILabel()
        label.text = getConstantsConfig().thirdItemTitle
        label.font = .amazonFont(type: .bold, size: 13)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private var thirdItemText: UITextView = {
        let tw = UITextView()
        tw.text = getConstantsConfig().thirdItemText
        tw.isUserInteractionEnabled = false
        tw.font = .amazonFont(type: .regular, size: 13)
        tw.textColor = .searchBarTintColor
        tw.textAlignment = .left
        tw.contentInset = UIEdgeInsets(top: -7, left: -3, bottom: 0, right: 0)
        tw.isScrollEnabled = false
        return tw
    }()

    func hideCloseButton(state: Bool) {
        self.headerStackView.isHidden = state
        self.separatorView.isHidden = state
        
        logoView.snp.remakeConstraints {
            if(state) {
                $0.top.equalTo(44).offset(10)
            }
            else {
                $0.top.equalTo(separatorView.snp.bottom).offset(10)
          }
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(56)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    @objc private func dismissAction() {
        dismissHandler?()
    }
    
    private func setupView() {
        headerStackView.addSubview(loginVCTitle)
        headerStackView.addSubview(closeButton)
        
        self.addSubview(headerStackView)
        self.addSubview(separatorView)
        self.addSubview(logoView)
        self.addSubview(mainTitle)
        self.addSubview(mainSubTitle)
        self.addSubview(closeAppAlertView)
        self.addSubview(subHeader)
        self.addSubview(firstNumber)
        self.addSubview(firstItemTitle)
        self.addSubview(firstItemText)
        self.addSubview(secondNumber)
        self.addSubview(secondItemTitle)
        self.addSubview(secondItemText)
        self.addSubview(thirdNumber)
        self.addSubview(thirdItemTitle)
        self.addSubview(thirdItemText)
        
        headerStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
            $0.top.equalToSuperview()
        }
        
        loginVCTitle.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-10)
            $0.height.width.equalTo(30)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(headerStackView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        logoView.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(56)
        }
        
        mainTitle.snp.makeConstraints {
            $0.top.equalTo(logoView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        mainSubTitle.snp.makeConstraints {
            $0.top.equalTo(mainTitle.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        closeAppAlertView.snp.makeConstraints {
            $0.top.equalTo(mainSubTitle.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    
        subHeader.snp.makeConstraints {
            $0.top.equalTo(closeAppAlertView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        firstNumber.snp.makeConstraints {
            $0.leading.equalTo(subHeader.snp.leading)
            $0.top.equalTo(subHeader.snp.bottom).offset(20)
            $0.height.width.equalTo(24)
        }
        
        firstItemTitle.snp.makeConstraints {
            $0.top.equalTo(firstNumber.snp.top)
            $0.leading.equalTo(firstNumber.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        firstItemText.snp.makeConstraints {
            $0.leading.equalTo(firstItemTitle.snp.leading)
            $0.top.equalTo(firstItemTitle.snp.bottom).offset(2)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        secondNumber.snp.makeConstraints {
            $0.leading.equalTo(subHeader.snp.leading)
            $0.top.equalTo(firstItemText.snp.bottom).offset(12)
            $0.height.width.equalTo(24)
        }
        
        secondItemTitle.snp.makeConstraints {
            $0.top.equalTo(secondNumber.snp.top)
            $0.leading.equalTo(secondNumber.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        secondItemText.snp.makeConstraints {
            $0.leading.equalTo(secondItemTitle.snp.leading)
            $0.top.equalTo(secondItemTitle.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        thirdNumber.snp.makeConstraints {
            $0.leading.equalTo(subHeader.snp.leading)
            $0.top.equalTo(secondItemText.snp.bottom).offset(12)
            $0.height.width.equalTo(24)
        }
        
        thirdItemTitle.snp.makeConstraints {
            $0.top.equalTo(thirdNumber.snp.top)
            $0.leading.equalTo(thirdNumber.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        thirdItemText.snp.makeConstraints {
            $0.leading.equalTo(thirdItemTitle.snp.leading)
            $0.top.equalTo(thirdItemTitle.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
        
        firstItemTitle.isUserInteractionEnabled = true
        let tapGestureClickHere = UITapGestureRecognizer(target: self, action: #selector(openLink))
        firstItemTitle.addGestureRecognizer(tapGestureClickHere)
        
        let tapGestureLearnMore = UITapGestureRecognizer(target: self, action: #selector(handleTapOnLabel(_:)))
        secondItemText.addGestureRecognizer(tapGestureLearnMore)
    }
    
    @objc func openLink() {
        if let url = URL(string: StringConstant.cfTemplateURL) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func handleTapOnLabel(_ recognizer: UITapGestureRecognizer) {
        let url = Self.getConstantsConfig().learnMoreURL
        
        let range = LoginDefaultInformationView.getConstantsConfig().secondItemText.range(of: LoginDefaultInformationView.getConstantsConfig().secondItemTextClickablePart)
        guard let range,
              recognizer.didTapAttributedTextInLabel(tw: secondItemText, inRange: NSRange(range, in: LoginDefaultInformationView.getConstantsConfig().secondItemText)) else { return }
        
        learnMoreLinkTappedHandler?(url)
    }
    
    private static func getConstantsConfig() -> ConstantsLoginInfoConfig.Type {
        if isCustomConfigConnected() {
            return StringConstant.LoginInfo.CustomConfig.self
        } else {
            return StringConstant.LoginInfo.DefaultConfig.self
        }
    }
    
    private static func isCustomConfigConnected() -> Bool {
        return UserDefaultsHelper.getAppState() == .loggedIn || UserDefaultsHelper.getAppState() == .customAWSConnected
    }
}
