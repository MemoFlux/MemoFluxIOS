//
//  IntentChipModel.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/25.
//

import Foundation
import SwiftUI

/// 待处理意图数据模型
struct PendingIntent: Identifiable {
  let id: UUID
  let title: String
  let type: IntentType
  let iconName: String
  let iconColor: Color
}

/// 意图类型枚举
enum IntentType {
  case calendar
  case reminder
}
