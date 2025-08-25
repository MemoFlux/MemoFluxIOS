//
//  AnalysisModuleView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftUI

struct AnalysisModuleView: View {
  let apiResponse: APIResponse?
  let isLoading: Bool

  init(apiResponse: APIResponse? = nil, isLoading: Bool = false) {
    self.apiResponse = apiResponse
    self.isLoading = isLoading
  }

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
        if isLoading {
          // 加载状态
          HStack(alignment: .center, spacing: 12) {
            ProgressView()
              .scaleEffect(0.8)

            VStack(alignment: .leading, spacing: 4) {
              Text("AI正在分析中...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)

              Text("请稍候，正在为您生成智能解析结果")
                .font(.system(size: 12))
                .foregroundColor(Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255))
            }

            Spacer()
          }
          .padding(.bottom, 12)

        } else if let response = apiResponse {
          // 有API响应数据
          HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
              Text("AI 分析完成")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)

              if !response.information.summary.isEmpty {
                Text("AI 分析：\(response.information.summary)")
                  .font(.system(size: 12))
                  .foregroundColor(Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255))
              } else {
                Text("AI 分析：已完成内容分析")
                  .font(.system(size: 12))
                  .foregroundColor(Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255))
              }
            }
            .padding(.leading, 20)
            .overlay(
              Rectangle()
                .fill(Color.green)
                .frame(width: 4)
                .cornerRadius(2)
                .padding(.leading, 3),
              alignment: .leading
            )

            Spacer()
          }
          .padding(.bottom, 12)

          HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
              .font(.system(size: 12))
              .foregroundColor(.green)

            Text("AI分析已完成，可查看详细解析结果")
              .font(.system(size: 12))
              .foregroundColor(.grayTextColor)
          }

        } else {
          // 默认状态
          HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
              Text("等待解析信息")
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
      }
      .padding(16)
      .background(Color.grayBackgroundColor)
      .cornerRadius(16)
    }
  }
}

#Preview {
  VStack(spacing: 20) {
    AnalysisModuleView()
    AnalysisModuleView(isLoading: true)
  }
  .padding()
}
