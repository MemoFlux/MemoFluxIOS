//
//  IntentDiscoveryView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/25.
//

import SwiftUI

/// 发现待处理意图视图
struct IntentDiscoveryView: View {
  @State private var pendingIntents: [PendingIntent] = [
    PendingIntent(
      id: UUID(),
      title: "项目会议 10:30",
      type: .calendar,
      iconName: "calendar",
      iconColor: Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255)
    ),
    PendingIntent(
      id: UUID(),
      title: "提交周报",
      type: .task,
      iconName: "calendar",
      iconColor: Color(.green)
    ),
    PendingIntent(
      id: UUID(),
      title: "回复客户邮件",
      type: .task,
      iconName: "calendar",
      iconColor: Color(.green)
    ),
    PendingIntent(
      id: UUID(),
      title: "购买生活用品",
      type: .reminder,
      iconName: "calendar",
      iconColor: Color(.green)
    ),
    PendingIntent(
      id: UUID(),
      title: "整理会议纪要",
      type: .note,
      iconName: "calendar",
      iconColor: Color(.green)
    ),
    PendingIntent(
      id: UUID(),
      title: "预约体检",
      type: .calendar,
      iconName: "calendar",
      iconColor: Color(.green)
    ),
    PendingIntent(
      id: UUID(),
      title: "学习新技术",
      type: .task,
      iconName: "calendar",
      iconColor: Color(.green)
    ),
    
  ]
  
  // 检查是否有待处理意图
  private var hasIntents: Bool {
    !pendingIntents.isEmpty
  }
  
  var body: some View {
    if hasIntents {
      VStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            HStack(spacing: 8) {
              Image(systemName: "bell.fill")
                .font(.system(size: 14))
                .foregroundColor(.orange)
              
              Text("发现待处理意图")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            }
            
            Spacer()
          }
          .padding(.bottom, 12)
          
          // 意图项目纵向排列，最多显示5个，可滚动
          ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 8) {
              ForEach(pendingIntents) { intent in
                IntentRowView(intent: intent) {
                  handleIntent(intent)
                }
              }
            }
            .padding(.vertical, 1)
          }
          .frame(maxHeight: min(CGFloat(pendingIntents.count) * 44, 220))
        }
        .padding(16)
        .background(Color.yellowBackgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
      }
    }
  }
  
  private func handleIntent(_ intent: PendingIntent) {
    // 处理单个意图
    print("处理意图: \(intent.title)")
    // TODO: 实现具体的意图处理逻辑
    withAnimation {
      pendingIntents.removeAll { $0.id == intent.id }
    }
  }
}

/// 意图 item 行视图
struct IntentRowView: View {
  let intent: PendingIntent
  let onTap: () -> Void
  
  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 12) {
        Image(systemName: intent.iconName)
          .font(.system(size: 16))
          .foregroundColor(intent.iconColor)
          .frame(width: 20, height: 20)
        
        Text(intent.title)
          .font(.system(size: 14))
          .foregroundColor(.primary)
          .frame(maxWidth: .infinity, alignment: .leading)
        
        Image(systemName: "chevron.right")
          .font(.system(size: 12))
          .foregroundColor(.secondary)
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 10)
      .background(Color.white)
      .cornerRadius(8)
      .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

/// 意图 item 胶囊视图
struct IntentChipView: View {
  let intent: PendingIntent
  let onTap: () -> Void
  
  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 6) {
        Image(systemName: intent.iconName)
          .font(.system(size: 12))
          .foregroundColor(intent.iconColor)
        
        Text(intent.title)
          .font(.system(size: 12))
          .foregroundColor(.primary)
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(Color.white)
      .cornerRadius(20)
      .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 1)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

#Preview {
  VStack(spacing: 16) {
    VStack(spacing: 12) {
      IntentDiscoveryView()
      
      IntentDiscoveryViewEmpty()
      
      VStack(alignment: .leading, spacing: 12) {
        Text("其他内容卡片")
          .font(.system(size: 16, weight: .bold))
        Text("这里是其他内容的示例，用来展示意图发现卡片在列表中的效果")
          .font(.system(size: 14))
          .foregroundColor(.secondary)
      }
      .padding(16)
      .background(Color.white)
      .cornerRadius(16)
      .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
  }
  .padding()
  .background(Color.globalStyleBackgroundColor)
}

// 预览用，空意图视图
private struct IntentDiscoveryViewEmpty: View {
  @State private var pendingIntents: [PendingIntent] = []
  
  private var hasIntents: Bool {
    !pendingIntents.isEmpty
  }
  
  var body: some View {
    if hasIntents {
      VStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            HStack(spacing: 8) {
              Image(systemName: "bell.fill")
                .font(.system(size: 14))
                .foregroundColor(.orange)
              
              Text("发现待处理意图")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            }
            
            Spacer()
            
            Button("全部处理") {
              // 空实现
            }
            .font(.system(size: 12))
            .foregroundColor(.grayTextColor)
          }
          .padding(.bottom, 12)
          
          ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 8) {
              // 空内容
            }
            .padding(.vertical, 1)
          }
          .frame(maxHeight: 220)
        }
        .padding(16)
        .background(Color.yellowBackgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
      }
    }
  }
}
