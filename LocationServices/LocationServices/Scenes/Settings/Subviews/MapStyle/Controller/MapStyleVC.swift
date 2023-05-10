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
    var viewModel: MapStyleViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private var screenTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .amazonFont(type: .bold,
                                 size: 20)
        label.text = StringConstant.mapStyle
        return label
    }()
    
    var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadLocalMapData()
        setupCollectionView()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationController?.isNavigationBarHidden = false
        } else {
            navigationController?.navigationBar.isHidden = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationController?.isNavigationBarHidden = true
        } else {
            navigationController?.navigationBar.isHidden = false
        }
    }
    
    private func setupViews() {
        self.navigationController?.navigationBar.tintColor = .mapDarkBlackColor
        self.navigationItem.title = StringConstant.mapStyle
        self.view.backgroundColor = .white
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        if isPad {
            view.addSubview(screenTitleLabel)
            screenTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
                make.horizontalEdges.equalToSuperview().inset(24)
            }
        }
        
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            if isPad {
                $0.top.equalTo(screenTitleLabel.snp.bottom)
            } else {
                $0.top.equalTo(self.view.safeAreaLayoutGuide)
            }
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
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
