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
}

struct PoliticalViewType: Codable {
    let countryCode: String
    let flagCode: String
    let fullName: String
    let politicalDescription: String
}


let PoliticalViewTypes: [PoliticalViewType] = [
    PoliticalViewType(countryCode: "", flagCode: "", fullName: "No Political View", politicalDescription: ""),
    PoliticalViewType(countryCode: "ARG", flagCode: "AR", fullName: "Argentina", politicalDescription: "Argentina's view on the Southern Patagonian Ice Field and Tierra Del Fuego, including the Falkland Islands, South Georgia, and South Sandwich Islands"),
    PoliticalViewType(countryCode: "CYP", flagCode: "CY", fullName: "Cyprus", politicalDescription: "Cyprus's view on ..."),
    PoliticalViewType(countryCode: "EGY", flagCode: "EG", fullName: "Egypt", politicalDescription: "Egypt's view on Bir Tawil"),
    PoliticalViewType(countryCode: "GEO", flagCode: "GE", fullName: "Georgia", politicalDescription: "Georgia's view on ..."),
    PoliticalViewType(countryCode: "GRC", flagCode: "GR", fullName: "Greece", politicalDescription: "Greece's view on ..."),
    PoliticalViewType(countryCode: "IND", flagCode: "IN", fullName: "India", politicalDescription: "India's view on Gilgit-Baltistan"),
    PoliticalViewType(countryCode: "KEN", flagCode: "KE", fullName: "Kenya", politicalDescription: "Kenya's view on the Ilemi Triangle"),
    PoliticalViewType(countryCode: "MAR", flagCode: "MA", fullName: "Morocco", politicalDescription: "Morocco's view on Western Sahara"),
    PoliticalViewType(countryCode: "PSE", flagCode: "PS", fullName: "Palestine", politicalDescription: "Palestine's view on ..."),
    PoliticalViewType(countryCode: "RUS", flagCode: "RU", fullName: "Russia", politicalDescription: "Russia's view on Crimea"),
    PoliticalViewType(countryCode: "SDN", flagCode: "SD", fullName: "Sudan", politicalDescription: "Sudan's view on the Halaib Triangle"),
    PoliticalViewType(countryCode: "SRB", flagCode: "RS", fullName: "Serbia", politicalDescription: "Serbia's view on Kosovo, Vukovar, and Sarengrad Islands"),
    PoliticalViewType(countryCode: "SUR", flagCode: "SR", fullName: "Suriname", politicalDescription: "Suriname's view on the Courantyne Headwaters and Lawa Headwaters"),
    PoliticalViewType(countryCode: "SYR", flagCode: "SY", fullName: "Syria", politicalDescription: "Syria's view on the Golan Heights"),
    PoliticalViewType(countryCode: "TUR", flagCode: "TR", fullName: "Türkiye", politicalDescription: "Türkiye's view on Cyprus and Northern Cyprus"),
    PoliticalViewType(countryCode: "TZA", flagCode: "TZ", fullName: "Tanzania", politicalDescription: "Tanzania's view on Lake Malawi"),
    PoliticalViewType(countryCode: "URY", flagCode: "UY", fullName: "Uruguay", politicalDescription: "Uruguay's view on Rincon de Artigas"),
]


struct LanguageSwitcherData: Codable {
    let value: String
    let label: String
}

