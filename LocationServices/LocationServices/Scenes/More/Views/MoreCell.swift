//
//  MoreCell.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

enum MoreCellType {
    case attribution, termsAndConditions, about
    
    var title: String {
        switch self {
        case .attribution:
            return StringConstant.MoreTab.cellAttributionTitle
        case .termsAndConditions:
            return StringConstant.MoreTab.cellLegalTitle
        case .about:
            return StringConstant.MoreTab.cellAboutTitle
        }
    }
}

struct MoreCellModel {
    let type: MoreCellType
}

final class MoreCell: UITableViewCell {

    enum Constants {
        static let itemTitleFont: UIFont = .amazonFont(type: .regular, size: 16)
    }
    
    static let reuseId: String = "MoreCell"
    
    var model: MoreCellModel! {
        didSet {
            self.itemTitle.text = model.type.title
        }
    }
    
    
    private var containerView: UIView = UIView()
    
    private var itemTitle: UILabel = {
        var label = UILabel()
        label.font = Constants.itemTitleFont
        label.textColor = .mapDarkBlackColor
        label.textAlignment = .left
        return label
    }()
    
    private var arrowIcon: UIImageView = {
        let image = UIImage(systemName: "chevron.right")
        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .searchBarTintColor
        return iv
    }()
    
    private var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private var separatorView: UIView = {
        var view = UIView()
        view.backgroundColor = .textFieldBackgroundColor
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {

        textStackView.removeArrangedSubViews()
        textStackView.addArrangedSubview(itemTitle)
        
        self.addSubview(containerView)
        containerView.addSubview(arrowIcon)
        containerView.addSubview(textStackView)
        containerView.addSubview(separatorView)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        arrowIcon.snp.makeConstraints {
            $0.height.width.equalTo(14)
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalToSuperview()
        }
        
        textStackView.snp.makeConstraints {
            $0.height.equalTo(46)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalTo(arrowIcon.snp.leading)
            $0.centerY.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview()
        }
    }
}
