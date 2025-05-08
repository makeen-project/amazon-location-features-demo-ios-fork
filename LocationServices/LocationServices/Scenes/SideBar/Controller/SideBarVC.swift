//
//  SideBarVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class SideBarVC: UIViewController {
    
    enum Constants {
        static let horizontalOffset: CGFloat = 16
        static let tableViewVerticalOffset: CGFloat = 16
    }
    
    private let titleLabel: LargeTitleLabel = {
        let label = LargeTitleLabel(labelText: StringConstant.demo)
        return label
    }()
    
    let tableView: UITableView = {
        var tableView = UITableView()
        tableView.accessibilityIdentifier = ViewsIdentifiers.General.sideBarTableView
        return tableView
    }()
    
    weak var delegate: SideBarDelegate?
    var viewModel: SideBarViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupViews()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTableView(keyboardHeight: KeyboardObserver.shared.keyboardHeight)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotifications()
    }
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(Constants.horizontalOffset)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Constants.horizontalOffset)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Constants.tableViewVerticalOffset)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Constants.tableViewVerticalOffset)
        }
    }
    
    private func updateTableView(keyboardHeight: CGFloat) {
        let additionalOffset = keyboardHeight - view.safeAreaInsets.bottom
        tableView.contentInset.bottom = additionalOffset
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectExploreScene(_:)), name: Notification.showExploreScene, object: nil)
    }
    
    @objc override func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        updateTableView(keyboardHeight: keyboardSize.height)
    }
    
    @objc override func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset.bottom = 0
    }
    
    @objc func selectExploreScene(_ notification: NSNotification) {
        tableView.selectRow(at: IndexPath(row: 0, section: 0),
                            animated: true,
                            scrollPosition: .none)
    }
}
