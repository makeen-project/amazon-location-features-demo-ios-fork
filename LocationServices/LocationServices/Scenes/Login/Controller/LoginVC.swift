//
//  LoginVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SafariServices

final class LoginVC: UIViewController {
    
    enum Constants {
        static let footerViewHeight: CGFloat = 36
        static let stackViewBottomOffset: CGFloat = 32
        static let scrollViewBottomOffset: CGFloat = -24
        
        static let horizontalOffset: CGFloat = 16
        static let bottomButtonHeight: CGFloat = 48
        static let bottomButtonStackViewOffset: CGFloat = 5
    }
    
    var postLoginHandler: VoidHandler?
    var dismissHandler: VoidHandler?
    var isFromSettingScene: Bool = false
    
    private var identityPoolId: String?
    private var userPoolId: String?
    private var userPoolClientId: String?
    private var userDomain: String?
    private var webSocketUrl: String?
    
    var viewModel: LoginViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private let scrollView: UIScrollView = {
        let sc = UIScrollView()
        sc.alwaysBounceVertical = true
        sc.isDirectionalLockEnabled = true
        return sc
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        return stackView
    }()
    
    private var loginView: LoginDefaultInformationView = LoginDefaultInformationView()
    private var loginForm: LoginFormView = LoginFormView()
    private var footerView: LoginFooterView = LoginFooterView()
    
