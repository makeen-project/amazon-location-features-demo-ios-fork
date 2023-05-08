//
//  MapSearchFloatingView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

enum SideBarButtonState {
    case sidebar
    case fullscreen
    
    var image: UIImage? {
        switch self {
        case .sidebar:
            return .sidebarLeft
        case .fullscreen:
            return .arrowUpLeftAndArrowDownRight
        }
    }
}

final class MapSearchFloatingView: UIView {
    
    private let containerView: UIView =  {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var sideBarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(sideBarButtonState.image, for: .normal)
        button.tintColor = .lsPrimary
        button.addTarget(self, action: #selector(actionPerformed), for: .touchUpInside)
        return button
    }()
    
    private let separatorView: UIView =  {
        let view = UIView()
        view.backgroundColor = .lsLight3
        return view
    }()
    
    private let searchView = SearchTextField()
    
    weak var delegate: MapSearchFloatingViewDelegate?
    private var sideBarButtonState: SideBarButtonState = .sidebar
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    func setSideBarButtonState(_ state: SideBarButtonState) {
        sideBarButtonState = state
        sideBarButton.setImage(state.image, for: .normal)
    }
    
    private func configure() {
        self.addSubview(containerView)
        containerView.addSubview(sideBarButton)
        containerView.addSubview(searchView)
        containerView.addSubview(separatorView)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        sideBarButton.snp.makeConstraints {
            $0.width.equalTo(sideBarButton.snp.height)
            $0.top.bottom.equalToSuperview()
            $0.centerY.leading.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints {
            $0.leading.equalTo(sideBarButton.snp.trailing)
            $0.width.equalTo(1)
            $0.height.equalToSuperview().multipliedBy(0.8)
            $0.centerY.equalToSuperview()
        }
        
        searchView.snp.makeConstraints {
            $0.leading.equalTo(separatorView.snp.trailing)
            $0.width.equalTo(300)
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        searchView.textFieldActivated = { [weak self] in
            self?.delegate?.searchActivated()
        }
    }
    
    @objc private func actionPerformed() {
        delegate?.changeSplitState(to: sideBarButtonState)
    }
}
