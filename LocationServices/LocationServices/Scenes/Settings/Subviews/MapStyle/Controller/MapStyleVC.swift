//
//  MapStyleVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class MapStyleVC: UIViewController {
    var selectedCell: IndexPath = IndexPath(row: 0, section: 0)
    
    var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    var viewModel: MapStyleViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadLocalMapData()
        setupCollectionView()
        setupViews()
    }
    
    private func setupViews() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .mapDarkBlackColor
        self.navigationItem.title = "Map style"
        self.view.backgroundColor = .white
        
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
}

extension MapStyleVC: MapStyleViewModelOutputDelegate {
    func loadData(selectedIndexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            self?.selectedCell = selectedIndexPath
            self?.collectionView.reloadData()
        }
    }
}
