//
//  ModelSelectionView.swift
//  MemoFlux
//
//  Created by OpenAI Codex on 2026/3/31.
//

import SwiftUI

struct ModelSelectionView: View {
  @ObservedObject private var modelStore = AIModelStore.shared
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    List {
      Section(AppStrings.builtInModels) {
        ForEach(AIModelProfile.builtInModels) { model in
          modelRow(model)
        }
      }
      
      if !modelStore.customModels.isEmpty {
        Section(AppStrings.customModels) {
          ForEach(modelStore.customModels) { model in
            modelRow(model)
          }
        }
      }
    }
    .navigationTitle(AppStrings.modelSelection)
    .navigationBarTitleDisplayMode(.inline)
  }
  
  private func modelRow(_ model: AIModelProfile) -> some View {
    Button {
      modelStore.selectModel(id: model.id)
      dismiss()
    } label: {
      HStack(spacing: 12) {
        VStack(alignment: .leading, spacing: 4) {
          Text(model.name)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.primary)
          
          Text("\(model.provider.shortDisplayName) · \(model.modelIdentifier)")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
        }
        
        Spacer()
        
        if modelStore.selectedModelID == model.id {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.mainStyleBackgroundColor)
        }
      }
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  NavigationStack {
    ModelSelectionView()
  }
}
