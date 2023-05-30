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

struct SearchBarStyle {
    let backgroundColor: UIColor
    let textFieldBackgroundColor: UIColor
}

final class SearchBarView: UIView {
    
    enum Constants {
        static let textFieldHeight: CGFloat = 40
        
        static let grabberIconTopOffset: CGFloat = 7
        static let grabberIconWidth: CGFloat = 36
        static let grabberIconHeight: CGFloat = 5
    }
    
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
    private var shouldFillHeight: Bool = false
    private var horizontalPadding: CGFloat = 16
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.accessibilityIdentifier = ViewsIdentifiers.Search.searchBar
        
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
    
    convenience init(becomeFirstResponder: Bool, showGrabberIcon: Bool = true, shouldFillHeight: Bool = false, horizontalPadding: CGFloat = 16) {
        self.init(frame: .zero)
        self.shouldFillHeight = shouldFillHeight
        self.horizontalPadding = horizontalPadding
        configure()
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
    
    func applyStyle(_ style: SearchBarStyle) {
        containerView.backgroundColor = style.backgroundColor
        searchView.applyStyle(backgroundColor: style.textFieldBackgroundColor)
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
            $0.leading.equalToSuperview().offset(horizontalPadding)
            $0.trailing.equalToSuperview().offset(-horizontalPadding)
            if shouldFillHeight {
                $0.bottom.equalToSuperview()
            }
        }
        
        grabberIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Constants.grabberIconTopOffset)
            $0.width.equalTo(Constants.grabberIconWidth)
            $0.height.equalTo(Constants.grabberIconHeight)
            $0.centerX.bottom.equalToSuperview()
        }
        
        if !shouldFillHeight {
            searchView.snp.makeConstraints {
                $0.height.equalTo(Constants.textFieldHeight)
            }
        }
    }
    
    @objc private func gestureAction() {
        delegate?.searchTextActivated()
    }
}
