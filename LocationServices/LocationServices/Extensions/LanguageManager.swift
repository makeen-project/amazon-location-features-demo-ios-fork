import Foundation
import UIKit

private var bundleKey: UInt8 = 0

class LanguageManager {
    static let shared = LanguageManager()
    private(set) var translations: [String: [String: String]] = [:]

    var currentLanguage: String {
        get {
            return Locale.currentAppLanguageIdentifier()
        }
        set {
            UserDefaultsHelper.save(value: [newValue], key: .AppleLanguages)
            loadStrings()
            reloadUI()
        }
    }
    
    func loadStrings(from file: String = "Localizations") {
        
        do {
            if let url = Bundle.main.url(forResource: file, withExtension: "json") {
                let data = try Data(contentsOf: url)
                let parsed = try JSONDecoder().decode(XCStringsFile.self, from: data)
                
                for (key, entry) in parsed.strings {
                    var localizedVariants: [String: String] = [:]
                    for (lang, unit) in entry.localizations {
                        localizedVariants[lang] = unit.stringUnit.value
                    }
                    translations[key] = localizedVariants
                }
            }
        }
        catch {
            print("⚠️ Failed to load .json: \(error)")
            return
        }
    }

    func localizedString(forKey key: String) -> String {
        let translation = translations[key]?[currentLanguage] ?? key
        return translation
    }

    func reloadUI() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first,
              let window = windowScene.windows.first else {
            return
        }

        // Determine language direction (RTL or LTR)
        let currentLanguage = LanguageManager.shared.currentLanguage
        let isRTL = Locale.Language(identifier:currentLanguage).characterDirection == .rightToLeft
        let semantic: UISemanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight

        // Apply semantic direction globally
        UIView.appearance().semanticContentAttribute = semantic
        UILabel.appearance().semanticContentAttribute = semantic
        UITextField.appearance().semanticContentAttribute = semantic
        UITextView.appearance().semanticContentAttribute = semantic
        window.semanticContentAttribute = semantic

        // Rebuild rootViewController
        let nav = UINavigationController()
        let sceneDelegate = windowScene.delegate as? SceneDelegate
        sceneDelegate?.window?.rootViewController = nav
        sceneDelegate?.coordinator = AppCoordinator(navigationController: nav, window: sceneDelegate?.window)
        sceneDelegate?.coordinator?.start()

        // Animate the transition
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }

}

struct XCStringsFile: Decodable {
    let sourceLanguage: String
    let strings: [String: XCStringEntry]
    let version: String
}

struct XCStringEntry: Decodable {
    let extractionState: String
    let localizations: [String: XCLocalization]
}

struct XCLocalization: Decodable {
    let stringUnit: XCStringUnit
}

struct XCStringUnit: Decodable {
    let state: String
    let value: String
}
