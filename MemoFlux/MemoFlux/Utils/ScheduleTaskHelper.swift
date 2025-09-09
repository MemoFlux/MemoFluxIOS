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
  
  // 从ScheduleTask.TaskStatus转换
  static func from(_ taskStatus: ScheduleTask.TaskStatus) -> TaskActionStatus {
    switch taskStatus {
    case .pending:
      return .none
    case .completed:
      return .processed
    case .ignored:
      return .ignored
    }
  }
  
  // 转换为ScheduleTask.TaskStatus
  var toTaskStatus: ScheduleTask.TaskStatus {
    switch self {
    case .none:
      return .pending
    case .processed:
      return .completed
    case .ignored:
      return .ignored
    }
  }
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
  ///   - intentKey: 意图的唯一标识符
  ///   - intentManager: 意图完成状态管理器
  ///   - onDelete: 删除意图的回调
  /// - Returns: 包含日历和提醒事项按钮以及状态按钮的视图
  static func actionButtons(
    for task: ScheduleTask,
    showingReminderConfirmation: Binding<Bool>,
    fontSize: CGFloat = 12,
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
  
  // 任务状态更新回调
  var onStatusChange: ((ScheduleTask, ScheduleTask.TaskStatus) -> Void)?
  
  @State private var actionStatus: TaskActionStatus = .none
  
  // 初始化方法
  init(
    task: ScheduleTask,
    showingReminderConfirmation: Binding<Bool>,
    fontSize: CGFloat,
    intentKey: String? = nil,
    intentManager: IntentCompletionManager? = nil,
  ) {
    self.task = task
    self._showingReminderConfirmation = showingReminderConfirmation
    self.fontSize = fontSize
    
    // 根据任务状态初始化UI状态
    self._actionStatus = State(initialValue: TaskActionStatus.from(task.taskStatus))
  }
  
  var body: some View {
    HStack(spacing: 8) {
      ScheduleTaskHelper.calendarButton(for: task, fontSize: fontSize)
      ScheduleTaskHelper.reminderButton(
        for: task,
        showingReminderConfirmation: $showingReminderConfirmation,
        fontSize: fontSize
      )
    }
  }
}
