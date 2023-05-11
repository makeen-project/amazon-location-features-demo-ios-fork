//
//  NavigationVCView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

struct NavigationHeaderViewModel {
    let duration: String
    let distance: String
}

final class NavigationHeaderView: UIView {
    var dismissHandler: VoidHandler?
    var model: NavigationHeaderViewModel! {
        didSet {
            self.durationLabel.text = model.duration
            self.distanceLabel.text = model.distance
        }
    }
    
    private let containerView: UIView =  {
        let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 20
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "4 min"
        label.textAlignment = .left
        label.font = .amazonFont(type: .bold, size: 20)
        label.textColor = .black
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .left
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .searchBarTintColor
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.Navigation.navigationExitButton
        button.setTitle("Exit", for: .normal)
        
        button.tintColor = .white
        button.backgroundColor = .navigationRedButton
        button.isUserInteractionEnabled = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(navigationDismiss), for: .touchUpInside)
        return button
    }()
    
    private var seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        return view
    }()
    
    
    @objc func navigationDismiss() {
        dismissHandler?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func updateDatas(distance: String?, duration: String?) {
            distanceLabel.text = distance
            durationLabel.text = duration
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(durationLabel)
        containerView.addSubview(distanceLabel)
        containerView.addSubview(exitButton)
        containerView.addSubview(seperatorView)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        durationLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(27)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(28)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.top.equalTo(durationLabel.snp.bottom).offset(2)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(18)
        }
        
        exitButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(31)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
            $0.width.equalTo(83)
        }
        
        seperatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(2)
        }
    }
}
