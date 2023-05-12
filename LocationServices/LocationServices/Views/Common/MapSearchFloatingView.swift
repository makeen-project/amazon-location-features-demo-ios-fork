//
//  MapSearchFloatingView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

enum SideBarState {
    case fullSideBar
    case fullSecondaryScreen
    case onlyButtonSecondaryScreen
    
    var image: UIImage? {
        switch self {
        case .fullSideBar:
            return .sidebarLeft
        case .fullSecondaryScreen, .onlyButtonSecondaryScreen:
            return .arrowUpLeftAndArrowDownRight
        }
    }
    
    var showSearch: Bool {
        switch self {
        case .fullSideBar, .fullSecondaryScreen:
            return true
        case .onlyButtonSecondaryScreen:
            return false
        }
    }
}

enum MapSearchState {
    case hidden
    case primaryVisible
    case onlySecondaryVisible
}

protocol MapSearchFloatingViewDelegate: AnyObject {
    func changeSplitState(to state: SideBarState)
    func searchActivated()
}

final class MapSearchFloatingView: UIView {
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .white
        stackView.layer.cornerRadius = 8
        
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 0
        return stackView
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
    
    private let searchView = SearchBarView(becomeFirstResponder: true, showGrabberIcon: false)
    
    weak var delegate: MapSearchFloatingViewDelegate?
    private var sideBarButtonState: SideBarState = .fullSideBar
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    func setSideBarButtonState(_ state: SideBarState) {
        sideBarButtonState = state
        sideBarButton.setImage(state.image, for: .normal)
        searchView.isHidden = !state.showSearch
        separatorView.isHidden = !state.showSearch
    }
    
    private func configure() {
        self.addSubview(containerStackView)
        containerStackView.addArrangedSubview(sideBarButton)
        containerStackView.addArrangedSubview(searchView)
        containerStackView.addArrangedSubview(separatorView)
        
        containerStackView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        sideBarButton.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.width.equalTo(sideBarButton.snp.height)
        }
        
        separatorView.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalToSuperview().multipliedBy(0.8)
        }
        
        searchView.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.width.equalTo(300)
        }
        
        searchView.delegate = self
    }
    
    @objc private func actionPerformed() {
        delegate?.changeSplitState(to: sideBarButtonState)
    }
}

extension MapSearchFloatingView: SearchBarViewOutputDelegate {
    func searchTextActivated() {
        delegate?.searchActivated()
    }
}
