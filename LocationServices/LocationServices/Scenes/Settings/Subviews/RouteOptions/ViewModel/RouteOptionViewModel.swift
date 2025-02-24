//
//  RouteOptionViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class RouteOptionViewModel: RouteOptionViewModelProtocol {
    var delegate: RouteOptionViewModelOutputDelegate?
    
    func saveTollOption(state: Bool) {
        UserDefaultsHelper.save(value: state, key: .tollOptions)
    }
    
    func saveFerriesOption(state: Bool) {
        UserDefaultsHelper.save(value: state, key: .ferriesOptions)
    }
    
    func saveUturnsOption(state: Bool) {
        UserDefaultsHelper.save(value: state, key: .uturnsOptions)
    }
    
    func saveTunnelsOption(state: Bool) {
        UserDefaultsHelper.save(value: state, key: .tunnelsOptions)
    }
    
    func saveDirtRoadsOption(state: Bool) {
        UserDefaultsHelper.save(value: state, key: .dirtRoadsOptions)
    }
    
    func loadData() {
        let tollOption = UserDefaultsHelper.get(for: Bool.self, key: .tollOptions)
        let ferriesOptions = UserDefaultsHelper.get(for: Bool.self, key: .ferriesOptions)
        let uturnsOptions = UserDefaultsHelper.get(for: Bool.self, key: .uturnsOptions)
        let tunnelsOptions = UserDefaultsHelper.get(for: Bool.self, key: .tunnelsOptions)
        let dirtRoadsOptions = UserDefaultsHelper.get(for: Bool.self, key: .dirtRoadsOptions)
        delegate?.updateViews(tollOption: tollOption ?? true, ferriesOption: ferriesOptions ?? true, uturnsOption: uturnsOptions ?? true, tunnelsOption: tunnelsOptions ?? true, dirtRoadsOption: dirtRoadsOptions ?? true)
    }
}
