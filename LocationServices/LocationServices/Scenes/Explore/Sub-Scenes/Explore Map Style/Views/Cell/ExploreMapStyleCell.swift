//
//  ExploreMapStyleCell.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

private enum Constants {
    static let cellSize = CGSize(width: 160, height: 106)
    static let minimumLineSpacing: CGFloat = 36
    static let itemsCountPerRow = 2
}

final class ExploreMapStyleCell: UITableViewCell {
    
    static let reuseId: String = "ExploreMapSytleTableViewCell"
    private var selectedCell: Int? = nil
    
    private var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.isUserInteractionEnabled = true
        return view
    }()
    
    func updateDatas(isSelected: Bool) {
        mapStyleViewModel = ExploreMapStyleCellViewModel()
        mapStyleViewModel?.delegate = self
        if isSelected {
            mapStyleViewModel?.loadLocalMapData()
        }
    }
    
    private lazy var collectionViewWrapperView: CollectionViewWrapperView = {
        let wrapper = CollectionViewWrapperView()
        wrapper.layoutSubviewsCallback = { [weak self] in
            let horizontalInset = (self?.calculateMinimumInteritemSpacing() ?? 0) / 2
            self?.collectionView.contentInset = .init(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        }
        return wrapper
    }()
    
    var collectionView: UICollectionView {
        return collectionViewWrapperView.collectionView
    }
    
    var mapStyleViewModel: ExploreMapStyleCellViewModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupCollectionView()
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupCollectionView() {
        collectionView.isUserInteractionEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MapStyleCell.self, forCellWithReuseIdentifier: MapStyleCell.reuseId)
    }
    
    private func setupViews() {
        self.contentView.addSubview(containerView)
        containerView.addSubview(collectionViewWrapperView)
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
            $0.bottom.equalToSuperview().offset(-8)
        }
        collectionViewWrapperView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-24)
        }
    }
}

extension ExploreMapStyleCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mapStyleViewModel?.getItemCount() ?? 0
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MapStyleCell.reuseId, for: indexPath) as? MapStyleCell else {
            fatalError("Map Style Cell can't dequeu")
        }
        let data = mapStyleViewModel?.getCellItem(indexPath)
        cell.model = data
        cell.isCellSelected(state: selectedCell == indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mapStyleViewModel?.saveSelectedState(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Constants.cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return calculateMinimumInteritemSpacing()
    }
    
    func calculateMinimumInteritemSpacing() -> CGFloat {
        let itemsCountPerRow = CGFloat(Constants.itemsCountPerRow)
        let freeSpace = collectionView.frame.width - (Constants.cellSize.width * itemsCountPerRow)
        return (freeSpace / itemsCountPerRow).rounded(.down)
    }
}

extension ExploreMapStyleCell: ExploreMapStyleCellViewModelOutputDelegate {
    func loadData(selectedIndex: Int?) {
        selectedCell = selectedIndex
        collectionView.reloadData()
    }
}

private final class CollectionViewWrapperView: UIView {
    
    private(set) var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    var layoutSubviewsCallback: (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsCallback?()
    }
    
    private func setupViews() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}
