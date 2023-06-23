//
//  GeofenceDashboard+Tableview.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

extension GeofenceDashboardVC {
    func setupTableView() {
        tableView.register(GeofenceDashboardCell.self, forCellReuseIdentifier: GeofenceDashboardCell.reuseId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 64
    }
}

extension GeofenceDashboardVC: UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
      }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GeofenceDashboardCell.reuseId, for: indexPath) as? GeofenceDashboardCell else {
             fatalError("Geofence Dashboard Cell couldn't Initilized")
        }
        let data = datas[indexPath.row]
        cell.model = GeofenceDashboardCellModel(model: data)
        
        cell.deleteButtonAction = { [weak self] id in
            self?.deleteItem(id: id)
        }
        return cell
    }
    
    private func deleteItem(id: String) {
        let data = self.datas.filter { $0.id == id }.first
        if let model = data {
            viewModel.deleteGeofenceData(model: model)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = datas[indexPath.row]
        self.addGeofence?((viewModel.geofences, true, data, self.userlocation))
    }
}
