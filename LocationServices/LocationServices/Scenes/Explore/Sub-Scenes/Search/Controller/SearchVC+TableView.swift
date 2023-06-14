//
//  SearchVC+TableView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension SearchVC {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchCell.self, forCellReuseIdentifier: SearchCell.reuseId)
        tableView.register(SearchCell.self, forCellReuseIdentifier: SearchCell.reuseCompactId)
    }
}

extension SearchVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension SearchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if viewModel.numberOfRowsInSection() == 0 && !isInitalState {
            tableView.setEmptyView()
        } else {
            tableView.restore()
        }
        
        return viewModel.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = viewModel.getSearchCellModel()
        var model:SearchCellViewModel?
        if indexPath.row < data.count {
            model =  data[indexPath.row]
        }
        let reuseId = model?.searchType == .search ? SearchCell.reuseId : SearchCell.reuseCompactId
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as? SearchCell else {
            fatalError("Search Cell Can't be found")
        }
        cell.applyStyles(style: SearchCellStyle(style: searchScreenStyle))
        
        // safe check - data for model can be 0 if we make search queries too quickly
        if model != nil {
            cell.model = model
        }
         
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = viewModel.searchSelectedPlaceWith(indexPath, lat: userLocation?.lat, long: userLocation?.long)
        if state {
            self.dismiss(animated: true)
        } else {
            self.sheetPresentationController?.selectedDetentIdentifier = .medium
        }
    }
}
