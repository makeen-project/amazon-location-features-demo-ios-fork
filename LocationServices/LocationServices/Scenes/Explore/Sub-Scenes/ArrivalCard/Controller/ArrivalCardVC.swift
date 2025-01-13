//
//  ArrivalCardVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import CoreLocation

final class ArrivalCardVC: UIViewController, UIViewControllerTransitioningDelegate {
    
    enum DetentsSizeClass {
        case allInfo
        case noDistanceValues
        
        var height: CGFloat {
            switch self {
            case .allInfo:
                return 200
            case .noDistanceValues:
                return 174
            }
        }
    }
    
    enum Constants {
        static let titleOffsetiPhone: CGFloat = 20
        static let titleOffsetiPad: CGFloat = 0
    }
    
    private lazy var locationManager: LocationManager = {
        let locationManager = LocationManager(alertPresenter: self)
        return locationManager
    }()
    
    private lazy var arrivalCardView: ArrivalCardView = {
        let titleTopOffset: CGFloat = isInSplitViewController ? Constants.titleOffsetiPad : Constants.titleOffsetiPhone
        return ArrivalCardView(titleTopOffset: titleTopOffset, isCloseButtonHidden: isInSplitViewController)
    }()
    weak var delegate: ExploreNavigationDelegate?
    private var isInSplitViewController: Bool { delegate is SplitViewExploreMapCoordinator }
    var userLocation: (lat: Double?, long: Double?)?
    
    private var authorizationStatusChanged: Bool = false
    private var shouldOpenDirections: Bool = false
    
    var viewModel: ArrivalCardViewModel! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .searchBarBackgroundColor
        arrivalCardView.delegate = self
        arrivalCardView.arrivalCardModel = viewModel
        setupViews()
        
        let barButtonItem = UIBarButtonItem(title: nil, image: .chevronBackward, target: self, action: #selector(dismissArrivalView))
        barButtonItem.tintColor = .lsPrimary
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
        
    private func setupViews() {
        self.view.addSubview(arrivalCardView)
        arrivalCardView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension ArrivalCardVC: ArrivalCardViewModelOutputDelegate {
    @objc func dismissArrivalView() {
        DispatchQueue.main.async { [self] in
            if(isInSplitViewController){
                self.navigationController?.popViewController(animated: true)
            }
            else{
                self.view.removeFromSuperview()
            }
        }
    }
    
    func updateSizeClass(_ sizeClass: DetentsSizeClass) {
        let smallId = UISheetPresentationController.Detent.Identifier("small")
        let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallId) { context in
            return sizeClass.height
        }
        sheetPresentationController?.detents = [smallDetent]
        sheetPresentationController?.largestUndimmedDetentIdentifier = smallId
    }
    
    func setArrivalHeight(_ height: CGFloat)
    {
        self.setBottomSheetHeight(to: height)
    }
}
