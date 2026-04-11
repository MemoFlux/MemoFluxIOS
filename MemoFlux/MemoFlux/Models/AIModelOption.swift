//
//  AIModelOption.swift
//  MemoFlux
//
//  Created by OpenAI Codex on 2026/3/31.
//

import Foundation
import SwiftUI

enum AIRequestStyle: String, Codable {
  case openAICompatibleChatCompletions
}

struct AIServiceConfiguration {
  let provider: AIModelProvider
  let requestStyle: AIRequestStyle
  let baseURL: String?
  let apiKey: String?
  let modelId: String
}

// Backward-compatible shim for stale editor/build references while the app
// transitions from fixed enum-based models to stored model profiles.
enum AIModelOption: String, CaseIterable, Identifiable {
  case doubaoSeed16 = "doubao-seed-1.6"
  case gemini25Flash = "gemini-2.5-flash"
  
  static var current: AIModelOption {
    switch AIModelStore.shared.selectedModel.id {
    case AIModelProfile.builtInGeminiID:
      return .gemini25Flash
    default:
      return .doubaoSeed16
    }
  }
  
  var id: String { rawValue }
  
  var displayName: String {
    profile.name
  }
  
  var profile: AIModelProfile {
    switch self {
    case .doubaoSeed16:
      return AIModelProfile.builtInModels.first(where: { $0.id == AIModelProfile.builtInDoubaoID })
        ?? AIModelProfile.builtInModels[0]
    case .gemini25Flash:
      return AIModelProfile.builtInModels.first(where: { $0.id == AIModelProfile.builtInGeminiID })
        ?? AIModelProfile.builtInModels[0]
    }
  }
  
  var serviceConfiguration: AIServiceConfiguration {
    profile.serviceConfiguration
  }
}

enum AIModelProvider: String, CaseIterable, Codable, Identifiable {
  case doubaoArk
  case gemini
  case openAICompatible
  
  var id: String { rawValue }
  
  var displayName: String {
    switch self {
    case .doubaoArk:
      return LanguageManager.shared.localized(zh: "火山方舟 / 豆包", en: "Volcengine Ark / Doubao")
    case .gemini:
      return LanguageManager.shared.localized(zh: "Google Gemini", en: "Google Gemini")
    case .openAICompatible:
      return LanguageManager.shared.localized(zh: "OpenAI 兼容", en: "OpenAI Compatible")
    }
  }
  
  var shortDisplayName: String {
    switch self {
    case .doubaoArk:
      return LanguageManager.shared.localized(zh: "豆包", en: "Doubao")
    case .gemini:
      return "Gemini"
    case .openAICompatible:
      return LanguageManager.shared.localized(zh: "自定义", en: "Custom")
    }
  }
  
  var requestStyle: AIRequestStyle {
    .openAICompatibleChatCompletions
  }
  
  var defaultBaseURL: String? {
    switch self {
    case .doubaoArk:
      return SecureConfig.arkBaseURL
    case .gemini:
      return SecureConfig.geminiBaseURL
    case .openAICompatible:
      return nil
    }
  }
}

struct AIModelProfile: Codable, Identifiable, Equatable {
  static let builtInDoubaoID = "builtin.doubao-seed-1.6"
  static let builtInGeminiID = "builtin.gemini-2.5-flash"
  
  let id: String
  var name: String
  var provider: AIModelProvider
  var modelIdentifier: String
  var baseURLOverride: String?
  var isBuiltIn: Bool
  var createdAt: Date
  
  static var builtInModels: [AIModelProfile] {
    [
      AIModelProfile(
        id: builtInDoubaoID,
        name: LanguageManager.shared.localized(zh: "豆包 Seed 1.6", en: "Doubao Seed 1.6"),
        provider: .doubaoArk,
        modelIdentifier: SecureConfig.arkModelId ?? "doubao-seed-1-6-vision-250815",
        baseURLOverride: nil,
        isBuiltIn: true,
        createdAt: .distantPast
      ),
      AIModelProfile(
        id: builtInGeminiID,
        name: "Gemini 2.5 Flash",
        provider: .gemini,
        modelIdentifier: "gemini-2.5-flash",
        baseURLOverride: nil,
        isBuiltIn: true,
        createdAt: .distantPast
      )
    ]
  }
  
