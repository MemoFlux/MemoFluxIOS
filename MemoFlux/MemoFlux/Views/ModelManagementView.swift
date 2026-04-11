//
//  ModelManagementView.swift
//  MemoFlux
//
//  Created by OpenAI Codex on 2026/3/31.
//

import SwiftUI

struct ModelManagementView: View {
  @ObservedObject private var modelStore = AIModelStore.shared
  
  var body: some View {
    List {
      Section(AppStrings.currentModel) {
        NavigationLink(destination: ModelSelectionView()) {
          HStack {
            Text(AppStrings.modelSelection)
            Spacer()
            Text(modelStore.selectedModel.name)
              .foregroundColor(.secondary)
              .lineLimit(1)
          }
        }
      }
      
      Section(AppStrings.builtInModels) {
        ForEach(AIModelProfile.builtInModels) { model in
          modelRow(model)
        }
      }
      
      Section {
        NavigationLink(destination: CustomModelEditorView()) {
          Label(AppStrings.createCustomModel, systemImage: "plus.circle")
        }
        
        if !modelStore.customModels.isEmpty {
          ForEach(modelStore.customModels) { model in
            modelRow(model)
          }
          .onDelete(perform: modelStore.deleteCustomModels)
        }
      } header: {
        Text(AppStrings.customModels)
      } footer: {
        Text(AppStrings.customModelHint)
      }
    }
    .navigationTitle(AppStrings.modelSelection)
    .navigationBarTitleDisplayMode(.inline)
  }
  
  private func modelRow(_ model: AIModelProfile) -> some View {
    HStack(spacing: 12) {
      VStack(alignment: .leading, spacing: 4) {
        Text(model.name)
          .font(.system(size: 16, weight: .medium))
        
        Text("\(model.provider.displayName) · \(model.modelIdentifier)")
          .font(.system(size: 12))
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      if modelStore.selectedModelID == model.id {
        Image(systemName: "checkmark.circle.fill")
          .foregroundColor(.mainStyleBackgroundColor)
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      modelStore.selectModel(id: model.id)
    }
  }
}

#Preview {
  NavigationStack {
    ModelManagementView()
  }
}
