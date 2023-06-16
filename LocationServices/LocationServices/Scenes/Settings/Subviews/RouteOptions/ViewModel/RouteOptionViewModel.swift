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
    
    func loadData() {
        let tollOption = UserDefaultsHelper.get(for: Bool.self, key: .tollOptions)
        let ferriesOptions = UserDefaultsHelper.get(for: Bool.self, key: .ferriesOptions)
        delegate?.updateViews(tollOption: tollOption ?? true, ferriesOption: ferriesOptions ?? true)
    }
}
