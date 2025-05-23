//
//  CommonSelectableCell.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

private enum CommonSelectableCellConstants {
    static let checkMarkImage = UIImage.checkMark
}

struct CommonSelectableCellModel {
    let title: String
    let subTitle: String?
    var isSelected: Bool
    var identifier: String
    var unitType: UnitTypes?
}

final class CommonSelectableCell: UITableViewCell {
    static let reuseId: String = "commonCellSelectableCellID"
    
    var model: CommonSelectableCellModel! {
        didSet {
            self.accessibilityIdentifier = model.identifier
            self.title.text = model.title
            self.subtitle.text = model.subTitle
            
            self.subtitle.isHidden = model.subTitle != nil ? false : true
            isCellSelected(model.isSelected)
        }
    }
    
    private var containerView: UIView = UIView()
    private var title: UILabel = {
        var label = UILabel()
        label.font = .amazonFont(type: .regular, size: 16)
        label.textColor = .lsTetriary
        label.applyLocaleDirection()
        return label
    }()
    
    private var subtitle: UILabel = {
        var label = UILabel()
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .lsGrey
        label.applyLocaleDirection()
        return label
    }()
    
    private var selectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(nil, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    private var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    func isCellSelected(_ state: Bool) {
        if state {
            accessibilityTraits = [.selected]
            selectionButton.setImage(CommonSelectableCellConstants.checkMarkImage, for: .normal)
            selectionButton.tintColor = .lsPrimary
        } else {
            accessibilityTraits = []
            selectionButton.setImage(nil, for: .normal)
        }
    }
}

private extension CommonSelectableCell {
   
    private func setupViews() {
        textStackView.removeArrangedSubViews()
        textStackView.addArrangedSubview(title)
        textStackView.addArrangedSubview(subtitle)
        self.addSubview(containerView)
        containerView.addSubview(selectionButton)
        containerView.addSubview(textStackView)
            
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        title.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
        }
        
        subtitle.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(8)
        }
        
        selectionButton.snp.makeConstraints {
            $0.height.width.equalTo(20)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        textStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.height.equalTo(72)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(selectionButton.snp.leading)
        }
    }
}
