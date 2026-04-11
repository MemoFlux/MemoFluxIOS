//
//  CustomModelEditorView.swift
//  MemoFlux
//
//  Created by OpenAI Codex on 2026/3/31.
//

import SwiftUI

struct CustomModelEditorView: View {
  @Environment(\.dismiss) private var dismiss
  
  @State private var modelName = ""
  @State private var selectedProvider: AIModelProvider = .openAICompatible
  @State private var modelIdentifier = ""
  @State private var baseURL = ""
  @State private var apiKey = ""
  
  var body: some View {
    Form {
      Section {
        TextField(AppStrings.modelName, text: $modelName)
        TextField(AppStrings.modelID, text: $modelIdentifier)
      } header: {
        Text(AppStrings.modelBasicInfo)
      }
      
      Section {
        Picker(AppStrings.provider, selection: $selectedProvider) {
          ForEach(AIModelProvider.allCases) { provider in
            Text(provider.displayName).tag(provider)
          }
        }
        .pickerStyle(.navigationLink)
      } header: {
        Text(AppStrings.providerSelection)
      }
      
      Section {
        TextField(AppStrings.baseURL, text: $baseURL)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
        
        SecureField(AppStrings.apiKey, text: $apiKey)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
      } header: {
        Text(AppStrings.connectionConfig)
      } footer: {
        Text(AppStrings.providerInterfaceHint)
      }
    }
    .navigationTitle(AppStrings.createCustomModel)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(AppStrings.save) {
          AIModelStore.shared.saveCustomModel(
            name: modelName,
            provider: selectedProvider,
            modelIdentifier: modelIdentifier,
            baseURL: baseURL,
            apiKey: apiKey
          )
          dismiss()
        }
        .disabled(!canSave)
      }
    }
    .onAppear {
      applyDefaultBaseURL(for: selectedProvider)
    }
    .onChange(of: selectedProvider) { provider in
      applyDefaultBaseURL(for: provider)
    }
  }
  
  private var canSave: Bool {
    !modelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && !modelIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && !baseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
  
  private func applyDefaultBaseURL(for provider: AIModelProvider) {
    let providerDefaults = AIModelProvider.allCases.compactMap { $0.defaultBaseURL }
    if baseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      || providerDefaults.contains(baseURL) {
      baseURL = provider.defaultBaseURL ?? ""
    }
  }
}

#Preview {
  NavigationStack {
    CustomModelEditorView()
  }
}