  var resolvedBaseURL: String? {
    let override = baseURLOverride?.trimmingCharacters(in: .whitespacesAndNewlines)
    if let override, !override.isEmpty {
      return override
    }
    
    return provider.defaultBaseURL
  }
  
  var apiKeyStorageKey: String {
    "ai_model_api_key.\(id)"
  }
  
  var serviceConfiguration: AIServiceConfiguration {
    AIServiceConfiguration(
      provider: provider,
      requestStyle: provider.requestStyle,
      baseURL: resolvedBaseURL,
      apiKey: resolvedAPIKey,
      modelId: modelIdentifier
    )
  }
  
  var resolvedAPIKey: String? {
    if isBuiltIn {
      switch id {
      case Self.builtInDoubaoID:
        return SecureConfig.arkAPIKey
      case Self.builtInGeminiID:
        return SecureConfig.geminiAPIKey
      default:
        break
      }
    }
    
    return KeychainHelper.string(for: apiKeyStorageKey)
  }
}

final class AIModelStore: ObservableObject {
  static let shared = AIModelStore()
  
  static let selectedModelKey = "selectedAIModelID"
  private static let customModelsKey = "customAIModels"
  
  @Published private(set) var customModels: [AIModelProfile] = []
  @Published var selectedModelID: String {
    didSet {
      UserDefaults.standard.set(selectedModelID, forKey: Self.selectedModelKey)
    }
  }
  
  private init() {
    selectedModelID = UserDefaults.standard.string(forKey: Self.selectedModelKey)
      ?? AIModelProfile.builtInDoubaoID
    loadCustomModels()
    normalizeSelectionIfNeeded()
  }
  
  var allModels: [AIModelProfile] {
    AIModelProfile.builtInModels + customModels
  }
  
  var selectedModel: AIModelProfile {
    model(for: selectedModelID) ?? AIModelProfile.builtInModels[0]
  }
  
  func model(for id: String) -> AIModelProfile? {
    allModels.first(where: { $0.id == id })
  }
  
  func selectModel(id: String) {
    selectedModelID = id
    normalizeSelectionIfNeeded()
  }
  
  func saveCustomModel(
    id: String? = nil,
    name: String,
    provider: AIModelProvider,
    modelIdentifier: String,
    baseURL: String,
    apiKey: String
  ) {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedIdentifier = modelIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedBaseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedAPIKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    let modelID = id ?? UUID().uuidString
    
    let profile = AIModelProfile(
      id: modelID,
      name: trimmedName,
      provider: provider,
      modelIdentifier: trimmedIdentifier,
      baseURLOverride: trimmedBaseURL.isEmpty ? nil : trimmedBaseURL,
      isBuiltIn: false,
      createdAt: Date()
    )
    
    if let existingIndex = customModels.firstIndex(where: { $0.id == modelID }) {
      customModels[existingIndex] = profile
    } else {
      customModels.append(profile)
    }
    
    customModels.sort { $0.createdAt < $1.createdAt }
    KeychainHelper.set(trimmedAPIKey, for: profile.apiKeyStorageKey)
    persistCustomModels()
    selectedModelID = profile.id
  }
  
  func deleteCustomModels(at offsets: IndexSet) {
    let modelsToDelete = offsets.map { customModels[$0] }
    customModels.remove(atOffsets: offsets)
    
    for model in modelsToDelete {
      KeychainHelper.removeValue(for: model.apiKeyStorageKey)
    }
    
    persistCustomModels()
    normalizeSelectionIfNeeded()
  }
  
  private func loadCustomModels() {
    guard let data = UserDefaults.standard.data(forKey: Self.customModelsKey) else {
      customModels = []
      return
    }
    
    do {
      customModels = try JSONDecoder().decode([AIModelProfile].self, from: data)
    } catch {
      print("❌ Failed to load custom models: \(error)")
      customModels = []
    }
  }
  
  private func persistCustomModels() {
    do {
      let data = try JSONEncoder().encode(customModels)
      UserDefaults.standard.set(data, forKey: Self.customModelsKey)
    } catch {
      print("❌ Failed to persist custom models: \(error)")
    }
  }
  
  private func normalizeSelectionIfNeeded() {
    guard model(for: selectedModelID) == nil else { return }
    selectedModelID = AIModelProfile.builtInDoubaoID
  }
}
