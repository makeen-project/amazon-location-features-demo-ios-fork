//
//  UIImageView+Extension.swift
//  LocationServices
//
//  Created by Zeeshan Sheikh on 22/05/2023.
//

import Foundation
import UIKit

extension UIImageView {
    func setShadow(){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 2
        self.layer.masksToBounds = false
    }
}
