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
  let schedule: ScheduleResponse
  let knowledge: KnowledgeResponse
  
  enum CodingKeys: String, CodingKey {
    case mostPossibleCategory
    case schedule
    case knowledge
  }
}

// MARK: - Knowledge 模型
struct KnowledgeResponse: Codable, Equatable {
  let title: String
  let knowledgeItems: [KnowledgeItem]
  let relatedItems: [String]
  let summary: String
  let tags: [String]
  
  enum CodingKeys: String, CodingKey {
    case title
    case knowledgeItems
    case relatedItems
    case summary
    case tags
  }
}

struct KnowledgeItem: Codable, Identifiable, Equatable {
  let id: Int
  let header: String
  let content: String
  let node: KnowledgeNode?
}

struct KnowledgeNode: Codable, Equatable {
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
  
  // 为了符合Identifiable协议，使用startTime作为id
  var id: String {
    return startTime
  }
  
  enum CodingKeys: String, CodingKey {
    case startTime
    case endTime
    case people
    case theme
    case coreTasks
    case position
    case tags
    case category
    case suggestedActions
  }
  
  // 将字符串时间转换为Date
  var startDate: Date? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.date(from: startTime)
  }
  
  var endDate: Date? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.date(from: endTime)
  }
}

// MARK: - 扩展
extension APIResponse {
  /// 获取所有任务的标签
  var allTags: Set<String> {
    var tags = Set<String>()
    tags.formUnion(knowledge.tags)
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
      mostPossibleCategory: "INFORMATION",
      schedule: ScheduleResponse(
        title: "中国铁路消费记录",
        category: "消费",
        tasks: [
          ScheduleTask(
            startTime: "2025-07-20T15:58:58+08:00",
            endTime: "2025-07-20T15:58:58+08:00",
            people: [],
            theme: "消费记录",
            coreTasks: [
              "查看交易详情",
              "记录消费金额",
            ],
            position: [],
            tags: [
              "消费",
              "铁路",
              "2025年",
            ],
            category: "消费",
            suggestedActions: [
              "核对消费金额是否正确",
              "如需投诉或查询，可联系财付通支付科技有限公司",
            ]
          )
        ]
      ),
      knowledge: KnowledgeResponse(
        title: "交易详情",
        knowledgeItems: [
          KnowledgeItem(
            id: 1,
            header: "交易状态",
            content: "Payment successful",
            node: KnowledgeNode(targetId: 1, relationship: "PARENT")
          ),
          KnowledgeItem(
            id: 2,
            header: "支付时间",
            content: "2025/7/20 15:58:58",
            node: KnowledgeNode(targetId: 1, relationship: "CHILD")
          ),
          KnowledgeItem(
            id: 3,
            header: "产品",
            content: "12306消费",
            node: KnowledgeNode(targetId: 1, relationship: "CHILD")
          ),
          KnowledgeItem(
            id: 4,
            header: "商户",
            content: "中国铁路网络有限公司",
            node: KnowledgeNode(targetId: 5, relationship: "PARENT")
          ),
          KnowledgeItem(
            id: 5,
            header: "收单机构",
            content: "财付通支付科技有限公司",
            node: KnowledgeNode(targetId: 1, relationship: "CHILD")
          ),
          KnowledgeItem(
            id: 6,
            header: "支付方式",
            content: "Balance",
            node: KnowledgeNode(targetId: 1, relationship: "CHILD")
          ),
          KnowledgeItem(
            id: 7,
            header: "交易订单号",
            content: "4200002772202507201236367735",
            node: KnowledgeNode(targetId: 1, relationship: "CHILD")
          ),
          KnowledgeItem(
            id: 8,
            header: "商户订单号",
            content: "M2025072073510186",
            node: KnowledgeNode(targetId: 1, relationship: "CHILD")
          ),
          KnowledgeItem(
            id: 9,
            header: "交易金额",
            content: "-128.00",
            node: KnowledgeNode(targetId: 1, relationship: "CHILD")
          ),
          KnowledgeItem(
            id: 10,
            header: "交易服务",
            content: "可进行可疑交易报告和发起分账。",
            node: KnowledgeNode(targetId: 1, relationship: "CHILD")
          ),
        ],
        relatedItems: [
          "中国铁路",
          "12306",
          "交易记录",
        ],
        summary: "本次交易于2025年7月20日15:58:58完成，金额为-128.00，支付方式为余额，交易商户是中国铁路网络有限公司，收单机构为财付通支付科技有限公司。",
        tags: [
          "交易",
          "支付",
          "中国铁路",
        ]
      )
    )
  }
}
