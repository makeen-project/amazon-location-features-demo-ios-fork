//
//  TrackingHistory+TableView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension TrackingSimulationController {
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.sectionHeaderTopPadding = 0
        self.tableView.register(TrackSimulationCell.self, forCellReuseIdentifier: TrackSimulationCell.reuseId)
    }
}

extension TrackingSimulationController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.trackingRowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = getActiveRouteCoordinates().count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackSimulationCell.reuseId, for: indexPath) as? TrackSimulationCell else {
            fatalError(.errorCellCannotBeInititalized)
        }
        let data = getActiveRouteCoordinates()[indexPath.row]
        cell.model = data
        return cell
    }
    
}
