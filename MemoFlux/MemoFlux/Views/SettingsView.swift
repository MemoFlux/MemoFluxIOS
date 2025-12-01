//
//  SettingsView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/29.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var languageManager: LanguageManager
  
  var body: some View {
    NavigationStack {
      List {
        Section {
          NavigationLink(destination: LanguageSettingsView()) {
            HStack {
              Image(systemName: "globe")
                .foregroundColor(.mainStyleBackgroundColor)
              Text("settings.language".localized)
              Spacer()
              Text(languageManager.currentLanguage.displayName)
                .foregroundColor(.gray)
            }
          }
        } header: {
          Text("settings.language.description".localized)
        }
      }
      .navigationTitle("settings.title".localized)
    }
  }
}

struct LanguageSettingsView: View {
  @EnvironmentObject var languageManager: LanguageManager
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    List {
      ForEach(AppLanguage.allCases, id: \.self) { language in
        Button {
          languageManager.setLanguage(language)
          dismiss()
        } label: {
          HStack {
            Text(language.displayName)
            Spacer()
            if languageManager.currentLanguage == language {
              Image(systemName: "checkmark")
                .foregroundColor(.mainStyleBackgroundColor)
            }
          }
        }
      }
    }
    .navigationTitle("settings.language".localized)
  }
}

#Preview {
  SettingsView()
    .environmentObject(LanguageManager.shared)
}
