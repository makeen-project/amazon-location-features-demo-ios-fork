//
//  MapStyleTypes.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

enum MapStyleImages: Codable  {
    case standard, monochrome, hybrid, satellite
    
    var mapName: String {
        switch self {
        case .standard:
            return "Standard"
        case .monochrome:
            return "Monochrome"
        case .hybrid:
            return "Hybrid"
        case .satellite:
            return "Satellite"
        }
    }
}

enum MapStyleColorType: String, Codable {
    case light, dark
    
    var colorName: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
    
    var colorLabel: String {
        switch self {
        case .light:
            return NSLocalizedString("Light", comment: "")
        case .dark:
            return NSLocalizedString("Dark", comment: "")
        }
    }
}

struct PoliticalViewType: Codable {
    let countryCode: String
    let flagCode: String
    let fullName: String
    let politicalDescription: String
}


let PoliticalViewTypes: [PoliticalViewType] = [
    PoliticalViewType(countryCode: "", flagCode: "", fullName: NSLocalizedString("No Political View", comment: ""), politicalDescription: ""),
    PoliticalViewType(countryCode: "ARG", flagCode: "AR", fullName: "Argentina", politicalDescription: NSLocalizedString("ArgentinaPoliticalView", comment: "")),
    PoliticalViewType(countryCode: "CYP", flagCode: "CY", fullName: "Cyprus", politicalDescription: NSLocalizedString("CyprusPoliticalView", comment: "")),
    PoliticalViewType(countryCode: "EGY", flagCode: "EG", fullName: "Egypt", politicalDescription: NSLocalizedString("EgyptPoliticalView", comment: "")),
    PoliticalViewType(countryCode: "GEO", flagCode: "GE", fullName: "Georgia", politicalDescription: NSLocalizedString("GeorgiaPoliticalView", comment: "")),
    PoliticalViewType(countryCode: "GRC", flagCode: "GR", fullName: "Greece", politicalDescription: NSLocalizedString("GreecePoliticalView", comment: "")),
    PoliticalViewType(countryCode: "IND", flagCode: "IN", fullName: "India", politicalDescription: NSLocalizedString("IndiaPoliticalView", comment: "")),
    PoliticalViewType(countryCode: "KEN", flagCode: "KE", fullName: "Kenya", politicalDescription: NSLocalizedString("KenyaPoliticalView", comment: "")),
    PoliticalViewType(countryCode: "MAR", flagCode: "MA", fullName: "Morocco", politicalDescription: NSLocalizedString("MoroccoPoliticalView", comment: "")),
    PoliticalViewType(countryCode: "PSE", flagCode: "PS", fullName: "Palestine", politicalDescription: NSLocalizedString("PalestinePoliticalView", comment: "")),
    PoliticalViewType(countryCode: "RUS", flagCode: "RU", fullName: "Russia", politicalDescription: NSLocalizedString("RussiaPoliticalView", comment: "")),
    PoliticalViewType(countryCode: "SDN", flagCode: "SD", fullName: "Sudan", politicalDescription: NSLocalizedString("SudanPoliticalView", comment: "")),
    PoliticalViewType(countryCode: "SRB", flagCode: "RS", fullName: "Serbia", politicalDescription: NSLocalizedString("SerbiaPoliticalView", comment: "")),
    PoliticalViewType(countryCode: "SUR", flagCode: "SR", fullName: "Suriname", politicalDescription: NSLocalizedString("SurinamePoliticalView", comment: "")),
    PoliticalViewType(countryCode: "SYR", flagCode: "SY", fullName: "Syria", politicalDescription: NSLocalizedString("SyriaPoliticalView", comment: "")),
    PoliticalViewType(countryCode: "TUR", flagCode: "TR", fullName: "Türkiye", politicalDescription: NSLocalizedString("TurkeyPoliticalView", comment: "")),
    PoliticalViewType(countryCode: "TZA", flagCode: "TZ", fullName: "Tanzania", politicalDescription: NSLocalizedString("TanzaniaPoliticalView", comment: "")),
    PoliticalViewType(countryCode: "URY", flagCode: "UY", fullName: "Uruguay", politicalDescription: NSLocalizedString("UruguayPoliticalView", comment: "")),
]


struct LanguageSwitcherData: Codable {
    let value: String
    let label: String
    let mapOnly: Bool
}

