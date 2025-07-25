//
//  AnalysisModuleView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftUI

struct AnalysisModuleView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // 标题
      HStack {
        Text("智能解析结果")
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.black)
        Spacer()
      }
      .padding(.bottom, 8)
      .padding(.leading, 5)

      // 解析结果卡片
      VStack(alignment: .leading, spacing: 0) {
        HStack(alignment: .top, spacing: 12) {
          VStack(alignment: .leading, spacing: 10) {
            Text("未识别到标题")
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(.black)

            Text(
              "AI 分析：未识别到有效内容，请输入或上传信息"
            )
            .font(.system(size: 12))
            .foregroundColor(Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255))
          }
          .padding(.leading, 20)
          .overlay(
            Rectangle()
              .fill(Color.mainStyleBackgroundColor)
              .frame(width: 4)
              .cornerRadius(2)
              .padding(.leading, 3),
            alignment: .leading
          )

          Spacer()
        }
        .padding(.bottom, 12)

        HStack(spacing: 8) {
          Image(systemName: "lightbulb.fill")
            .font(.system(size: 12))
            .foregroundColor(Color(red: 245 / 255, green: 158 / 255, blue: 11 / 255))

          Text("添加更多内容可获得更精准的解析结果")
            .font(.system(size: 12))
            .foregroundColor(.grayTextColor)
        }
      }
      .padding(16)
      .background(Color.grayBackgroundColor)
      .cornerRadius(16)
    }
  }
}

#Preview {
  AnalysisModuleView()
}