let languageSwitcherData: [LanguageSwitcherData] = [
    LanguageSwitcherData(value: "en", label: "English"),
    LanguageSwitcherData(value: "as", label: "অসমীয়া"),
    LanguageSwitcherData(value: "az", label: "Azərbaycan dili"),
    LanguageSwitcherData(value: "id", label: "Bahasa Indonesia"),
    LanguageSwitcherData(value: "ms", label: "Bahasa Melayu"),
    LanguageSwitcherData(value: "be", label: "Беларуская"),
    LanguageSwitcherData(value: "bg", label: "Български"),
    LanguageSwitcherData(value: "bn", label: "বাংলা"),
    LanguageSwitcherData(value: "bs", label: "Bosanski"),
    LanguageSwitcherData(value: "ca", label: "Català"),
    LanguageSwitcherData(value: "zh", label: "简体中文"),
    LanguageSwitcherData(value: "zh-Hant", label: "繁體中文"),
    LanguageSwitcherData(value: "cs", label: "Čeština"),
    LanguageSwitcherData(value: "cy", label: "Cymraeg"),
    LanguageSwitcherData(value: "da", label: "Dansk"),
    LanguageSwitcherData(value: "de", label: "Deutsch"),
    LanguageSwitcherData(value: "el", label: "Ελληνικά"),
    LanguageSwitcherData(value: "en", label: "English"),
    LanguageSwitcherData(value: "es", label: "Español"),
    LanguageSwitcherData(value: "et", label: "Eesti"),
    LanguageSwitcherData(value: "eu", label: "Euskara"),
    LanguageSwitcherData(value: "fa", label: "فارسی"),
    LanguageSwitcherData(value: "fi", label: "Suomi"),
    LanguageSwitcherData(value: "fo", label: "Føroyskt"),
    LanguageSwitcherData(value: "fr", label: "Français"),
    LanguageSwitcherData(value: "gl", label: "Galego"),
    LanguageSwitcherData(value: "ka", label: "ქართული"),
    LanguageSwitcherData(value: "gu", label: "ગુજરાતી"),
    LanguageSwitcherData(value: "he", label: "עברית"),
    LanguageSwitcherData(value: "hi", label: "हिन्दी"),
    LanguageSwitcherData(value: "hr", label: "Hrvatski"),
    LanguageSwitcherData(value: "hu", label: "Magyar"),
    LanguageSwitcherData(value: "hy", label: "Հայերեն"),
    LanguageSwitcherData(value: "is", label: "Íslenska"),
    LanguageSwitcherData(value: "it", label: "Italiano"),
    LanguageSwitcherData(value: "ja", label: "日本語"),
    LanguageSwitcherData(value: "kk", label: "Қазақ тілі"),
    LanguageSwitcherData(value: "km", label: "ខ្មែរ"),
    LanguageSwitcherData(value: "kn", label: "ಕನ್ನಡ"),
    LanguageSwitcherData(value: "ko", label: "한국어"),
    LanguageSwitcherData(value: "ky", label: "Кыргызча"),
    LanguageSwitcherData(value: "lt", label: "Lietuvių"),
    LanguageSwitcherData(value: "lv", label: "Latviešu"),
    LanguageSwitcherData(value: "mk", label: "Македонски"),
    LanguageSwitcherData(value: "ml", label: "മലയാളം"),
    LanguageSwitcherData(value: "mr", label: "मराठी"),
    LanguageSwitcherData(value: "mt", label: "Malti"),
    LanguageSwitcherData(value: "my", label: "မြန်မာစာ"),
    LanguageSwitcherData(value: "nl", label: "Nederlands"),
    LanguageSwitcherData(value: "no", label: "Norsk"),
    LanguageSwitcherData(value: "or", label: "ଓଡ଼ିଆ"),
    LanguageSwitcherData(value: "pa", label: "ਪੰਜਾਬੀ"),
    LanguageSwitcherData(value: "pl", label: "Polski"),
    LanguageSwitcherData(value: "pt", label: "Português"),
    LanguageSwitcherData(value: "ro", label: "Română"),
    LanguageSwitcherData(value: "ru", label: "Русский"),
    LanguageSwitcherData(value: "sk", label: "Slovenčina"),
    LanguageSwitcherData(value: "sl", label: "Slovenščina"),
    LanguageSwitcherData(value: "sq", label: "Shqip"),
    LanguageSwitcherData(value: "sr", label: "Српски"),
    LanguageSwitcherData(value: "sv", label: "Svenska"),
    LanguageSwitcherData(value: "ta", label: "தமிழ்"),
    LanguageSwitcherData(value: "te", label: "తెలుగు"),
    LanguageSwitcherData(value: "th", label: "ไทย"),
    LanguageSwitcherData(value: "tr", label: "Türkçe"),
    LanguageSwitcherData(value: "uk", label: "Українська"),
    LanguageSwitcherData(value: "uz", label: "Oʻzbek"),
    LanguageSwitcherData(value: "vi", label: "Tiếng Việt")
]