    private var bottomButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        return stackView
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.AWSConnect.signInButton
        button.backgroundColor = .tabBarTintColor
        button.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 10
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isUserInteractionEnabled = true
        button.titleLabel?.font = .amazonFont(type: .bold, size: 16)
        button.addTarget(self, action: #selector(signInAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.AWSConnect.signOutButton
        button.backgroundColor = .navigationRedButton
        button.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 10
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isUserInteractionEnabled = true
        button.titleLabel?.font = .amazonFont(type: .bold, size: 16)
        button.addTarget(self, action: #selector(signOutAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.AWSConnect.connectButton
        button.backgroundColor = .tabBarTintColor
        button.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 10
        button.setTitle("Connect", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(connectButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var disconnectButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.AWSConnect.disconnectButton
        button.backgroundColor = .navigationRedButton
        button.contentMode = .scaleAspectFit
        button.isHidden = true
        button.layer.cornerRadius = 10
        button.setTitle("Disconnect from AWS", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(disconnectButtonAction), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsViewsUpdate()
        setupHandlers()
        view.backgroundColor = .white
        setupKeyboardNotifications()
        setup()
        updateAccordingToAppState()
    }
    
    private func updateAccordingToAppState() {
        let state =  isFromSettingScene && viewModel.hasLocalUser()
        
        let appState = UserDefaultsHelper.getAppState()
        
        self.loginForm.isHidden = state
        self.connectButton.isHidden = state
        self.footerView.isHidden = state
        
        if appState == .initial || appState == .defaultAWSConnected {
            self.connectButton.isHidden = false
            
            self.disconnectButton.isHidden = true
            self.signInButton.isHidden = true
            self.signOutButton.isHidden = true
        } else if appState == .customAWSConnected {
            self.connectButton.isHidden = true
            
            self.disconnectButton.isHidden = false
            self.signInButton.isHidden = false
            self.signOutButton.isHidden = true
        } else if appState == .loggedIn {
            self.connectButton.isHidden = true
            
            self.disconnectButton.isHidden = false
            self.signInButton.isHidden = true
            self.signOutButton.isHidden = false
        }
    }
    
    private func settingsViewsUpdate() {
        loginView.hideCloseButton(state: isFromSettingScene)
        if isFromSettingScene {
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationBar.tintColor = .mapDarkBlackColor
            self.navigationItem.title = "AWS CloudFormation"
            self.view.backgroundColor = .white
            
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.backgroundColor = .white
            navigationBarAppearance.titleTextAttributes = [
                .font: UIFont.amazonFont(type: .bold, size: 16),
                .foregroundColor: UIColor.lsTetriary]
            self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
            self.navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        }
    }
    
    private func setupKeyboardNotifications() {
        scrollView.keyboardDismissMode = .onDrag
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc private func signInAction() {
        if let navigationController {
            (UIApplication.shared.delegate as? AppDelegate)?.navigationController = navigationController
        }
        
        viewModel.login()
    }
    
    @objc private func signOutAction() {
        if let navigationController {
            (UIApplication.shared.delegate as? AppDelegate)?.navigationController = navigationController
        }
        
        viewModel.logout()
    }
    
    @objc func connectButtonAction() {
        /// Empty fields will be updated  after unused fields activated.
        guard let identityPoolIdText = identityPoolId, identityPoolIdText.count > 0,
              let userPoolIdText = userPoolId, userPoolIdText.count > 0,
              let userPoolClientIdText = userPoolClientId, userPoolClientIdText.count > 0,
              let userDomainText = userDomain, userDomainText.count > 0,
              let webSocketUrlText = webSocketUrl, webSocketUrlText.count > 0 else {
            
            let alert = UIAlertController(title: "Cannot connect",
                                          message: "Check if all fields are filled", preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction!) in
            }
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.connectAWS(identityPoolId: self?.identityPoolId,
                                       userPoolId: self?.userPoolId,
                                       userPoolClientId: self?.userPoolClientId,
                                       userDomain: self?.userDomain,
                                       websocketUrl: self?.webSocketUrl)
        }
    }
    
    @objc func disconnectButtonAction() {
        DispatchQueue.main.async { [weak self] in
            NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
            self?.viewModel.disconnectAWS()
        }
    }
    
    private func updateStateConnectButton() {
        guard identityPoolId != nil, identityPoolId?.isEmpty == false,
              userPoolClientId != nil, userPoolClientId?.isEmpty == false,
                userPoolId != nil, userPoolId?.isEmpty == false,
              userDomain != nil, userDomain?.isEmpty == false,
              webSocketUrl != nil, webSocketUrl?.isEmpty == false else {
                  
                  connectButton.isUserInteractionEnabled = false
            return
        }
        
        connectButton.isUserInteractionEnabled = true
    }
    
    private func setupHandlers() {
        loginForm.identityPoolIdHandler = { [weak self] value in
            self?.identityPoolId = value
        }
        
        loginForm.userPoolClientIdHandler = { [weak self] value in
            self?.userPoolClientId = value
        }
        
        loginForm.useryPoolIdHandler = { [weak self] value in
            self?.userPoolId = value
        }
        
        loginForm.userDomainHandler = { [weak self] value in
            self?.userDomain = value
        }
        
        loginView.dismissHandler = { [weak self] in
            self?.dismissHandler?()
        }
        
        loginForm.webSocketHandler = { [weak self] value in
            self?.webSocketUrl = value
        }
        
        loginView.learnMoreLinkTappedHandler = { [weak self] urlString in
            if let url = URL(string: urlString) {
                let config = SFSafariViewController.Configuration()
                let vc = SFSafariViewController(url: url, configuration: config)
                self?.present(vc, animated: true)
            }
        }
    }
    
    private func setup() {
        
        let appState = UserDefaultsHelper.getAppState()
        scrollView.contentInset = .init(top: 0, left: 0, bottom: -Constants.scrollViewBottomOffset, right: 0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(loginView)
        stackView.addArrangedSubview(loginForm)
        stackView.addArrangedSubview(footerView)
        
        view.addSubview(bottomButtonStackView)
        bottomButtonStackView.addArrangedSubview(signInButton)
        bottomButtonStackView.addArrangedSubview(signOutButton)
        
        bottomButtonStackView.addArrangedSubview(connectButton)
        bottomButtonStackView.addArrangedSubview(disconnectButton)
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.width.equalToSuperview()
            $0.bottom.greaterThanOrEqualToSuperview().offset(-Constants.stackViewBottomOffset)
        }
        
        footerView.snp.makeConstraints {
            $0.height.equalTo(Constants.footerViewHeight)
        }
        
        bottomButtonStackView.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.bottom).offset(Constants.scrollViewBottomOffset)
            $0.leading.trailing.equalToSuperview().inset(Constants.horizontalOffset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Constants.bottomButtonStackViewOffset)
        }
        
        signInButton.snp.makeConstraints {
            $0.height.equalTo(Constants.bottomButtonHeight)
        }
        
        signOutButton.snp.makeConstraints {
            $0.height.equalTo(Constants.bottomButtonHeight)
        }
        
        connectButton.snp.makeConstraints {
            $0.height.equalTo(Constants.bottomButtonHeight)
        }
        
        disconnectButton.snp.makeConstraints {
            $0.height.equalTo(Constants.bottomButtonHeight)
        }
    }
}
extension LoginVC: LoginViewModelOutputDelegate {
    func cloudConnectionCompleted() {
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
        postLoginHandler?()
    }
    
    func cloudConnectionDisconnected() {
        updateAccordingToAppState()
    }
    
    func loginCompleted() {
        // TODO: investigate crash cause
        //NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
        
        DispatchQueue.main.async{
            self.setup()
            self.updateAccordingToAppState()
        }
    }
    
    func logoutCompleted() {
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
        
        DispatchQueue.main.async{
            self.setup()
            self.updateAccordingToAppState()
        }
    }
    
    func identityPoolIdValidationSucceed() {
        UserDefaultsHelper.save(value: isFromSettingScene, key: .awsCustomConnectFromSettings)
        UserDefaultsHelper.setAppState(state: .prepareCustomAWSConnect)
        
        updateAccordingToAppState()
    }
}
