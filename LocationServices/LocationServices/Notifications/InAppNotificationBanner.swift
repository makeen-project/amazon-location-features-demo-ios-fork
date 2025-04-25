//
//  InAppNotificationBanner.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

class InAppNotificationBanner: UIView {

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()

    private static var currentBanner: InAppNotificationBanner?
    private var isiPad = UIDevice.current.userInterfaceIdiom == .pad

    init(title: String, message: String, image: UIImage? = nil) {
        super.init(frame: CGRect.zero)

        backgroundColor = UIColor.lsLight3.withAlphaComponent(0.9)
        layer.cornerRadius = 12
        clipsToBounds = true

        // Configure image view
        iconImageView.image = image
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.cornerRadius = 8
        iconImageView.clipsToBounds = true
        iconImageView.snp.makeConstraints { $0.size.equalTo(CGSize(width: 40, height: 40)) }

        // Configure labels
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black

        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0

        // Vertical stack for title and message
        let textStack = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        // Horizontal stack with image + text
        let contentStack = UIStackView(arrangedSubviews: [iconImageView, textStack])
        contentStack.axis = .horizontal
        contentStack.spacing = 12
        contentStack.alignment = .center

        addSubview(contentStack)

        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(in view: UIView) {
        DispatchQueue.main.async {
            // Remove current banner if it exists
            if let existingBanner = Self.currentBanner {
                existingBanner.dismiss(immediate: true)
            }

            Self.currentBanner = self
            view.addSubview(self)

            self.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(16)
                $0.top.equalTo(view.safeAreaLayoutGuide).offset(-125)
            }

            view.layoutIfNeeded()

            // Animate banner slide-in
            UIView.animate(withDuration: 0.3) {
                self.transform = CGAffineTransform(translationX: 0, y: 120)
            }

            // Auto dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.dismiss()
            }
        }
    }

    private func dismiss(immediate: Bool = false) {
        DispatchQueue.main.async {
            let animation = {
                self.transform = .identity
            }

            let completion: (Bool) -> Void = { _ in
                self.removeFromSuperview()
                if Self.currentBanner === self {
                    Self.currentBanner = nil
                }
            }

            if immediate {
                animation()
                completion(true)
            } else {
                UIView.animate(withDuration: 0.3, animations: animation, completion: completion)
            }
        }
    }
}
