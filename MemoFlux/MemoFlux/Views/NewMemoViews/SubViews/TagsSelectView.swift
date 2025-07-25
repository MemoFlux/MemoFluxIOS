//
//  TagsSelectView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/25.
//

import SwiftUI

struct TagsSelectView: View {
  @State private var selectedTags: Set<String> = ["工作"]
  @State private var recommendedTags = ["工作", "会议", "笔记", "任务", "日程", "旅行", "美食"]

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // 标题和添加自定义按钮
      HStack {
        Text("添加标签")
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.black)

        Spacer()

        Button("添加自定义") {
          // 添加自定义标签的逻辑
        }
        .font(.system(size: 12))
        .foregroundColor(.mainStyleBackgroundColor)
      }
      .padding(.bottom, 8)
      .padding(.horizontal, 5)

      // 卡片容器
      VStack(alignment: .leading, spacing: 0) {
        // 描述文本
        //        Text("基于内容智能推荐的标签，点击选择：")
        //          .font(.system(size: 12))
        //          .foregroundColor(.grayTextColor)
        //          .padding(.bottom, 12)

        // 标签芯片布局
        LazyVGrid(
          columns: [
            GridItem(.adaptive(minimum: 60), spacing: 8)
          ], spacing: 10
        ) {
          ForEach(recommendedTags, id: \.self) { tag in
            TagChipView(
              tag: tag,
              isSelected: selectedTags.contains(tag)
            ) {
              toggleTag(tag)
            }
          }
        }
      }
      .padding(16)
      .background(Color.grayBackgroundColor)
      .cornerRadius(16)
    }
  }

  private func toggleTag(_ tag: String) {
    if selectedTags.contains(tag) {
      selectedTags.remove(tag)
    } else {
      selectedTags.insert(tag)
    }
  }
}

struct TagChipView: View {
  let tag: String
  let isSelected: Bool
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 4) {
        Text(tag)
          .font(.system(size: 14))
          .foregroundColor(isSelected ? .white : .grayTextColor)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(
        isSelected
          ? Color.mainStyleBackgroundColor
          : Color.buttonUnavailableBackgroundColor
      )
      .clipShape(.capsule)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

#Preview {
  TagsSelectView()
}
