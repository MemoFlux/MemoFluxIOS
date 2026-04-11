//
//  SettingsView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/29.
//

import SwiftUI

struct SettingsView: View {
  @ObservedObject private var languageManager = LanguageManager.shared
  @ObservedObject private var modelStore = AIModelStore.shared
  
  var body: some View {
    NavigationView {
      List {
        Section {
          NavigationLink(destination: LanguageSettingsView()) {
            HStack {
              Text(AppStrings.language)
              Spacer()
              Text(languageManager.currentLanguage.displayName)
                .foregroundColor(.secondary)
            }
          }
          
          NavigationLink(destination: ModelManagementView()) {
            HStack {
              Text(AppStrings.modelSelection)
              Spacer()
              Text(modelStore.selectedModel.name)
                .foregroundColor(.secondary)
                .lineLimit(1)
            }
          }
          
          NavigationLink(destination: TagManagementView()) {
            HStack {
              Text(AppStrings.tagManagement)
              Spacer()
            }
          }
          
          NavigationLink(destination: TopicManagementView()) {
            HStack {
              Text(AppStrings.topicManagement)
              Spacer()
            }
          }
        }
      }
      .navigationTitle(AppStrings.settingsTitle)
    }
  }
}

#Preview {
  SettingsView()
}
