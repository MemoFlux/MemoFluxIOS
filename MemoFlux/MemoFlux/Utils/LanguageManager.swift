//
//  LanguageManager.swift
//  MemoFlux
//
//  Created by AI Assistant on 2025/12/05.
//

import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
  case chinese = "zh-Hans"
  case english = "en"
  
  var id: String { rawValue }
  
  var displayName: String {
    switch self {
    case .chinese: return "简体中文"
    case .english: return "English"
    }
  }
}

class LanguageManager: ObservableObject {
  static let shared = LanguageManager()
  
  @AppStorage("app_language") private var languageCode: String = AppLanguage.chinese.rawValue {
    didSet {
      updateCurrentLanguage()
    }
  }
  
  @Published var currentLanguage: AppLanguage = .chinese
  
  private init() {
    updateCurrentLanguage()
  }
  
  private func updateCurrentLanguage() {
    if let lang = AppLanguage(rawValue: languageCode) {
      currentLanguage = lang
    } else {
      currentLanguage = .chinese
    }
  }
  
  func setLanguage(_ language: AppLanguage) {
    languageCode = language.rawValue
  }
  
  // 辅助方法，根据当前语言返回对应的字符串
  func localized(zh: String, en: String) -> String {
    return currentLanguage == .chinese ? zh : en
  }
}

