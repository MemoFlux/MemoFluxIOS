//
//  APIResponseModels.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/25.
//

import Foundation

// MARK: - 主响应模型
struct APIResponse: Codable {
  let knowledge: KnowledgeResponse
  let information: InformationResponse
  let schedule: ScheduleResponse
}

// MARK: - Knowledge 模型
struct KnowledgeResponse: Codable {
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

struct KnowledgeItem: Codable, Identifiable {
  let id: Int
  let header: String
  let content: String
  let node: KnowledgeNode?
}

struct KnowledgeNode: Codable {
  let targetId: Int
  let relationship: String
  
  enum CodingKeys: String, CodingKey {
    case targetId = "targert_id" // JSON中是"targert_id"，拼写错误
    case relationship
  }
}

// MARK: - Information 模型
struct InformationResponse: Codable {
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

struct InformationItem: Codable, Identifiable {
  let header: String
  let content: String
  
  // 为了符合Identifiable协议
  var id: String {
    return header
  }
}

// MARK: - Schedule 模型
struct ScheduleResponse: Codable {
  let title: String
  let category: String
  let tasks: [ScheduleTask]
  let id: String
  let text: String
}

struct ScheduleTask: Codable, Identifiable {
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
      )
    )
  }
}
