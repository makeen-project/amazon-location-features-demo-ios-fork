//
//  MapStyleVC+CollectionView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension MapStyleVC {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MapStyleCell.self, forCellWithReuseIdentifier: MapStyleCell.reuseId)
        collectionView.register(MapStyleSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MapStyleSectionHeaderView.reuseId)
        collectionView.register(MapStyleSectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: MapStyleSectionFooterView.reuseId)
    }
}

extension MapStyleVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.getSectionsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getItemCount(at: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MapStyleCell.reuseId, for: indexPath) as? MapStyleCell else {
            fatalError("Map Style Cell can't dequeu")
        }
        let data = viewModel.getCellItem(indexPath)
        cell.model = data
        cell.isCellSelected(state: selectedCell == indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view: UICollectionReusableView?
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MapStyleSectionHeaderView.reuseId, for: indexPath)
            (view as? MapStyleSectionHeaderView)?.title = viewModel.getSectionTitle(at: indexPath.section)
        case UICollectionView.elementKindSectionFooter:
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MapStyleSectionFooterView.reuseId, for: indexPath)
        default:
            view = nil
        }
        
        return view ?? UICollectionReusableView()
    }
}
extension MapStyleVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Constants.cellSize
        let totalWidth = collectionView.frame.size.width
        let interitemSpacingSum = minimumInteritemSpacing * (numberOfItemsInRow - 1)
        let itemWidth = (totalWidth - horizontalItemPadding - interitemSpacingSum)/numberOfItemsInRow
        return CGSize(width: itemWidth,
                      height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.size.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let isLastSection = section == viewModel.getSectionsCount() - 1
        if isLastSection {
            return .init(width: collectionView.frame.size.width, height: 0)
        } else {
            return .init(width: collectionView.frame.size.width, height: 17)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MapStyleCell {
            self.selectedCell = indexPath
            cell.isCellSelected(state: true)
            self.viewModel.saveSelectedState(indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return calculateMinimumInteritemSpacing()
    }
    
    func calculateMinimumInteritemSpacing() -> CGFloat {
        let itemsCountPerRow = CGFloat(Constants.itemsCountPerRow)
        let freeSpace = collectionView.frame.width - (Constants.cellSize.width * itemsCountPerRow)
        return (freeSpace / itemsCountPerRow).rounded(.down)
    }
}
