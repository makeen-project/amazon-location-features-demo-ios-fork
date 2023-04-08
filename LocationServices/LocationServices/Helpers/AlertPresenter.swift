//
//  AlertPresenter.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

class AlertModel {
    var title: String
    var message: String
    var cancelButtonTitle: String?
    var okButtonTitle: String
    var okHandler: (()->())?
    
    
    init(title: String = StringConstant.error, message: String = "", cancelButton: String? = StringConstant.cancel, okButton: String = StringConstant.ok, okHandler: (()->())? = nil) {
        self.title = title
        self.message = message
        self.cancelButtonTitle = cancelButton
        self.okButtonTitle = okButton
        self.okHandler = okHandler
    }
}

protocol AlertPresentable {
    func showAlert(_ model: AlertModel)
}

extension AlertPresentable where Self: UIViewController {
    func showAlert(_ model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message, preferredStyle: UIAlertController.Style.alert)
        if let cancelButtonTitle = model.cancelButtonTitle {
            alert.addAction(UIAlertAction(title: cancelButtonTitle,
                                          style: .cancel,
                                          handler: nil))
        }
        alert.addAction(UIAlertAction(title: model.okButtonTitle,
                                      style: .default,
                                      handler: { _ in
            model.okHandler?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
