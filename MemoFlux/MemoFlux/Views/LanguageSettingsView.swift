//
//  LanguageSettingsView.swift
//  MemoFlux
//
//  Created by AI Assistant on 2025/12/05.
//

import SwiftUI

struct LanguageSettingsView: View {
  @ObservedObject private var languageManager = LanguageManager.shared
  
  var body: some View {
    List {
      ForEach(AppLanguage.allCases) { language in
        HStack {
          Text(language.displayName)
          Spacer()
          if language == languageManager.currentLanguage {
            Image(systemName: "checkmark")
              .foregroundColor(.blue)
          }
        }
        .contentShape(Rectangle())
        .onTapGesture {
          languageManager.setLanguage(language)
        }
      }
    }
    .navigationTitle(AppStrings.language)
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationView {
    LanguageSettingsView()
  }
}

