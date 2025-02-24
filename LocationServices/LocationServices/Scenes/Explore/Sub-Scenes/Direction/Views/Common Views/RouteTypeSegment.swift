//
//  RouteTypeSegment.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import UIKit

final class RouteTypeSegment: UISegmentedControl {

    var routeTypeChangedHandler: Handler<RouteTypes>?
    override init(items: [Any]?) {
        super.init(items: items)
        setup()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let routeTypes = [RouteTypes.car, RouteTypes.pedestrian, RouteTypes.scooter, RouteTypes.truck]
    
    func setup() {
        for i in 0...routeTypes.count-1 {
            self.setImage(routeTypes[i].image, forSegmentAt: i)
        }
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.mapStyleTintColor], for: .selected)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        self.addTarget(self, action: #selector(routeTypeChanged(_:)), for: .valueChanged)
    }
    
    @objc func routeTypeChanged(_ sender: UISegmentedControl) {
        let routeType: RouteTypes = routeTypes[sender.selectedSegmentIndex]
        routeTypeChangedHandler?(routeType)
    }
}
