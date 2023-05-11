//
//  WelcomeBottomView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class WelcomeBottomView: UIView {
    private var logoIcon: UIImageView = {
        let iv = UIImageView(image: .logoPoweredByAWS)
        return iv
    }()
    
    private var desctiptionTextView: UITextView = {
        let tw = UITextView()
        
        let text = StringConstant.About.descriptionTitle
        let attributedString = NSMutableAttributedString(string: text)
        let clickableSets = [
            (StringConstant.About.appTermsOfUse, StringConstant.About.appTermsOfUseURL)
        ]
        
        clickableSets.forEach { clickableText, urlString in
            guard let url = URL(string: urlString) else { return }
            let range = (attributedString.string as NSString).range(of: clickableText)
            attributedString.setAttributes([.link: url], range: range)
        }
        
        tw.linkTextAttributes = [
            .foregroundColor: UIColor.lsPrimary,
            .font: UIFont.amazonFont(type: .regular, size: 10)
        ]
        
        tw.attributedText = attributedString
        tw.font = .amazonFont(type: .regular, size: 10)
        tw.textColor = .lsGrey
        tw.textAlignment = .left
        tw.isScrollEnabled = false
        tw.contentInset = UIEdgeInsets(top: -10, left: -5, bottom: 0, right: 0)
        tw.isUserInteractionEnabled = true
        tw.isEditable = false
        return tw
    }()
    
    private var copyrightLabel: UILabel = {
        var label = UILabel()
        label.text = StringConstant.About.copyright
        label.font = .amazonFont(type: .regular, size: 10)
        label.textColor = .lsGrey
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        addSubview(logoIcon)
        addSubview(desctiptionTextView)
        addSubview(copyrightLabel)
       
        logoIcon.snp.makeConstraints {
            $0.height.equalTo(20)
            $0.width.equalTo(113)
            $0.top.centerX.equalToSuperview()
        }
        
        desctiptionTextView.snp.makeConstraints {
            $0.top.equalTo(logoIcon.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        copyrightLabel.snp.makeConstraints {
            $0.top.equalTo(desctiptionTextView.snp.bottom)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview()
        }
    }
}