let languageSwitcherData: [LanguageSwitcherData] = [
    LanguageSwitcherData(value: "en", label: "English", mapOnly: false), // English
    LanguageSwitcherData(value: "ar", label: "العربية", mapOnly: false), // Arabic
    LanguageSwitcherData(value: "as", label: "অসমীয়া", mapOnly: true), // Assamese
    LanguageSwitcherData(value: "az", label: "Azərbaycan dili", mapOnly: true), //Azerbaijani
    LanguageSwitcherData(value: "be", label: "беларуская", mapOnly: true), //Belarusian
    LanguageSwitcherData(value: "bg", label: "български", mapOnly: true), //Bulgarian
    LanguageSwitcherData(value: "bn", label: "বাংলা", mapOnly: true), //Bengali
    LanguageSwitcherData(value: "bs", label: "Bosanski", mapOnly: true), //Bosnian
    LanguageSwitcherData(value: "ca", label: "Català", mapOnly: true), //Catalan
    LanguageSwitcherData(value: "cs", label: "Čeština", mapOnly: true), //Czech
    LanguageSwitcherData(value: "cy", label: "Cymraeg", mapOnly: true), //Welsh
    LanguageSwitcherData(value: "da", label: "Dansk", mapOnly: true), //Danish
    LanguageSwitcherData(value: "de", label: "Deutsch", mapOnly: false), //German
    LanguageSwitcherData(value: "el", label: "Ελληνικά", mapOnly: true), //Greek
    LanguageSwitcherData(value: "es", label: "Español", mapOnly: false), //Spanish
    LanguageSwitcherData(value: "et", label: "Eesti", mapOnly: true), //Estonian
    LanguageSwitcherData(value: "eu", label: "Euskara", mapOnly: true), //Basque
    LanguageSwitcherData(value: "fi", label: "Suomi", mapOnly: true), //Finnish
    LanguageSwitcherData(value: "fo", label: "Føroyskt", mapOnly: true), //Faroese
    LanguageSwitcherData(value: "fr", label: "Français", mapOnly: false), //French
    LanguageSwitcherData(value: "ga", label: "Gaeilge", mapOnly: true), //Irish
    LanguageSwitcherData(value: "gl", label: "Galego", mapOnly: true), //Galician
    LanguageSwitcherData(value: "gn", label: "Avañe'ẽ", mapOnly: true), //Guarani
    LanguageSwitcherData(value: "gu", label: "ગુજરાતી", mapOnly: true), //Gujarati
    LanguageSwitcherData(value: "he", label: "עברית", mapOnly: false), //Hebrew
    LanguageSwitcherData(value: "hi", label: "हिन्दी", mapOnly: false), //Hindi
    LanguageSwitcherData(value: "hr", label: "Hrvatski", mapOnly: true), //Croatian
    LanguageSwitcherData(value: "hu", label: "Magyar", mapOnly: true), //Hungarian
    LanguageSwitcherData(value: "hy", label: "Հայերեն", mapOnly: true), //Armenian
    LanguageSwitcherData(value: "id", label: "Bahasa Indonesia", mapOnly: true), //Indonesian
    LanguageSwitcherData(value: "is", label: "Íslenska", mapOnly: true), //Icelandic
    LanguageSwitcherData(value: "it", label: "Italiano", mapOnly: false), //Italian
    LanguageSwitcherData(value: "ja", label: "日本語", mapOnly: false), //Japanese
    LanguageSwitcherData(value: "ka", label: "ქართული", mapOnly: true), //Georgian
    LanguageSwitcherData(value: "kk", label: "Қазақша", mapOnly: true), //Kazakh
    LanguageSwitcherData(value: "km", label: "ភាសាខ្មែរ", mapOnly: true), //Khmer
    LanguageSwitcherData(value: "kn", label: "ಕನ್ನಡ", mapOnly: true), //Kannada
    LanguageSwitcherData(value: "ko", label: "한국어", mapOnly: false), //Korean
    LanguageSwitcherData(value: "ky", label: "Кыргызча", mapOnly: true), //Kyrgyz
    LanguageSwitcherData(value: "lt", label: "Lietuvių", mapOnly: true), //Lithuanian
    LanguageSwitcherData(value: "lv", label: "Latviešu", mapOnly: true), //Latvian
    LanguageSwitcherData(value: "mk", label: "Македонски", mapOnly: true), //Macedonian
    LanguageSwitcherData(value: "ml", label: "മലയാളം", mapOnly: true), //Malayalam
    LanguageSwitcherData(value: "mr", label: "मराठी", mapOnly: true), //Marathi
    LanguageSwitcherData(value: "ms", label: "Bahasa Melayu", mapOnly: true), //Malay
    LanguageSwitcherData(value: "mt", label: "Malti", mapOnly: true), //Maltese
    LanguageSwitcherData(value: "my", label: "မြန်မာ", mapOnly: true), //Burmese
    LanguageSwitcherData(value: "nl", label: "Nederlands", mapOnly: true), //Dutch
    LanguageSwitcherData(value: "no", label: "Norsk", mapOnly: true), //Norwegian
    LanguageSwitcherData(value: "or", label: "ଓଡ଼ିଆ", mapOnly: true), //Odia
    LanguageSwitcherData(value: "pa", label: "ਪੰਜਾਬੀ", mapOnly: true), //Punjabi
    LanguageSwitcherData(value: "pl", label: "Polski", mapOnly: true), //Polish
    LanguageSwitcherData(value: "pt", label: "Português", mapOnly: false), //Portuguese
    LanguageSwitcherData(value: "ro", label: "Română", mapOnly: true), //Romanian
    LanguageSwitcherData(value: "ru", label: "Русский", mapOnly: true), //Russian
    LanguageSwitcherData(value: "sk", label: "Slovenčina", mapOnly: true), //Slovak
    LanguageSwitcherData(value: "sl", label: "Slovenščina", mapOnly: true), //Slovenian
    LanguageSwitcherData(value: "sq", label: "Shqip", mapOnly: true), //Albanian
    LanguageSwitcherData(value: "sr", label: "Српски", mapOnly: true), //Serbian
    LanguageSwitcherData(value: "sv", label: "Svenska", mapOnly: true), //Swedish
    LanguageSwitcherData(value: "ta", label: "தமிழ்", mapOnly: true), //Tamil
    LanguageSwitcherData(value: "te", label: "తెలుగు", mapOnly: true), //Telugu
    LanguageSwitcherData(value: "th", label: "ไทย", mapOnly: true), //Thai
    LanguageSwitcherData(value: "tr", label: "Türkçe", mapOnly: true), //Turkish
    LanguageSwitcherData(value: "uk", label: "Українська", mapOnly: true), //Ukrainian
    LanguageSwitcherData(value: "uz", label: "Oʻzbekcha", mapOnly: true), //Uzbek
    LanguageSwitcherData(value: "vi", label: "Tiếng Việt", mapOnly: true), //Vietnamese
    LanguageSwitcherData(value: "zh", label: "中文 (简体)", mapOnly: false), //Chinese (Simplified)
    LanguageSwitcherData(value: "zh-Hant", label: "中文 (繁體)", mapOnly: false) // Chinese (Traditional)
]
