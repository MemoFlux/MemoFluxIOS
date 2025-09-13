//
//  MemoItemModel.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import CryptoKit
import Foundation
import SwiftData
import SwiftUI

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
  func setAPIResponse(_ response: MemoItemModel.APIResponse, in modelContext: ModelContext) {
    do {
      self.apiResponseData = try JSONEncoder().encode(response)
      self.hasAPIResponse = true
      self.isAPIProcessing = false
      self.apiProcessedAt = Date()
      
      // 创建ScheduleTaskModel对象
      self.createScheduleTasks(from: response.schedule.tasks, in: modelContext)
    } catch {
      print("保存API响应失败: \(error)")
      self.isAPIProcessing = false
    }
  }
  
  /// 从ScheduleTask创建ScheduleTaskModel
  private func createScheduleTasks(from tasks: [ScheduleTask], in modelContext: ModelContext) {
    // 删除现有的关联任务
    let memoItemId = self.id
    let existingTasks = try? modelContext.fetch(
      FetchDescriptor<ScheduleTaskModel>(
        predicate: #Predicate<ScheduleTaskModel> { task in
          task.memoItemId == memoItemId
        }
      ))
    existingTasks?.forEach { modelContext.delete($0) }
    
    // 创建新任务
    for task in tasks {
      print("🔧 创建ScheduleTaskModel: 原始ID=\(task.id)")
      let scheduleTaskModel = ScheduleTaskModel(
        id: task.id,
        startTime: task.startTime,
        endTime: task.endTime,
        people: task.people,
        theme: task.theme,
        coreTasks: task.coreTasks,
        position: task.position,
        tags: task.tags,
        category: task.category,
        suggestedActions: task.suggestedActions,
        status: ScheduleTaskModel.TaskStatus(rawValue: task.taskStatus.rawValue) ?? .pending,
        memoItemId: self.id
      )
      print("🔧 ScheduleTaskModel创建后ID=\(scheduleTaskModel.id)")
      modelContext.insert(scheduleTaskModel)
      print("🔧 插入数据库后ID=\(scheduleTaskModel.id)")
    }
  }
  
  /// 获取关联的任务
  func getScheduleTasks(from modelContext: ModelContext) -> [ScheduleTaskModel] {
    do {
      let memoItemId = self.id
      let tasks = try modelContext.fetch(
        FetchDescriptor<ScheduleTaskModel>(
          predicate: #Predicate<ScheduleTaskModel> { task in
            task.memoItemId == memoItemId
          }
        ))
      return tasks
    } catch {
      print("获取任务失败: \(error)")
      return []
    }
  }
  
  /// 更新任务状态 - 使用索引匹配而非ID匹配
  func updateTaskStatus(
    taskId: UUID, status: ScheduleTaskModel.TaskStatus, in modelContext: ModelContext
  ) {
    do {
      let memoItemId = self.id
      print("🔍 查找任务: taskId=\(taskId), memoItemId=\(memoItemId)")
      
      // 获取所有相关的任务
      let allTasks = try modelContext.fetch(
        FetchDescriptor<ScheduleTaskModel>(
          predicate: #Predicate<ScheduleTaskModel> { task in
            task.memoItemId == memoItemId
          }
        ))
      print("📋 找到 \(allTasks.count) 个相关任务")
      
      // 获取内存中的ScheduleTask列表
      guard var apiResponse = self.apiResponse else {
        print("❌ 无法获取API响应数据")
        return
      }
      
      // 通过taskId在ScheduleTask中找到对应的索引
      var targetIndex: Int? = nil
      for (index, task) in apiResponse.schedule.tasks.enumerated() {
        print("  内存任务\(index): id=\(task.id), status=\(task.taskStatus)")
        if task.id == taskId {
          targetIndex = index
          break
        }
      }
      
      guard let index = targetIndex else {
        print("❌ 在内存中未找到ID为 \(taskId) 的任务")
        return
      }
      
      // 确保数据库中有对应索引的任务
      guard index < allTasks.count else {
        print("❌ 数据库任务数量(\(allTasks.count))小于目标索引(\(index))")
        return
      }
      
      // 更新数据库中对应索引的任务
      let targetTask = allTasks[index]
      print("✅ 找到对应任务，修改前状态: \(targetTask.taskStatus)")
      targetTask.taskStatus = status
      try modelContext.save()
      print("✅ 数据库任务状态已更新: \(targetTask.taskStatus)")
      
      // 同时更新内存中的ScheduleTask状态
      apiResponse.schedule.tasks[index].taskStatus =
      ScheduleTask.TaskStatus(rawValue: status.rawValue) ?? .pending
      self.apiResponseData = try JSONEncoder().encode(apiResponse)
      print("✅ 内存任务状态已同步更新")
      
    } catch {
      print("❌ 更新任务状态失败: \(error)")
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
  
  // MARK: - 嵌套模型 - 主响应模型
  struct APIResponse: Codable, Equatable {
    let mostPossibleCategory: String
    let information: Information
    var schedule: Schedule
    
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
    var tasks: [ScheduleTask]
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
    
    // 任务状态枚举
    enum TaskStatus: String, Codable {
      case pending = "待处理"
      case completed = "已处理"
      case ignored = "已忽略"
    }
    
    // 任务状态，默认为待处理
    var taskStatus: TaskStatus = .pending
    
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
      case status
      case id
    }
    
    // 自定义初始化器，尝试解码ID或生成稳定ID
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
      // 尝试解码状态，如果不存在则默认为待处理
      taskStatus = try container.decodeIfPresent(TaskStatus.self, forKey: .status) ?? .pending
      
      // 尝试解码ID，如果不存在则基于内容生成稳定的UUID
      if let existingId = try container.decodeIfPresent(UUID.self, forKey: .id) {
        id = existingId
      } else {
        // 基于任务内容生成稳定的UUID
        let contentString = "\(startTime)-\(endTime)-\(theme)-\(category)"
        id = UUID(uuidString: contentString.sha256UUID) ?? UUID()
      }
    }
    
    // 编码时包含id字段以保持一致性
    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(startTime, forKey: .startTime)
      try container.encode(endTime, forKey: .endTime)
      try container.encode(people, forKey: .people)
      try container.encode(theme, forKey: .theme)
      try container.encode(coreTasks, forKey: .coreTasks)
      try container.encode(position, forKey: .position)
      try container.encode(id, forKey: .id)
      try container.encode(tags, forKey: .tags)
      try container.encode(category, forKey: .category)
      try container.encode(suggestedActions, forKey: .suggestedActions)
      try container.encode(taskStatus, forKey: .status)
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
      status: TaskStatus = .pending,
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
      self.taskStatus = status
      self.id = id
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
    mutating func markAsPending() {
      taskStatus = .pending
      
    }
    
    /// 将任务标记为已处理
    mutating func markAsCompleted() {
      taskStatus = .completed
    }
    
    /// 将任务标记为已忽略
    mutating func markAsIgnored() {
      taskStatus = .ignored
    }
    
    /// 获取当前状态的显示文本
    var statusText: String {
      return taskStatus.rawValue
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

// MARK: - String扩展，用于生成稳定的UUID
extension String {
  /// 基于字符串内容生成稳定的UUID字符串
  var sha256UUID: String {
    let hash = SHA256.hash(data: Data(self.utf8))
    let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
    
    // 将SHA256哈希转换为UUID格式 (8-4-4-4-12)
    let uuidString = String(hashString.prefix(32))
    let formatted =
    "\(uuidString.prefix(8))-\(uuidString.dropFirst(8).prefix(4))-\(uuidString.dropFirst(12).prefix(4))-\(uuidString.dropFirst(16).prefix(4))-\(uuidString.dropFirst(20).prefix(12))"
    return formatted
  }
}
