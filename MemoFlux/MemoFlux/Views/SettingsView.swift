//
//  SettingsView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/29.
//

import SwiftUI

struct SettingsView: View {
  @ObservedObject private var languageManager = LanguageManager.shared
  
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
          
          NavigationLink(destination: TagManagementView()) {
            HStack {
              Text(AppStrings.tagManagement)
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
