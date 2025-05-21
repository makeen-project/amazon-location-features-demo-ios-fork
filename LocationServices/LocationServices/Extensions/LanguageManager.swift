import Foundation
import UIKit

private var bundleKey: UInt8 = 0

class LanguageManager {
    static let shared = LanguageManager()
    
    private(set) var translations: [String: [String: String]] = [:] // [key: [lang: value]]
    
//    private var defaultLanguage: LanguageSwitcherData {
//        return Locale.preferredLanguages.first ?? "en"
//    }

    var currentLanguage: String {
        get {
            return Locale.currentAppLanguageIdentifier()
        }
        set {
            UserDefaultsHelper.save(value: [newValue], key: .AppleLanguages)
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
    
    func reloadRootViewController() {
         let sceneDelegate = UIApplication.shared.connectedScenes
             .first?.delegate as? SceneDelegate
         let nav = UINavigationController()
         sceneDelegate?.window?.rootViewController = nav
         sceneDelegate?.coordinator = AppCoordinator(navigationController: nav, window: sceneDelegate?.window)
         sceneDelegate?.coordinator?.start()
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



private class LocalizedBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        } else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
    }
}

extension Bundle {
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, LocalizedBundle.self)
        }

        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        let value = path != nil ? Bundle(path: path!) : nil
        objc_setAssociatedObject(Bundle.main, &bundleKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    static func swizzleLocalization() {
        // One-time swizzle check
        guard object_getClass(Bundle.main) != LocalizedBundle.self else { return }
        object_setClass(Bundle.main, LocalizedBundle.self)
    }
}
