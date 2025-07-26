//
//  FeatureComponent.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import SwiftUI

struct FeatureComponent: View {
  @State private var isAnimating: [Bool]
  
  private let features: [FeatureInfo] = [
    FeatureInfo(
      image: Image(systemName: "square.2.layers.3d.fill"),
      title: "智能图片识别",
      content: "快捷指令或上传图片，自动识别文字内容并进行AI分析，快速创建备忘录。"
    ),
    FeatureInfo(
      image: Image(systemName: "brain.head.profile"),
      title: "AI智能解析",
      content: "利用人工智能，自动分析内容并提取关键信息、生成标签和任务。"
    ),
    FeatureInfo(
      image: Image(systemName: "tag.fill"),
      title: "智能标签管理",
      content: "自动生成相关标签，帮助您更好地组织和查找备忘录内容。"
    ),
    FeatureInfo(
      image: Image(systemName: "calendar.badge.plus"),
      title: "日程任务提取",
      content: "从备忘录中智能提取时间和任务信息，自动生成日程安排。"
    ),
  ]
  
  private let accentColor: Color
  
  init(accentColor: Color) {
    self._isAnimating = State(initialValue: Array(repeating: false, count: features.count))
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
}
