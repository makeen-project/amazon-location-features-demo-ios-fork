import Foundation
import UIKit

var bundleKey: UInt8 = 0

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
            GeneralHelper.reloadUI()
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
