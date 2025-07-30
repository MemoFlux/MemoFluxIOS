//
//  TagModel.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/30.
//

import Foundation
import SwiftData
import SwiftUI

/// 标签数据模型
@Model
final class TagModel: Identifiable {
  var id: UUID = UUID()
  var name: String = ""
  var createdAt: Date = Date()
  var lastUsedAt: Date = Date()
  var usageCount: Int = 0
  var color: String?  // 可选的标签颜色
  var category: String?  // 可选的标签分类
  
  init(name: String, color: String? = nil, category: String? = nil) {
    self.id = UUID()
    self.name = name
    self.createdAt = Date()
    self.lastUsedAt = Date()
    self.usageCount = 1
    self.color = color
    self.category = category
  }
  
  /// 更新标签使用信息
  func updateUsage() {
    self.lastUsedAt = Date()
    self.usageCount += 1
  }
}

/// 标签管理器
@Observable
class TagManager {
  static let shared = TagManager()
  
  private init() {}
  
  // MARK: - 标签操作方法
  
  /// 获取所有标签
  /// - Parameter modelContext: SwiftData模型上下文
  /// - Returns: 所有「标签」数组，按使用频率排序
  func getAllTags(from modelContext: ModelContext) -> [TagModel] {
    do {
      // FetchDescriptor 是 SwiftData 中用来指定“如何从模型中获取数据”的描述器
      let descriptor = FetchDescriptor<TagModel>(
        sortBy: [SortDescriptor(\.usageCount, order: .reverse)]
      )
      return try modelContext.fetch(descriptor)
    } catch {
      print("获取标签失败: \(error)")
      return []
    }
  }
  
  /// 获取所有标签名称（用于API请求）
  /// - Parameter modelContext: SwiftData模型上下文
  /// - Returns: 所有「标签名称」数组
  func getAllTagNames(from modelContext: ModelContext) -> [String] {
    return getAllTags(from: modelContext).map { $0.name }
  }
  
  /// 根据名称查找标签
  /// - Parameters:
  ///   - name: 标签名称
  ///   - modelContext: SwiftData模型上下文
  /// - Returns: 找到的标签，如果不存在则返回nil
  func findTag(by name: String, in modelContext: ModelContext) -> TagModel? {
    do {
      let descriptor = FetchDescriptor<TagModel>(
        predicate: #Predicate { $0.name == name }
      )
      return try modelContext.fetch(descriptor).first
    } catch {
      print("查找标签失败: \(error)")
      return nil
    }
  }
  
  /// 创建或更新标签
  /// - Parameters:
  ///   - name: 标签名称
  ///   - modelContext: SwiftData模型上下文
  ///   - color: 可选的标签颜色
  ///   - category: 可选的标签分类
  /// - Returns: 创建或找到的标签
  @discardableResult
  func createOrUpdateTag(
    name: String,
    in modelContext: ModelContext,
    color: String? = nil,
    category: String? = nil
  ) -> TagModel {
    // 先查找是否已存在
    if let existingTag = findTag(by: name, in: modelContext) {
      existingTag.updateUsage()
      // 如果提供了新的颜色或分类，更新它们
      if let color = color {
        existingTag.color = color
      }
      if let category = category {
        existingTag.category = category
      }
      return existingTag
    } else {
      // 创建新标签
      let newTag = TagModel(name: name, color: color, category: category)
      modelContext.insert(newTag)
      return newTag
    }
  }
  
  /// 批量创建或更新标签
  /// - Parameters:
  ///   - names: 标签名称数组
  ///   - modelContext: SwiftData模型上下文
  /// - Returns: 创建或找到的标签数组
  @discardableResult
  func createOrUpdateTags(names: [String], in modelContext: ModelContext) -> [TagModel] {
    return names.map { name in
      createOrUpdateTag(name: name, in: modelContext)
    }
  }
  
  /// 删除标签
  /// - Parameters:
  ///   - tag: 要删除的标签
  ///   - modelContext: SwiftData模型上下文
  func deleteTag(_ tag: TagModel, from modelContext: ModelContext) {
    modelContext.delete(tag)
  }
  
  /// 获取最常用的标签
  /// - Parameters:
  ///   - limit: 返回的标签数量限制
  ///   - modelContext: SwiftData模型上下文
  /// - Returns: 最常用的标签数组
  func getMostUsedTags(limit: Int = 10, from modelContext: ModelContext) -> [TagModel] {
    let allTags = getAllTags(from: modelContext)
    return Array(allTags.prefix(limit))
  }
  
  /// 获取最近使用的标签
  /// - Parameters:
  ///   - limit: 返回的标签数量限制
  ///   - modelContext: SwiftData模型上下文
  /// - Returns: 最近使用的标签数组
  func getRecentlyUsedTags(limit: Int = 10, from modelContext: ModelContext) -> [TagModel] {
    do {
      let descriptor = FetchDescriptor<TagModel>(
        sortBy: [SortDescriptor(\.lastUsedAt, order: .reverse)]
      )
      let tags = try modelContext.fetch(descriptor)
      return Array(tags.prefix(limit))
    } catch {
      print("获取最近使用标签失败: \(error)")
      return []
    }
  }
  
  /// 搜索标签
  /// - Parameters:
  ///   - query: 搜索关键词
  ///   - modelContext: SwiftData模型上下文
  /// - Returns: 匹配的标签数组
  func searchTags(query: String, in modelContext: ModelContext) -> [TagModel] {
    guard !query.isEmpty else { return getAllTags(from: modelContext) }
    
    do {
      let descriptor = FetchDescriptor<TagModel>(
        predicate: #Predicate { tag in
          tag.name.localizedStandardContains(query)
        },
        sortBy: [SortDescriptor(\.usageCount, order: .reverse)]
      )
      return try modelContext.fetch(descriptor)
    } catch {
      print("搜索标签失败: \(error)")
      return []
    }
  }
  
  /// 清理未使用的标签（可选功能）
  /// - Parameter modelContext: SwiftData模型上下文
  func cleanupUnusedTags(from modelContext: ModelContext) {
    // 获取所有Memo中使用的标签
    do {
      let memoDescriptor = FetchDescriptor<MemoItemModel>()
      let memos = try modelContext.fetch(memoDescriptor)
      let usedTagNames = Set(memos.flatMap { $0.tags })
      
      // 获取所有标签
      let allTags = getAllTags(from: modelContext)
      
      // 删除未使用的标签
      for tag in allTags {
        if !usedTagNames.contains(tag.name) {
          modelContext.delete(tag)
        }
      }
      
      try modelContext.save()
    } catch {
      print("清理未使用标签失败: \(error)")
    }
  }
}

// MARK: - MemoItemModel 扩展
extension MemoItemModel {
  /// 同步标签到TagModel
  /// - Parameter modelContext: SwiftData模型上下文
  func syncTagsToTagModel(in modelContext: ModelContext) {
    TagManager.shared.createOrUpdateTags(names: self.tags, in: modelContext)
    
    // 保存更改
    do {
      try modelContext.save()
    } catch {
      print("同步标签到TagModel失败: \(error)")
    }
  }
}

// MARK: - NetworkManager 扩展更新
extension NetworkManager {
  /// 从TagModel获取所有标签名称（替代原有方法）
  /// - Parameter modelContext: SwiftData模型上下文
  /// - Returns: 所有标签名称的数组
  func getAllTagsFromTagModel(from modelContext: ModelContext) -> [String] {
    return TagManager.shared.getAllTagNames(from: modelContext)
  }
}
