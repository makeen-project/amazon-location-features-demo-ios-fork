//
//  ArrivalCardView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class ArrivalCardView: UIView {
    weak var delegate: ArrivalCardViewModelOutputDelegate?
    var arrivalCardModel: ArrivalCardViewModel! {
        didSet {
            self.poiTitle.text = "You've arrived!"
            self.poiLabel.text = arrivalCardModel.route.destinationPlaceName
            if let address = arrivalCardModel.route.destinationPlaceAddress, address != "" {
                self.poiAddress.text = address
            }
        }
    }
    
    private var titleTopOffset: CGFloat = 20
    
    private let containerView: UIView =  {
       let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 20
        view.isUserInteractionEnabled = true
        return view
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.closeIcon, for: .normal)
        button.tintColor = .closeButtonTintColor
        button.backgroundColor = .closeButtonBackgroundColor
        button.isUserInteractionEnabled = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(poiCardDismiss), for: .touchUpInside)
        return button
    }()

    private let poiTitle: LargeTitleLabel = {
        let label = LargeTitleLabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let poiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .amazonFont(type: .bold, size: 14)
        label.textColor = .lsTetriary
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let poiAddress: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .amazonFont(type: .regular, size: 14)
        label.textColor = .searchBarTintColor
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.ArrivalCard.doneButton
        button.backgroundColor = .lsPrimary
        button.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 10
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
        return button
    }()
    
    private let doneIcon: UIImageView = {
        let iv = UIImageView(image: .checkMark)
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()
    
    private let doneLabel: UILabel = {
        let label = UILabel()
        label.text = StringConstant.done
        label.textAlignment = .left
        label.font = .amazonFont(type: .bold, size: 16)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let buttonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
   
    convenience init(titleTopOffset: CGFloat, isCloseButtonHidden: Bool) {
        self.init()
        self.titleTopOffset = titleTopOffset
        self.accessibilityIdentifier = ViewsIdentifiers.ArrivalCard.arrivalCardView
        setupViews()
        closeButton.isHidden = isCloseButtonHidden
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    @objc private func poiCardDismiss() {
        delegate?.dismissArrivalView()
    }
    
    func setupViews() {
        self.addSubview(containerView)
        headerView.addSubview(poiTitle)
        headerView.addSubview(closeButton)
        
        stackView.addArrangedSubview(poiLabel)
        stackView.addArrangedSubview(poiAddress)
        
        containerView.addSubview(headerView)
        containerView.addSubview(stackView)
        containerView.addSubview(doneButton)
        
        doneButton.addSubview(buttonContainerView)
        buttonContainerView.addSubview(doneIcon)
        buttonContainerView.addSubview(doneLabel)
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.bottom.equalToSuperview()
        }
        
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-11)
            $0.height.width.equalTo(30)
        }
        
        poiTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(titleTopOffset)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(closeButton.snp.leading).offset(-5)
            $0.height.equalTo(28)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(12)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        poiLabel.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(18)
        }
        
        poiAddress.snp.makeConstraints {
            $0.top.equalTo(poiLabel.snp.bottom).offset(3)
            $0.height.greaterThanOrEqualTo(18)
        }
        
        doneButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.top.equalTo(stackView.snp.bottom).offset(16)
        }
        
        buttonContainerView.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.width.equalTo(120)
            $0.centerX.centerY.equalToSuperview()
        }
        
        doneIcon.snp.makeConstraints {
            $0.height.width.equalTo(22)
            $0.leading.equalToSuperview()
        }
        
        doneLabel.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.width.equalTo(77)
            $0.leading.equalTo(doneIcon.snp.trailing).offset(19)
        }
    }
    
    @objc func doneButtonAction() {
        delegate?.dismissArrivalView()
    }
}
