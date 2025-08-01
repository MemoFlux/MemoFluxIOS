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
  let knowledge: KnowledgeResponse
  let information: InformationResponse
  let schedule: ScheduleResponse
  let mostPossibleCategory: String

  enum CodingKeys: String, CodingKey {
    case knowledge
    case information
    case schedule
    case mostPossibleCategory = "most_possbile_category"
  }
}

// MARK: - Knowledge 模型
struct KnowledgeResponse: Codable, Equatable {
  let title: String
  let knowledgeItems: [KnowledgeItem]
  let relatedItems: [String]
  let tags: [String]
  let category: String

  enum CodingKeys: String, CodingKey {
    case title
    case knowledgeItems = "knowledge_items"
    case relatedItems = "related_items"
    case tags
    case category
  }
}

struct KnowledgeItem: Codable, Identifiable, Equatable {
  let id: Int
  let header: String
  let content: String
  let node: KnowledgeNode?
}

struct KnowledgeNode: Codable, Equatable {
  let targetId: Int?
  let relationship: String?

  enum CodingKeys: String, CodingKey {
    case targetId = "target_id"
    case targetIdTypo = "targert_id"  // 保留错误拼写，保证兼容性
    case relationship
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let targetId = try container.decodeIfPresent(Int.self, forKey: .targetId) {
      self.targetId = targetId
    } else if let targetId = try container.decodeIfPresent(Int.self, forKey: .targetIdTypo) {
      self.targetId = targetId
    } else {
      self.targetId = nil
    }

    self.relationship = try container.decodeIfPresent(String.self, forKey: .relationship)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(targetId, forKey: .targetId)
    try container.encodeIfPresent(relationship, forKey: .relationship)
  }
}

// MARK: - Information 模型
struct InformationResponse: Codable, Equatable {
  let title: String
  let informationItems: [InformationItem]
  let postType: String
  let summary: String
  let tags: [String]
  let category: String

  enum CodingKeys: String, CodingKey {
    case title
    case informationItems = "information_items"
    case postType = "post_type"
    case summary
    case tags
    case category
  }
}

struct InformationItem: Codable, Identifiable, Equatable {
  let header: String
  let content: String

  // 为了符合Identifiable协议
  var id: String {
    return header
  }
}

// MARK: - Schedule 模型
struct ScheduleResponse: Codable, Equatable {
  let title: String
  let category: String
  let tasks: [ScheduleTask]
  let id: String
  let text: String
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
  let id: Int

  enum CodingKeys: String, CodingKey {
    case startTime = "start_time"
    case endTime = "end_time"
    case people
    case theme
    case coreTasks = "core_tasks"
    case position
    case tags
    case category
    case suggestedActions = "suggested_actions"
    case id
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
    tags.formUnion(knowledge.tags)
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

// MARK: - 示例用法和测试数据
extension APIResponse {
  /// 创建示例数据用于预览和测试
  static var sampleData: APIResponse {
    return APIResponse(
      knowledge: KnowledgeResponse(
        title: "示例知识标题",
        knowledgeItems: [
          KnowledgeItem(
            id: 1,
            header: "示例标题",
            content: "示例内容",
            node: nil
          )
        ],
        relatedItems: [],
        tags: ["示例", "测试"],
        category: "{}"
      ),
      information: InformationResponse(
        title: "示例信息标题",
        informationItems: [
          InformationItem(
            header: "示例信息",
            content: "示例信息内容"
          )
        ],
        postType: "示例类型",
        summary: "示例摘要",
        tags: ["信息", "测试"],
        category: "{}"
      ),
      schedule: ScheduleResponse(
        title: "示例日程标题",
        category: "示例分类",
        tasks: [
          ScheduleTask(
            startTime: "2024-05-16T09:00:00+08:00",
            endTime: "2024-05-16T17:00:00+08:00",
            people: [],
            theme: "示例主题",
            coreTasks: ["示例任务"],
            position: [],
            tags: ["示例"],
            category: "示例分类",
            suggestedActions: ["示例行动"],
            id: 0
          )
        ],
        id: "sample-id",
        text: "{}"
      ),
      mostPossibleCategory: "information"
    )
  }
}
