//
//  TermsAndConditionsVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import SafariServices

final class TermsAndConditionsVC: UIViewController {
    
    // MARK: - Views
    private var desctiptionTextView: UITextView = {
        let tw = UITextView()
        
        let text = StringConstant.About.descriptionTitle
        let attributedString = NSMutableAttributedString(string: text)
        let clickableSets = [
            (StringConstant.About.appTermsOfUse, StringConstant.About.appTermsOfUseURL)
        ]
        
        clickableSets.forEach { clickableText, urlString in
            guard let url = URL(string: urlString) else { return }
            let range = (attributedString.string as NSString).range(of: clickableText)
            attributedString.setAttributes([.link: url], range: range)
        }
        
        tw.linkTextAttributes = [
            .foregroundColor: UIColor.lsPrimary,
            .font: UIFont.amazonFont(type: .regular, size: 13)
        ]
        
        tw.attributedText = attributedString
        tw.font = .amazonFont(type: .regular, size: 13)
        tw.textColor = .lsGrey
        tw.textAlignment = .left
        tw.isScrollEnabled = false
        tw.contentInset = UIEdgeInsets(top: -10, left: -5, bottom: 0, right: 0)
        tw.isUserInteractionEnabled = true
        tw.isEditable = false
        return tw
    }()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never
        setupNavigationItems()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Functions
    private func setupNavigationItems() {
        navigationController?.navigationBar.tintColor = .lsTetriary
        self.title = StringConstant.termsAndConditions
    }
    
    private func setupViews() {
        view.addSubview(desctiptionTextView)
        
        desctiptionTextView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        let tapGestureTerms = UITapGestureRecognizer(target: self, action: #selector(handleTapOnTerms(_:)))
        desctiptionTextView.addGestureRecognizer(tapGestureTerms)
    }
    
    @objc func handleTapOnTerms(_ recognizer: UITapGestureRecognizer) {
        let url = StringConstant.About.appTermsOfUseURL
        
        let range = StringConstant.About.descriptionTitle.range(of: StringConstant.About.appTermsOfUse)
        guard let range,
              recognizer.didTapAttributedTextInLabel(tw: desctiptionTextView, inRange: NSRange(range, in: StringConstant.About.descriptionTitle)) else { return }
        
        openSafariBrowser(with: URL(string: url))
    }
    
    private func openSafariBrowser(with url: URL?) {
        guard let url else { return }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}
