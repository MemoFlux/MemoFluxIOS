//
//  IntentDiscoveryViewModel.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import Foundation
import SwiftUI

/// 今日待处理意图数据模型
struct IntentDiscoveryViewModel: Identifiable {
  let id: UUID
  let title: String
  let memoItem: MemoItemModel  // 关联的 Memo 项目
  let scheduleTask: ScheduleTask  // 具体的日程任务
  let iconName: String
  let iconColor: Color
  var isCompleted: Bool  // 添加完成状态标记

  init(memoItem: MemoItemModel, scheduleTask: ScheduleTask, isCompleted: Bool = false) {
    self.id = UUID()
    self.memoItem = memoItem
    self.scheduleTask = scheduleTask
    self.title = scheduleTask.theme
    self.iconName = "calendar"
    self.iconColor = Color(.orange)
    self.isCompleted = isCompleted
  }

  /// 生成唯一的意图标识符，用于状态管理
  var intentKey: String {
    return "\(memoItem.id.uuidString)-\(scheduleTask.id)"
  }
}

/// 意图完成状态管理器
class IntentCompletionManager: ObservableObject {
  @Published private var completedIntents: Set<String> = []

  /// 标记意图为已完成
  func markAsCompleted(_ intentKey: String) {
    completedIntents.insert(intentKey)
  }

  /// 标记意图为未完成
  func markAsIncomplete(_ intentKey: String) {
    completedIntents.remove(intentKey)
  }

  /// 检查意图是否已完成
  func isCompleted(_ intentKey: String) -> Bool {
    return completedIntents.contains(intentKey)
  }

  /// 切换意图完成状态
  func toggleCompletion(_ intentKey: String) {
    if isCompleted(intentKey) {
      markAsIncomplete(intentKey)
    } else {
      markAsCompleted(intentKey)
    }
  }
}
