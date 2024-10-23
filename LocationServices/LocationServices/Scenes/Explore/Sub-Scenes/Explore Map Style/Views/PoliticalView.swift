//
//  PoliticalView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class PoliticalView: UIButton {
    private var itemIcon: UIImageView = {
        let image = UIImage(systemName: "globe.europe.africa.fill")
        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .mapStyleTintColor
        return iv
    }()
    
    private var itemTitle: UILabel = {
        var label = UILabel()
        label.font = .amazonFont(type: .regular, size: 16)
        label.textColor = .mapDarkBlackColor
        label.textAlignment = .left
        label.text = "Political view"
        return label
    }()
    
    private var itemSubtitle: UILabel = {
        var label = UILabel()
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .mapStyleTintColor
        label.textAlignment = .left
        label.text = ""
        return label
    }()
    
    private var arrowIcon: UIImageView = {
        let image = UIImage(systemName: "chevron.right")
        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .searchBarTintColor
        return iv
    }()
    
    private var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private var containerView: UIView = UIView()
    public var viewController: UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        textStackView.removeArrangedSubViews()
        textStackView.addArrangedSubview(itemTitle)
        textStackView.addArrangedSubview(itemSubtitle)
        
        self.addSubview(containerView)
        containerView.addSubview(itemIcon)
        containerView.addSubview(arrowIcon)
        containerView.addSubview(textStackView)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        itemIcon.snp.makeConstraints {
            $0.height.width.equalTo(32)
            $0.leading.equalToSuperview().offset(18)
            $0.centerY.equalToSuperview()
        }
        
        arrowIcon.snp.makeConstraints {
            $0.height.width.equalTo(14)
            $0.trailing.equalToSuperview().offset(-25)
            $0.centerY.equalToSuperview()
        }
        
        textStackView.snp.makeConstraints {
            $0.height.equalTo(46)
            $0.leading.equalTo(itemIcon.snp.trailing).offset(24)
            $0.trailing.equalTo(arrowIcon.snp.leading)
            $0.centerY.equalToSuperview()
        }
        
        self.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
        
        setPoliticalView()
    }
    
    @objc private func handleTapGesture() {
        let politicalVC = PoliticalViewController()
        politicalVC.modalPresentationStyle = .formSheet
        politicalVC.onDismiss = {
            self.setPoliticalView()
        }
        viewController?.present(politicalVC, animated: true)
    }

    public func setPoliticalView() {
        if let politicalViewType = UserDefaultsHelper.getObject(value: PoliticalViewType.self, key: .politicalView) {
            itemSubtitle.text = "\(politicalViewType.countryCode). \(politicalViewType.politicalDescription)"
            itemSubtitle.tintColor = .mapStyleTintColor
        }
        else {
            itemSubtitle.text = "Map representation for different countries"
            itemSubtitle.tintColor = .gray
        }
    }
}
