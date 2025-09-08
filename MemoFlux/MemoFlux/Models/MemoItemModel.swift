//
//  MemoItemModel.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import Foundation
import SwiftData
import SwiftUI
import UIKit

/// 首页 List cell 中 item 的数据模型
@Model
final class MemoItemModel: Identifiable {
  var id: UUID = UUID()
  var imageData: Data?  // 存储图片
  var recognizedText: String = ""
  var userInputText: String = ""
  var title: String = ""
  var tags: [String] = []
  var createdAt: Date = Date()
  var scheduledDate: Date?
  var source: String = ""  // 数据来源（快捷指令/手动添加）
  
  // API响应相关字段
  var apiResponseData: Data?  // 存储API响应的JSON数据
  var isAPIProcessing: Bool = false  // 是否正在处理API请求
  var apiProcessedAt: Date?  // API处理完成时间
  var hasAPIResponse: Bool = false  // 是否有API响应
  
  var image: UIImage? {
    if let imageData = imageData {
      return UIImage(data: imageData)
    }
    return nil
  }
  
  // 获取API响应
  var apiResponse: MemoItemModel.APIResponse? {
    guard let apiResponseData = apiResponseData else { return nil }
    return try? JSONDecoder().decode(MemoItemModel.APIResponse.self, from: apiResponseData)
  }
  
  // 获取Information响应
  var information: Information? {
    return apiResponse?.information
  }
  
  // 获取Schedule响应
  var schedule: Schedule? {
    return apiResponse?.schedule
  }
  
  init(image: UIImage, title: String = "", tags: [String], source: String = "") {
    self.id = UUID()
    self.imageData = image.pngData()  // 将UIImage转换为Data类型存储，避免swiftData无法存储UIImage的问题
    self.recognizedText = ""
    self.title = title
    self.tags = tags
    self.createdAt = Date()
    self.scheduledDate = nil
    self.source = source
    self.apiResponseData = nil
    self.isAPIProcessing = false
    self.apiProcessedAt = nil
    self.hasAPIResponse = false
  }
  
  // 初始化，用于swiftData
  init(
    id: UUID = UUID(),
    imageData: Data? = nil,
    recognizedText: String = "",
    userInputText: String = "",
    title: String = "",
    tags: [String],
    createdAt: Date = Date(),
    scheduledDate: Date? = nil,
    source: String = "",
    apiResponseData: Data? = nil,
    isAPIProcessing: Bool = false,
    apiProcessedAt: Date? = nil,
    hasAPIResponse: Bool = false
  ) {
    self.id = id
    self.imageData = imageData
    self.recognizedText = recognizedText
    self.userInputText = userInputText
    self.title = title
    self.tags = tags
    self.createdAt = createdAt
    self.scheduledDate = scheduledDate
    self.source = source
    self.apiResponseData = apiResponseData
    self.isAPIProcessing = isAPIProcessing
    self.apiProcessedAt = apiProcessedAt
    self.hasAPIResponse = hasAPIResponse
  }
  
  /// API响应
  func setAPIResponse(_ response: MemoItemModel.APIResponse) {
    do {
      self.apiResponseData = try JSONEncoder().encode(response)
      self.hasAPIResponse = true
      self.isAPIProcessing = false
      self.apiProcessedAt = Date()
    } catch {
      print("保存API响应失败: \(error)")
      self.isAPIProcessing = false
    }
  }
  
  func startAPIProcessing() {
    self.isAPIProcessing = true
    self.hasAPIResponse = false
    self.apiProcessedAt = nil
  }
  
  func apiProcessingFailed() {
    self.isAPIProcessing = false
    self.hasAPIResponse = false
  }
  
  var contentForAPI: String {
    if !title.isEmpty && !recognizedText.isEmpty {
      return "\(title)\n\n\(recognizedText)"
    } else if !title.isEmpty {
      return title
    } else {
      return recognizedText
    }
  }
  
  // 判断两个MemoItem是否相同
  static func areEqual(_ lhs: MemoItemModel, _ rhs: MemoItemModel) -> Bool {
    if lhs.id == rhs.id {
      return true
    }
    
    if lhs.imageData == rhs.imageData {
      return true
    }
    
    return false
  }
  
  /// 设置标签并同步到TagModel
  /// - Parameters:
  ///   - newTags: 新的标签数组
  ///   - modelContext: SwiftData模型上下文
  func setTags(_ newTags: [String], in modelContext: ModelContext) {
    self.tags = newTags
    syncTagsToTagModel(in: modelContext)
  }
  
  /// 添加标签并同步到TagModel
  /// - Parameters:
  ///   - tag: 要添加的标签
  ///   - modelContext: SwiftData模型上下文
  func addTag(_ tag: String, in modelContext: ModelContext) {
    if !self.tags.contains(tag) {
      self.tags.append(tag)
      syncTagsToTagModel(in: modelContext)
    }
  }
  
  /// 移除标签
  /// - Parameter tag: 要移除的标签
  func removeTag(_ tag: String) {
    self.tags.removeAll { $0 == tag }
  }
  
  // MARK: - 嵌套模型
  
  // MARK: - 主响应模型
  struct APIResponse: Codable, Equatable {
    let mostPossibleCategory: String
    let information: Information
    let schedule: Schedule
    
    enum CodingKeys: String, CodingKey {
      case mostPossibleCategory
      case information
      case schedule
    }
    
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
  
  // MARK: - Information 模型
  struct Information: Codable, Equatable {
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
  struct Schedule: Codable, Equatable {
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
}

// MARK: - 类型别名
typealias APIResponse = MemoItemModel.APIResponse
typealias Information = MemoItemModel.Information
typealias InformationItem = MemoItemModel.InformationItem
typealias InformationNode = MemoItemModel.InformationNode
typealias Schedule = MemoItemModel.Schedule
typealias ScheduleTask = MemoItemModel.ScheduleTask
