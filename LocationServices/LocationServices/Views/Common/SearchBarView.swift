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
}

extension SearchBarViewOutputDelegate {
    func searchTextActivated() {}
    func searchTextDeactivated() {}
    func searchText(_ text: String?) {}
    func searchTextWith(_ text: String?) {}
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
        view.backgroundColor = .searchBarBackgroundColor
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 20
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
    
    convenience init(becomeFirstResponder: Bool) {
        self.init(frame: .zero)
        searchView.searchViewBecomeFirstResponder(state: becomeFirstResponder)
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
    
    private func configure() {
        self.addSubview(containerView)
        containerView.addSubview(grabberIcon)
        containerView.addSubview(searchView)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        grabberIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(7)
            $0.width.equalTo(36)
            $0.height.equalTo(5)
            $0.centerX.equalToSuperview()
        }
        
        searchView.snp.makeConstraints {
            $0.top.equalTo(grabberIcon.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
        }
    }
    
    @objc private func gestureAction() {
        delegate?.searchTextActivated()
    }
}
