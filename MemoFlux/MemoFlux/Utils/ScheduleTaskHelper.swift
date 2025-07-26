//
//  ScheduleTaskHelper.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import Foundation
import SwiftUI

/// 日程任务辅助工具类，封装添加到日历和提醒事项的功能
class ScheduleTaskHelper {
  static let shared = ScheduleTaskHelper()
  
  private init() {}
  
  // MARK: - 添加到日历
  /// 添加任务到日历
  /// - Parameter task: 要添加的任务
  static func addToCalendar(task: ScheduleTask) {
    let eventTitle = task.theme
    let eventNotes = createEventNotes(for: task)
    let eventStartDate = task.startDate ?? Date()
    
    EventManager.shared.requestCalendarAccess { granted, error in
      if granted && error == nil {
        let event = EventManager.shared.createCalendarEvent(
          title: eventTitle,
          notes: eventNotes,
          startDate: eventStartDate
        )
        EventManager.shared.presentCalendarEventEditor(for: event)
      } else {
        print("日历访问权限被拒绝或出现错误: \(error?.localizedDescription ?? "未知错误")")
      }
    }
  }
  
  // MARK: - 添加到提醒事项
  /// 直接添加任务到提醒事项（不显示确认界面）
  /// - Parameter task: 要添加的任务
  static func addToReminders(task: ScheduleTask) {
    let reminderTitle = task.theme
    let reminderNotes = createEventNotes(for: task)
    let reminderDate = task.startDate
    
    EventManager.shared.addReminder(
      title: reminderTitle,
      notes: reminderNotes,
      date: reminderDate
    ) { success, error in
      if success {
        print("提醒事项创建成功: \(reminderTitle)")
      } else {
        print("提醒事项创建失败: \(error?.localizedDescription ?? "未知错误")")
      }
    }
  }
  
  // MARK: - 事件备注
  /// 格式化备注信息
  /// - Parameter task: 任务对象
  /// - Returns: 格式化的备注字符串
  static func createEventNotes(for task: ScheduleTask) -> String {
    var notes = ""
    
    if !task.coreTasks.isEmpty {
      notes += "核心任务:\n"
      for coreTask in task.coreTasks {
        notes += "• \(coreTask)\n"
      }
      notes += "\n"
    }
    
    if !task.suggestedActions.isEmpty {
      notes += "建议行动:\n"
      for action in task.suggestedActions {
        notes += "• \(action)\n"
      }
      notes += "\n"
    }
    
    if !task.people.isEmpty {
      notes += "参与人员: \(task.people.joined(separator: ", "))\n"
    }
    
    if !task.position.isEmpty {
      notes += "地点: \(task.position.joined(separator: ", "))\n"
    }
    
    if !task.tags.isEmpty {
      notes += "标签: \(task.tags.joined(separator: ", "))"
    }
    
    return notes.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

// MARK: - 任务状态枚举
enum TaskActionStatus {
  case none
  case processed
  case ignored
}

// MARK: - SwiftUI 扩展
extension ScheduleTaskHelper {
  /// SwiftUI 视图 - 日历按钮
  /// - Parameters:
  ///   - task: 任务对象
  ///   - fontSize: 字体大小，默认为12
  /// - Returns: 日历按钮视图
  static func calendarButton(for task: ScheduleTask, fontSize: CGFloat = 12) -> some View {
    Button {
      addToCalendar(task: task)
    } label: {
      HStack(spacing: 6) {
        Image(systemName: "calendar")
          .font(.system(size: fontSize))
        
        Text("添加到日历")
          .font(.system(size: fontSize))
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .foregroundStyle(.white)
      .background(.blue)
      .cornerRadius(12)
    }
  }
  
  /// SwiftUI 视图（显示确认界面）- 提醒事项
  /// - Parameters:
  ///   - task: 任务对象
  ///   - showingReminderConfirmation: 绑定的状态变量
  ///   - fontSize: 字体大小，默认为12
  /// - Returns: 提醒事项按钮视图
  static func reminderButton(
    for task: ScheduleTask, showingReminderConfirmation: Binding<Bool>, fontSize: CGFloat = 12
  ) -> some View {
    Button {
      showingReminderConfirmation.wrappedValue = true
    } label: {
      HStack(spacing: 6) {
        Image(systemName: "list.bullet")
          .font(.system(size: fontSize))
        
        Text("添加到提醒事项")
          .font(.system(size: fontSize))
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .foregroundStyle(.white)
      .background(.yellow)
      .cornerRadius(12)
    }
  }
  
  /// 操作按钮 group（带状态管理）
  /// - Parameters:
  ///   - task: 任务对象
  ///   - showingReminderConfirmation: 绑定的状态变量
  ///   - fontSize: 字体大小，默认为12
  /// - Returns: 包含日历和提醒事项按钮以及状态按钮的视图
  static func actionButtons(
    for task: ScheduleTask, showingReminderConfirmation: Binding<Bool>, fontSize: CGFloat = 12
  ) -> some View {
    ActionButtonsView(
      task: task,
      showingReminderConfirmation: showingReminderConfirmation,
      fontSize: fontSize
    )
  }
}

// MARK: - 操作按钮视图
struct ActionButtonsView: View {
  let task: ScheduleTask
  @Binding var showingReminderConfirmation: Bool
  let fontSize: CGFloat
  
  @State private var actionStatus: TaskActionStatus = .none
  
  var body: some View {
    HStack(spacing: 8) {
      ScheduleTaskHelper.calendarButton(for: task, fontSize: fontSize)
      ScheduleTaskHelper.reminderButton(
        for: task,
        showingReminderConfirmation: $showingReminderConfirmation,
        fontSize: fontSize
      )
      
      Spacer()
      
      // 状态按钮区域
      statusButtonsArea
    }
  }
  
  @ViewBuilder
  private var statusButtonsArea: some View {
    switch actionStatus {
    case .none:
      HStack(spacing: 8) {
        // 绿色确认按钮
        Button {
          withAnimation(.easeInOut(duration: 0.3)) {
            actionStatus = .processed
          }
        } label: {
          Image(systemName: "checkmark")
            .font(.system(size: fontSize + 2, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(Color.green)
            .clipShape(Circle())
        }
        
        // 红色忽略按钮
        Button {
          withAnimation(.easeInOut(duration: 0.3)) {
            actionStatus = .ignored
          }
        } label: {
          Image(systemName: "xmark")
            .font(.system(size: fontSize + 2, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 36, height: 36)
            .background(Color.red)
            .clipShape(Circle())
        }
      }
      
    case .processed:
      // 显示"✓已处理"胶囊按钮
      Button {
        withAnimation(.easeInOut(duration: 0.3)) {
          actionStatus = .none
        }
      } label: {
        HStack(spacing: 6) {
          Image(systemName: "checkmark")
            .font(.system(size: fontSize + 1, weight: .bold))
          Text("确认处理")
            .font(.system(size: fontSize + 1, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.green)
        .clipShape(Capsule())
      }
      .transition(.scale.combined(with: .opacity))
      
    case .ignored:
      // 显示"×忽略"胶囊按钮
      Button {
        withAnimation(.easeInOut(duration: 0.3)) {
          actionStatus = .none
        }
      } label: {
        HStack(spacing: 6) {
          Image(systemName: "xmark")
            .font(.system(size: fontSize + 1, weight: .bold))
          Text("确认忽略")
            .font(.system(size: fontSize + 1, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.red)
        .clipShape(Capsule())
      }
      .transition(.scale.combined(with: .opacity))
    }
  }
}
