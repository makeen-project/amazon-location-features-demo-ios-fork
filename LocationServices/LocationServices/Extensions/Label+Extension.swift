//
//  Label+Extension.swift
//  LocationServices
//
//  Created by Zeeshan Sheikh on 23/05/2025.
//

import UIKit

extension UILabel {
    /// Applies proper semantic content direction, text alignment, and refreshes placeholder for current language direction
    func applyLocaleDirection() {
        let isRTL = Locale.Language(identifier:LanguageManager.shared.currentLanguage).characterDirection == .rightToLeft
        self.semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        self.textAlignment = isRTL ? .right : .left
    }
}
