//
//  IntentDetectView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/25.
//

import SwiftUI

struct IntentDetectView: View {
  let apiResponse: APIResponse?
  let isLoading: Bool
  
  // 提醒确认视图状态
  @State private var showingReminderConfirmation = false
  
  init(apiResponse: APIResponse? = nil, isLoading: Bool = false) {
    self.apiResponse = apiResponse
    self.isLoading = isLoading
  }
  
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
        if isLoading {
          // 加载状态
          HStack(alignment: .center, spacing: 8) {
            ProgressView()
              .scaleEffect(0.8)
            
            Text("正在检测意图...")
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(.black)
            
            Spacer()
          }
          .padding(.bottom, 12)
          
        } else if let response = apiResponse, !response.schedule.tasks.isEmpty {
          // 检测到日程信息
          HStack(alignment: .center, spacing: 8) {
            Image(systemName: "brain.head.profile")
              .font(.system(size: 14))
              .foregroundColor(.green)
            
            Text("检测到日程安排")
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(.black)
            
            Spacer()
          }
          .padding(.bottom, 12)
          
          // 显示检测到的日程信息
          if let firstTask = response.schedule.tasks.first {
            VStack(alignment: .leading, spacing: 8) {
              Text("日程：\(firstTask.theme)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
              
              if let startDate = firstTask.startDate {
                Text("时间：\(startDate.formatted(date: .abbreviated, time: .shortened))")
                  .font(.system(size: 12))
                  .foregroundColor(.secondary)
              }
              
              if !firstTask.coreTasks.isEmpty {
                Text("任务：\(firstTask.coreTasks.joined(separator: "、"))")
                  .font(.system(size: 12))
                  .foregroundColor(.secondary)
                  .lineLimit(2)
              }
            }
            .padding(.bottom, 12)
          }
          
          // MARK: - 操作按钮 激活状态
          if let firstTask = response.schedule.tasks.first {
            ScheduleTaskHelper.actionButtons(
              for: firstTask,
              showingReminderConfirmation: $showingReminderConfirmation
            )
          }
          
        } else {
          // 默认状态或无日程信息
          HStack(alignment: .center, spacing: 8) {
            Image(systemName: "brain.head.profile")
              .font(.system(size: 14))
              .foregroundColor(.orange)
            
            Text(apiResponse != nil ? "未检测到日程安排" : "等待检测意图")
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
          
          // MARK: - 操作按钮 未激活状态
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
              Image(systemName: "list.bullet")
                .font(.system(size: 12))
                .foregroundColor(Color.buttonUnavailableTextColor)
              
              Text("添加到提醒事项")
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
      }
      .padding(16)
      .background(Color.yellowBackgroundColor)
      .cornerRadius(16)
    }
    .sheet(isPresented: $showingReminderConfirmation) {
      if let firstTask = apiResponse?.schedule.tasks.first {
        ReminderConfirmationView(task: firstTask)
      }
    }
  }
}

#Preview {
  VStack(spacing: 20) {
    IntentDetectView()
    IntentDetectView(isLoading: true)
  }
  .padding()
}
