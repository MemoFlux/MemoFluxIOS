//
//  LanguageManager.swift
//  MemoFlux
//
//  Created for localization support
//

import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable {
    case chinese = "zh-Hans"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .chinese:
            return "简体中文"
        case .english:
            return "English"
        }
    }
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "AppLanguage")
            // 通知所有视图更新
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }
    
    private let languageKey = "AppLanguage"
    
    private init() {
        // 从UserDefaults读取保存的语言设置
        if let savedLanguage = UserDefaults.standard.string(forKey: languageKey),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // 如果没有保存的语言设置，使用系统语言
            let systemLanguage = Locale.preferredLanguages.first ?? "en"
            if systemLanguage.hasPrefix("zh") {
                self.currentLanguage = .chinese
            } else {
                self.currentLanguage = .english
            }
        }
    }
    
    /// 切换语言
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

