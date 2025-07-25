//
//  IntentDetectView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/25.
//

import SwiftUI

struct IntentDetectView: View {
  @State private var hasDetectedIntent = false

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text("意图识别")
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.black)
        Spacer()
      }
      .padding(.bottom, 8)
      .padding(.leading, 5)

      VStack(alignment: .leading, spacing: 0) {
        HStack(alignment: .center, spacing: 8) {
          Image(systemName: "brain.head.profile")
            .font(.system(size: 14))
            .foregroundColor(.orange)

          Text("未检测到明确意图")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.black)

          Spacer()
        }
        .padding(.bottom, 12)

        // MARK: - 描述文本
        Text("当AI检测到日程安排、任务提醒等意图时，会在这里提供快捷操作选项。")
          .font(.system(size: 12))
          .foregroundColor(.grayTextColor)
          .lineLimit(nil)
          .padding(.bottom, 12)

        // MARK: - 操作按钮
        HStack(spacing: 8) {
          HStack(spacing: 6) {
            Image(systemName: "calendar")
              .font(.system(size: 12))
              .foregroundColor(Color.buttonUnavailableTextColor)

            Text("添加到日历")
              .font(.system(size: 12))
              .foregroundColor(Color.buttonUnavailableTextColor)
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(Color.buttonUnavailableBackgroundColor)
          .cornerRadius(12)

          HStack(spacing: 6) {
            Image(systemName: "bell")
              .font(.system(size: 12))
              .foregroundColor(Color.buttonUnavailableTextColor)

            Text("创建提醒")
              .font(.system(size: 12))
              .foregroundColor(Color.buttonUnavailableTextColor)
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(Color.buttonUnavailableBackgroundColor)
          .cornerRadius(12)

          Spacer()
        }
      }
      .padding(16)
      .background(Color.yellowBackgroundColor)
      .cornerRadius(16)
    }
  }
}

#Preview {
  IntentDetectView()
}
