//
//  APIResponseModels.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/25.
//

import Foundation

// MARK: - 请求模型
struct AIGenerationRequest: Codable {
  let tags: [String]
  let content: String
  let isimage: Int
  
  enum CodingKeys: String, CodingKey {
    case tags
    case content
    case isimage
  }
}

// MARK: - 网络错误类型
enum NetworkError: Error, LocalizedError {
  case invalidURL
  case noData
  case decodingError(Error)
  case serverError(Int)
  case unauthorized
  case networkError(Error)
  
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "无效的URL"
    case .noData:
      return "没有接收到数据"
    case .decodingError(let error):
      return "数据解析错误: \(error.localizedDescription)"
    case .serverError(let code):
      return "服务器错误: \(code)"
    case .unauthorized:
      return "未授权访问"
    case .networkError(let error):
      return "网络错误: \(error.localizedDescription)"
    }
  }
}

// MARK: - 主响应模型
struct APIResponse: Codable, Equatable {
  let mostPossibleCategory: String
  let information: InformationResponse
  let schedule: ScheduleResponse
  
  enum CodingKeys: String, CodingKey {
    case mostPossibleCategory
    case information
    case schedule
  }
}

// MARK: - Information 模型
struct InformationResponse: Codable, Equatable {
  let title: String
  let informationItems: [InformationItem]
  let relatedItems: [String]
  let summary: String
  let tags: [String]
  
  enum CodingKeys: String, CodingKey {
    case title
    case informationItems = "informationItems"
    case relatedItems = "relatedItems"
    case summary
    case tags
  }
}

struct InformationItem: Codable, Identifiable, Equatable {
  let id: Int
  let header: String
  let content: String
  let node: InformationNode?
}

struct InformationNode: Codable, Equatable {
  let targetId: Int
  let relationship: String
  
  enum CodingKeys: String, CodingKey {
    case targetId
    case relationship
  }
}

// MARK: - Schedule 模型
struct ScheduleResponse: Codable, Equatable {
  let title: String
  let category: String
  let tasks: [ScheduleTask]
}

struct ScheduleTask: Codable, Identifiable, Equatable {
  let startTime: String
  let endTime: String
  let people: [String]
  let theme: String
  let coreTasks: [String]
  let position: [String]
  let tags: [String]
  let category: String
  let suggestedActions: [String]
  let id: UUID
  
  enum CodingKeys: String, CodingKey {
    case startTime = "startTime"
    case endTime = "endTime"
    case people
    case theme
    case coreTasks = "coreTasks"
    case position
    case tags
    case category
    case suggestedActions = "suggestedActions"
    // 注意：id不包含在CodingKeys中，因为我们不从API解码它
  }
  
  // 自定义初始化器，自动生成UUID
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    startTime = try container.decode(String.self, forKey: .startTime)
    endTime = try container.decode(String.self, forKey: .endTime)
    people = try container.decode([String].self, forKey: .people)
    theme = try container.decode(String.self, forKey: .theme)
    coreTasks = try container.decode([String].self, forKey: .coreTasks)
    position = try container.decode([String].self, forKey: .position)
    tags = try container.decode([String].self, forKey: .tags)
    category = try container.decode(String.self, forKey: .category)
    suggestedActions = try container.decode([String].self, forKey: .suggestedActions)
    // 自动生成UUID
    id = UUID()
  }
  
  // 编码时不包含id字段
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(startTime, forKey: .startTime)
    try container.encode(endTime, forKey: .endTime)
    try container.encode(people, forKey: .people)
    try container.encode(theme, forKey: .theme)
    try container.encode(coreTasks, forKey: .coreTasks)
    try container.encode(position, forKey: .position)
    try container.encode(tags, forKey: .tags)
    try container.encode(category, forKey: .category)
    try container.encode(suggestedActions, forKey: .suggestedActions)
  }
  
  // 手动初始化器（用于测试和预览）
  init(
    startTime: String,
    endTime: String,
    people: [String],
    theme: String,
    coreTasks: [String],
    position: [String],
    tags: [String],
    category: String,
    suggestedActions: [String],
    id: UUID = UUID()
  ) {
    self.startTime = startTime
    self.endTime = endTime
    self.people = people
    self.theme = theme
    self.coreTasks = coreTasks
    self.position = position
    self.tags = tags
    self.category = category
    self.suggestedActions = suggestedActions
    self.id = id
  }
  
  // 将字符串时间转换为Date
  var startDate: Date? {
    return ISO8601DateFormatter().date(from: startTime)
  }
  
  var endDate: Date? {
    return ISO8601DateFormatter().date(from: endTime)
  }
}

// MARK: - 扩展
extension APIResponse {
  /// 获取所有任务的标签
  var allTags: Set<String> {
    var tags = Set<String>()
    tags.formUnion(information.tags)
    schedule.tasks.forEach { task in
      tags.formUnion(task.tags)
    }
    return tags
  }
  
  /// 获取所有任务
  var allTasks: [ScheduleTask] {
    return schedule.tasks
  }
  
  /// 根据日期筛选任务
  func tasks(for date: Date) -> [ScheduleTask] {
    let calendar = Calendar.current
    return schedule.tasks.filter { task in
      guard let taskDate = task.startDate else { return false }
      return calendar.isDate(taskDate, inSameDayAs: date)
    }
  }
}
