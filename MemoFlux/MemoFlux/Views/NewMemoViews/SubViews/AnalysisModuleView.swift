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
      Text("智能解析结果")
        .font(.headline)
        .padding(.bottom, 10)
      
      VStack(alignment: .leading, spacing: 20) {
        HStack(alignment: .top, spacing: 0) {
          Rectangle()
            .fill(Color.teal)
            .frame(width: 4)
            .cornerRadius(2)
          
          VStack(alignment: .leading, spacing: 8) {
            Text("未识别到标题")
              .font(.system(size: 18, weight: .medium))
            
            Text("AI 分析：未识别到有效内容，请输入或上传信息")
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
          .padding(.leading, 12)
        }
        .padding(.horizontal, 15)
        
        HStack(spacing: 10) {
          Image(systemName: "lightbulb.fill")
            .foregroundColor(.orange)
          
          Text("添加更多内容可获得更精准的解析结果")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
      }
      .padding(.vertical, 15)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color(.systemGray5).opacity(0.5))
      .cornerRadius(15)
      .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  AnalysisModuleView()
}
