//
//  MapStyleVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class MapStyleVC: UIViewController {
    
    enum Constants {
        static let horizontalOffset: CGFloat = 16
        static let cellSize = CGSize(width: 160, height: 106)
        static let minimumLineSpacing: CGFloat = 36
        static let itemsCountPerRow = 2
    }
    
    var selectedCell: IndexPath = IndexPath(row: 0, section: 0)
    var viewModel: MapStyleViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private var screenTitleLabel: LargeTitleLabel = {
        let label = LargeTitleLabel(labelText: StringConstant.mapStyle)
        return label
    }()
    
    var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    var colorSegment: ColorSegmentControl? = nil
    
    var isLargerPad: Bool {
        max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) > largerPadSideSizeThreshold
    }
    
    var numberOfItemsInRow: CGFloat {
        let device = UIDevice.current
        switch device.userInterfaceIdiom {
        case .pad:
            switch device.getDeviceOrientation() {
            case .landscapeLeft,
                    .landscapeRight:
                return 4
            default:
                if isLargerPad {
                    return 3
                } else {
                    return 2
                }
            }
        default:
            return 3
        }
    }
    
    private let largerPadSideSizeThreshold: CGFloat = 1300
    let horizontalItemPadding: CGFloat = 25
    var itemHeight: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return isLargerPad ? 120 : 106
        default:
            return 106
        }
    }
    var minimumInteritemSpacing: CGFloat {
        let device = UIDevice.current
        switch device.userInterfaceIdiom {
        case .pad:
            switch device.getDeviceOrientation() {
            case .landscapeLeft, .landscapeRight:
                if isLargerPad {
                    return 88
                } else {
                    return 50
                }
            default:
                return 0
            }
        default:
            return 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadLocalMapData()
        setupCollectionView()
        setupViews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Reloading view each time in case there has been an orientation change
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    private func setupViews() {
        let colorNames = [MapStyleColorType.light.colorName, MapStyleColorType.dark.colorName]
        colorSegment = ColorSegmentControl(items: colorNames)
        
        navigationController?.navigationBar.tintColor = .mapDarkBlackColor
        navigationItem.title = UIDevice.current.isPad ? "" :  StringConstant.mapStyle
        view.backgroundColor = .white
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        if isPad {
            view.addSubview(screenTitleLabel)
            screenTitleLabel.snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide)
                $0.horizontalEdges.equalToSuperview().inset(Constants.horizontalOffset)
            }
        }
        
        self.view.addSubview(collectionView)
        self.view.addSubview(colorSegment!)
        
        collectionView.snp.makeConstraints {
            if isPad {
                $0.top.equalTo(screenTitleLabel.snp.bottom)
            } else {
                $0.top.equalTo(self.view.safeAreaLayoutGuide)
            }
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(280)
        }
        
        colorSegment!.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            if UIDevice.current.userInterfaceIdiom == .pad {
                $0.width.equalTo(400)
            }
            else {
                $0.width.equalToSuperview().offset(-50)
            }
            $0.height.equalTo(40)
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
