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
        Text(AppStrings.smartAnalysisResults)
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
              Text(AppStrings.aiAnalyzing)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)

              Text(AppStrings.aiAnalyzingDesc)
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
              Text(AppStrings.analysisComplete)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)

              if !response.information.summary.isEmpty {
                Text(AppStrings.aiAnalysisSummaryPrefix(response.information.summary))
                  .font(.system(size: 12))
                  .foregroundColor(Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255))
              } else {
                Text(AppStrings.aiAnalysisFinishedPrefix)
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

            Text(AppStrings.analysisFinishedWithDetail)
              .font(.system(size: 12))
              .foregroundColor(.grayTextColor)
          }

        } else {
          // 默认状态
          HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
              Text(AppStrings.waitingForAnalysis)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)

              Text(AppStrings.aiAnalysisNoContent)
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

            Text(AppStrings.addMoreForBetterResults)
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
