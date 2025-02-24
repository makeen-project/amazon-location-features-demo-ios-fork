//
//  RouteOptionRowView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class RouteOptionRowView: UIView {
    var tollHandlers: BoolHandler?
    var ferriesHandlers: BoolHandler?
    var uturnsHandlers: BoolHandler?
    var tunnelsHandlers: BoolHandler?
    var dirtRoadsHandlers: BoolHandler?
    
    private let tollOption: RouteOptionView = {
        let view = RouteOptionView(title: StringConstant.avoidTolls)
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.avoidTollsOptionContainer
        return view
    }()
    
    private var firstSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        return view
    }()
    
    private let ferriesOption: RouteOptionView = {
        let view = RouteOptionView(title: StringConstant.avoidFerries)
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.avoidFerriesOptionContainer
        return view
    }()
    
    private let uturnsOption: RouteOptionView = {
        let view = RouteOptionView(title: StringConstant.avoidUturns)
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.avoidUturnsOptionContainer
        return view
    }()
    
    private let tunnelsOption: RouteOptionView = {
        let view = RouteOptionView(title: StringConstant.avoidTunnels)
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.avoidTunnelsOptionContainer
        return view
    }()
    
    private let dirtRoadsOption: RouteOptionView = {
        let view = RouteOptionView(title: StringConstant.avoidDirtRoads)
        view.accessibilityIdentifier = ViewsIdentifiers.Routing.avoidDirtRoadsOptionContainer
        return view
    }()
    
    private let optionStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .equalSpacing
        sv.spacing = 0
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHandlers()
        setupViews()
    }
    
    func setLocalValues(toll: Bool, ferries: Bool, uturns: Bool, tunnels: Bool, dirtRoads: Bool) {
        tollOption.setDefaultState(state: toll)
        ferriesOption.setDefaultState(state: ferries)
        uturnsOption.setDefaultState(state: uturns)
        tunnelsOption.setDefaultState(state: tunnels)
        dirtRoadsOption.setDefaultState(state: dirtRoads)
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupHandlers() {
        ferriesOption.boolHandler = { [weak self] option in
            self?.ferriesHandlers?(option)
            
         }
        
        tollOption.boolHandler = { [weak self] option in
            self?.tollHandlers?(option)
        }
        
        uturnsOption.boolHandler = { [weak self] option in
            self?.uturnsHandlers?(option)
        }
        
        tunnelsOption.boolHandler = { [weak self] option in
            self?.tunnelsHandlers?(option)
        }
        
        dirtRoadsOption.boolHandler = { [weak self] option in
            self?.dirtRoadsHandlers?(option)
        }
    }
    
    
    private func setupViews() {
        optionStackView.removeArrangedSubViews()
        optionStackView.addArrangedSubview(tollOption)
        optionStackView.addArrangedSubview(firstSeperatorView)
        optionStackView.addArrangedSubview(ferriesOption)
        optionStackView.addArrangedSubview(uturnsOption)
        optionStackView.addArrangedSubview(tunnelsOption)
        optionStackView.addArrangedSubview(dirtRoadsOption)
        
        self.addSubview(optionStackView)
                
        tollOption.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        firstSeperatorView.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        ferriesOption.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        uturnsOption.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        tunnelsOption.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        dirtRoadsOption.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        optionStackView.snp.makeConstraints {
            $0.top.trailing.leading.bottom.equalToSuperview()
        }
    }
}
