//
//  RouteToggleView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class RouteToggleView: UIView {
    var boolHandler: BoolHandler?
    
    public var id: String?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true
        return view
    }()
    
    public lazy var optionTitle: UILabel = {
        let label = UILabel()
        label.font = .amazonFont(type: .regular, size: 16)
        label.textColor = .black
        return label
    }()
    
    private lazy var optionSwitch: UISwitch = {
        let switchView = UISwitch()
        switchView.accessibilityIdentifier = ViewsIdentifiers.Routing.routeOptionSwitchButton
        switchView.onTintColor = .lsPrimary
        switchView.addTarget(self, action: #selector(changeState), for: .valueChanged)
        switchView.isUserInteractionEnabled = true
        return switchView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    convenience init(title: String) {
        self.init(frame: .zero)
        self.optionTitle.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    @objc func changeState() {
        if optionSwitch.isOn {
            optionSwitch.setOn(true, animated: false)
            boolHandler?(true)
        } else {
            optionSwitch.setOn(false, animated: false)
            boolHandler?(false)
        }
    }
    
    func setState(isOn: Bool) {
        if isOn {
            optionSwitch.setOn(true, animated: false)
            boolHandler?(true)
        } else {
            optionSwitch.setOn(false, animated: false)
            boolHandler?(false)
        }
    }
    
    func setDefaultState(state: Bool) {
        self.optionSwitch.setOn(state, animated: false)
    }
    
    func getState() -> Bool {
        return optionSwitch.isOn
    }
    
    private func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(optionTitle)
        containerView.addSubview(optionSwitch)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        optionTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-14)
        }
        
        optionSwitch.snp.makeConstraints {
            $0.centerY.equalTo(optionTitle.snp.centerY)
            $0.height.equalTo(31)
            $0.trailing.equalToSuperview().offset(-12)
        }
    }
}
