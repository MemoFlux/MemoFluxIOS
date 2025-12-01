//
//  FeatureComponent.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import SwiftUI

struct FeatureComponent: View {
  @State private var isAnimating: [Bool]
  
  private var features: [FeatureInfo] {
    [
      FeatureInfo(
        image: Image(systemName: "square.2.layers.3d.fill"),
        title: "onboarding.feature.image.recognition.title".localized,
        content: "onboarding.feature.image.recognition.content".localized
      ),
      FeatureInfo(
        image: Image(systemName: "brain.head.profile"),
        title: "onboarding.feature.ai.analysis.title".localized,
        content: "onboarding.feature.ai.analysis.content".localized
      ),
      FeatureInfo(
        image: Image(systemName: "tag.fill"),
        title: "onboarding.feature.tag.management.title".localized,
        content: "onboarding.feature.tag.management.content".localized
      ),
      FeatureInfo(
        image: Image(systemName: "calendar.badge.plus"),
        title: "onboarding.feature.schedule.extraction.title".localized,
        content: "onboarding.feature.schedule.extraction.content".localized
      ),
    ]
  }
  
  private let accentColor: Color
  
  init(accentColor: Color) {
    // 固定为4个特性
    self._isAnimating = State(initialValue: Array(repeating: false, count: 4))
    self.accentColor = accentColor
  }
  
  var body: some View {
    VStack(spacing: 24) {
      ForEach(features.indices, id: \.self) { index in
        FeatureView(info: features[index], accentColor: accentColor)
          .opacity(isAnimating[index] ? 1 : 0)
          .offset(y: isAnimating[index] ? 0 : 100)
          .onAppear {
            withAnimation(.easeInOut(duration: 0.8).delay(1.6 + Double(index) * 0.16)) {
              isAnimating[index] = true
            }
          }
      }
    }
  }
}

public struct FeatureInfo: Identifiable {
  public let id: UUID = .init()
  let image: Image
  let title: String
  let content: String
  
  public init(image: Image, title: String, content: String) {
    self.image = image
    self.title = title
    self.content = content
  }
}

#Preview {
  FeatureComponent(accentColor: Color.mainStyleBackgroundColor)
    .padding()
    .background(Color.globalStyleBackgroundColor)
    .environmentObject(LanguageManager.shared)
}
