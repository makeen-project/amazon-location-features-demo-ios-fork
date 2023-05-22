//
//  SearchBarView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit


private enum Constant {
    static let keyPathActiveSearchText = "activeSearchText"
}

protocol SearchBarViewOutputDelegate {
    func searchTextActivated()
    func searchTextDeactivated()
    func searchText(_ text: String?)
    func searchTextWith(_ text: String?)
    func searchCancel()
}

extension SearchBarViewOutputDelegate {
    func searchTextActivated() {}
    func searchTextDeactivated() {}
    func searchText(_ text: String?) {}
    func searchTextWith(_ text: String?) {}
    func searchCancel() {}
}

// to keep local history of searching between two screens. Explore and search detail
class SearchBarCache: NSObject {
    static let shared = SearchBarCache()
    private override init() {}
    @objc dynamic var activeSearchText = ""
}

final class SearchBarView: UIView {
    var delegate: SearchBarViewOutputDelegate? {
        didSet {
            if SearchBarCache.shared.activeSearchText.isEmpty == false {
                searchView.setCurrentText(text: SearchBarCache.shared.activeSearchText)
                self.delegate?.searchText(SearchBarCache.shared.activeSearchText)
            }
        }
    }
    
    private let containerView: UIView =  {
        let view = UIView()
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let stackView: UIStackView =  {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    private let grabberIconContainerView: UIView =  {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let grabberIcon: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .searchBarTintColor
        button.layer.cornerRadius = 2.5
        return button
    }()
    
    private let searchView = SearchTextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.accessibilityIdentifier = ViewsIdentifiers.Search.searchBar
        configure()
        
        searchView.passChangedText = { [weak self] value in
            SearchBarCache.shared.activeSearchText = value
            self?.delegate?.searchText(value)
        }
        
        searchView.searchText = { [weak self] value in
            SearchBarCache.shared.activeSearchText = value
            self?.delegate?.searchTextWith(value)
        }
        
        searchView.textFieldActivated = { [weak self] in
            self?.delegate?.searchTextActivated()
        }
        
        searchView.textFieldDeactivated = { [weak self] in
            self?.delegate?.searchTextDeactivated()
        }
        
        searchView.cancelSearchCallback = { [weak self] in
            self?.delegate?.searchCancel()
        }
                
        SearchBarCache.shared.addObserver(self,
                                          forKeyPath: Constant.keyPathActiveSearchText,
                                          options: [.new],                                context: nil)
        
        if SearchBarCache.shared.activeSearchText.isEmpty == false {
            searchView.setCurrentText(text: SearchBarCache.shared.activeSearchText)
            self.delegate?.searchText(SearchBarCache.shared.activeSearchText)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if object is SearchBarCache && keyPath == Constant.keyPathActiveSearchText {
            
            guard let change = change else {
                return
            }
            
            if let newValue = change[.newKey]  {
                
                if let currentText = self.searchView.currentText(), let value = newValue as? String {
                    if currentText != value {
                        self.searchView.setCurrentText(text: value)
                    }
                }
            }
        }
    }
    
    convenience init(becomeFirstResponder: Bool, showGrabberIcon: Bool = true) {
        self.init(frame: .zero)
        searchView.searchViewBecomeFirstResponder(state: becomeFirstResponder)
        grabberIconContainerView.isHidden = !showGrabberIcon
        if becomeFirstResponder {
            let tap = UITapGestureRecognizer(target: self, action: #selector(gestureAction))
            addGestureRecognizer(tap)
            let pan = UIPanGestureRecognizer(target: self, action: #selector(gestureAction))
            addGestureRecognizer(pan)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
        
    func setupTextWith(text: String) {
        searchView.configureTextFieldWith(text: text)
    }
    
    func applyStyles(style: SearchScreenStyle) {
        containerView.backgroundColor = style.backgroundColor
    }
    
    private func configure() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(grabberIconContainerView)
        grabberIconContainerView.addSubview(grabberIcon)
        
        stackView.addArrangedSubview(searchView)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        grabberIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(7)
            $0.width.equalTo(36)
            $0.height.equalTo(5)
            $0.centerX.bottom.equalToSuperview()
        }
        
        searchView.snp.makeConstraints {
            $0.height.equalTo(40)
        }
    }
    
    @objc private func gestureAction() {
        delegate?.searchTextActivated()
    }
}
