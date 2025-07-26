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
  
  init(memoItem: MemoItemModel, scheduleTask: ScheduleTask) {
    self.id = UUID()
    self.memoItem = memoItem
    self.scheduleTask = scheduleTask
    self.title = scheduleTask.theme
    self.iconName = "calendar"
    self.iconColor = Color(.orange)
  }
}
