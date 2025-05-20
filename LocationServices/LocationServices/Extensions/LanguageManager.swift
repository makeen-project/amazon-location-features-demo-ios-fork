import Foundation
import UIKit

private var bundleKey: UInt8 = 0

final class LanguageManager {
    static let shared = LanguageManager()

    //private let userDefaultsKey = "AppLanguage"
    private var defaultLanguage: String {
        return Locale.preferredLanguages.first ?? "en"
    }

    var currentLanguage: String {
        get {
            return UserDefaultsHelper.getObject(value: [String].self, key: .AppleLanguages)?.first ?? defaultLanguage
        }
        set {
            UserDefaultsHelper.saveObject(value: [newValue], key: .AppleLanguages)
            Bundle.setLanguage(newValue)
        }
    }

    private init() {
        Bundle.swizzleLocalization()
        Bundle.setLanguage(currentLanguage)
    }

    /// Call this after changing language to update the UI
    func reloadRootViewController() {
        let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate

        let nav = UINavigationController()
        sceneDelegate?.window?.rootViewController = nav
        sceneDelegate?.coordinator = AppCoordinator(navigationController: nav, window: sceneDelegate?.window)
        sceneDelegate?.coordinator?.start()
    }
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
