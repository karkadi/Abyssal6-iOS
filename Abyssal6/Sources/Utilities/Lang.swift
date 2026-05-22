//
//  Lang.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
// Loads localization strings from a .strings file (or falls back to the built-in
// English table below).  The active language is stored in UserDefaults.
import Foundation

// MARK: – Lang

final class Lang {

    // MARK: Supported Languages

    enum Language: String, CaseIterable {
        case english = "en"
        case french  = "fr"
        case german  = "de"
        case chinese = "zh-Hans"

        var displayName: String {
            switch self {
            case .english: return "English"
            case .french:  return "Français"
            case .german:  return "Deutsch"
            case .chinese: return "中文"
            }
        }
    }

    // MARK: Singleton State

    static var current: Language = .french {
        didSet { UserDefaults.standard.set(current.rawValue, forKey: "lang") }
    }

    /// Load persisted language preference.
    static func loadPreference() {
        if let code = UserDefaults.standard.string(forKey: "lang"),
           let lang = Language(rawValue: code) {
            current = lang
        }
    }

    // MARK: Public API

    static func string(_ key: String) -> String {
        // 1. Try Localizable.strings for the current language bundle
        if let path = Bundle.main.path(forResource: "Localizable",
                                       ofType: "strings",
                                       inDirectory: nil,
                                       forLocalization: current.rawValue),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String],
           let value = dict[key] {
            return value.replacingOccurrences(of: "\\n", with: "\n")
        }
        // 2. Fall back to built-in English table
        return builtIn[key] ?? key
    }

    // MARK: – Built-in English Fallback Table
    // (Mirrors msg.txt; additional languages load from Localizable.strings)

    static let builtIn: [String: String] = [:]
}
