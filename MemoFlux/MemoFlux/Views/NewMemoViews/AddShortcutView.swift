//
//  AddShortcutView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftUI

struct AddShortcutView: View {
  @Environment(\.dismiss) private var dismiss
  
  // 快捷指令链接
  private let shortcutURL = URL(string: "https://www.icloud.com/shortcuts/6ab04469d285467f8be052eebc6f276f")!
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          // 顶部图标和标题
          VStack(spacing: 16) {
            ZStack {
              Circle()
                .fill(Color.mainStyleBackgroundColor.opacity(0.1))
                .frame(width: 80, height: 80)
              
              Image(systemName: "square.2.layers.3d.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.mainStyleBackgroundColor)
            }
            
            Text("MemoFlux 快捷指令")
              .font(.system(size: 24, weight: .bold))
              .foregroundColor(.primary)
          }
          .padding(.top, 20)
          
          // 快捷指令介绍
          VStack(alignment: .leading, spacing: 16) {
            featureRow(icon: "bolt.fill", title: "快速捕捉", description: "随时随地一键启动，快速捕捉灵感和信息")
            
            featureRow(icon: "arrow.right.doc.on.clipboard", title: "直接导入", description: "拍照或选择图片后自动导入到 MemoFlux 应用")
            
            featureRow(icon: "text.viewfinder", title: "智能识别", description: "自动识别图片中的文字，无需手动输入")
            
            featureRow(icon: "brain", title: "AI 分析", description: "使用 AI 自动分析内容，提取关键信息")
          }
          .padding(.horizontal, 20)
          
          // 安装提示
          VStack(spacing: 12) {
            Text("安装步骤")
              .font(.system(size: 18, weight: .semibold))
              .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .top, spacing: 12) {
              Text("1")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.mainStyleBackgroundColor)
                .clipShape(Circle())
              
              VStack(alignment: .leading, spacing: 4) {
                Text("点击下方按钮")
                  .font(.system(size: 16, weight: .medium))
                
                Text("将跳转到快捷指令应用")
                  .font(.system(size: 14))
                  .foregroundColor(.secondary)
              }
              
              Spacer()
            }
            
            HStack(alignment: .top, spacing: 12) {
              Text("2")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.mainStyleBackgroundColor)
                .clipShape(Circle())
              
              VStack(alignment: .leading, spacing: 4) {
                Text("添加快捷指令")
                  .font(.system(size: 16, weight: .medium))
                
                Text("在快捷指令应用中点击\"添加快捷指令\"")
                  .font(.system(size: 14))
                  .foregroundColor(.secondary)
              }
              
              Spacer()
            }
          }
          .padding(.horizontal, 20)
          .padding(.top, 10)
          
          // 安装按钮
          Button {
            UIApplication.shared.open(shortcutURL)
          } label: {
            HStack {
              Image(systemName: "square.and.arrow.down")
              Text("安装快捷指令")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.mainStyleBackgroundColor)
            .cornerRadius(12)
          }
          .padding(.horizontal, 20)
          .padding(.top, 20)
          
          // 提示信息
          HStack(spacing: 8) {
            Image(systemName: "info.circle")
              .font(.system(size: 14))
            
            Text("可添加到Action Button或通过辅助触控快速启动")
              .font(.system(size: 14))
          }
          .foregroundColor(.grayTextColor)
          .padding(.top, 8)
          .padding(.horizontal, 20)
        }
        .padding(.bottom, 40)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.globalStyleBackgroundColor)
      .navigationTitle("添加快捷指令")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
  
  // 特性行视图
  private func featureRow(icon: String, title: String, description: String) -> some View {
    HStack(alignment: .top, spacing: 16) {
      ZStack {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.mainStyleBackgroundColor.opacity(0.1))
          .frame(width: 36, height: 36)
        
        Image(systemName: icon)
          .font(.system(size: 18))
          .foregroundStyle(Color.mainStyleBackgroundColor)
      }
      
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(.primary)
        
        Text(description)
          .font(.system(size: 14))
          .foregroundColor(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
      
      Spacer()
    }
  }
}

#Preview {
  AddShortcutView()
}
