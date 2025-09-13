//
//  ScheduleTaskModel.swift
//  MemoFlux
//
//  Created by AI Assistant on 2025/1/14.
//

import Foundation
import SwiftData

/// 日程任务模型 - 使用@Model类以支持SwiftData变化追踪
@Model
final class ScheduleTaskModel: Identifiable {
  var id: UUID = UUID()
  var startTime: String = ""
  var endTime: String = ""
  var people: [String] = []
  var theme: String = ""
  var coreTasks: [String] = []
  var position: [String] = []
  var tags: [String] = []
  var category: String = ""
  var suggestedActions: [String] = []
  
  // 任务状态枚举
  enum TaskStatus: String, Codable {
    case pending = "待处理"
    case completed = "已处理"
    case ignored = "已忽略"
  }
  
  // 任务状态，默认为待处理
  var taskStatus: TaskStatus = TaskStatus.pending
  
  // 关联的MemoItem ID - 使用UUID而不是直接关系避免循环引用
  var memoItemId: UUID?
  
  init(
    id: UUID = UUID(),
    startTime: String,
    endTime: String,
    people: [String],
    theme: String,
    coreTasks: [String],
    position: [String],
    tags: [String],
    category: String,
    suggestedActions: [String],
    status: TaskStatus = .pending,
    memoItemId: UUID? = nil
  ) {
    self.id = id
    self.startTime = startTime
    self.endTime = endTime
    self.people = people
    self.theme = theme
    self.coreTasks = coreTasks
    self.position = position
    self.tags = tags
    self.category = category
    self.suggestedActions = suggestedActions
    self.taskStatus = status
    self.memoItemId = memoItemId
  }
  
  // 将字符串时间转换为Date
  var startDate: Date? {
    return ISO8601DateFormatter().date(from: startTime)
  }
  
  var endDate: Date? {
    return ISO8601DateFormatter().date(from: endTime)
  }
  
  // MARK: - 状态管理方法
  /// 将任务标记为待处理
  func markAsPending() {
    taskStatus = .pending
  }
  
  /// 将任务标记为已处理
  func markAsCompleted() {
    taskStatus = .completed
  }
  
  /// 将任务标记为已忽略
  func markAsIgnored() {
    taskStatus = .ignored
  }
  
  /// 获取当前状态的显示文本
  var statusText: String {
    return taskStatus.rawValue
  }
}
