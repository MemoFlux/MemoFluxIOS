//
//  NetworkManager+Extensions.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import Foundation
import SwiftData
import UIKit

extension NetworkManager {
  
  /// 从文本内容生成AI响应
  /// - Parameters:
  ///   - text: 文本内容
  ///   - tags: 要传入的标签
  ///   - completion: 完成回调
  func generateFromText(
    _ text: String,
    tags: [String],
    completion: @escaping (Result<APIResponse, NetworkError>) -> Void
  ) {
    generateAIResponse(content: text, tags: tags, isImage: false, completion: completion)
  }
  
  /// 从图片识别文本生成AI响应
  /// - Parameters:
  ///   - recognizedText: 图片识别的文本
  ///   - tags: 要传入的标签
  ///   - completion: 完成回调
  func generateFromImage(
    recognizedText: String,
    tags: [String],
    completion: @escaping (Result<APIResponse, NetworkError>) -> Void
  ) {
    // 发送识别出的文本内容，isImage 设置为 false
    generateAIResponse(content: recognizedText, tags: tags, isImage: false, completion: completion)
  }
  
  /// 从图片Base64编码生成AI响应
  /// - Parameters:
  ///   - image: 原始图片
  ///   - config: 图片压缩配置
  ///   - tags: 要传入的标签
  ///   - completion: 完成回调
  func generateFromImageBase64(
    image: UIImage,
    config: ImageProcessor.CompressionConfig = .highQuality,
    tags: [String],
    completion: @escaping (Result<APIResponse, NetworkError>) -> Void
  ) {
    // 异步处理图片压缩和编码
    ImageProcessor.shared.compressAndEncodeToBase64Async(image: image, config: config) {
      base64String in
      guard let base64String = base64String else {
        completion(
          .failure(
            .networkError(
              NSError(
                domain: "ImageProcessing", code: -1, userInfo: [NSLocalizedDescriptionKey: "图片处理失败"]
              ))))
        return
      }
      
      // 发送Base64编码的图片数据
      self.generateAIResponse(content: base64String, tags: tags, isImage: true, completion: completion)
    }
  }
  
  // MARK: - SwiftData 集成
  
  /// 从 TagModel 获取所有 Tags（推荐使用）
  /// - Parameter modelContext: SwiftData 模型上下文
  /// - Returns: 所有标签名称的数组
  func getAllTags(from modelContext: ModelContext) -> [String] {
    return TagManager.shared.getAllTagNames(from: modelContext)
  }
  
  /// 从 MemoItemModel 获取所有 Tags（兼容性保留）
  /// - Parameter modelContext: SwiftData 模型上下文
  /// - Returns: 所有唯一标签的数组
  func getAllTagsFromMemos(from modelContext: ModelContext) -> [String] {
    do {
      let descriptor = FetchDescriptor<MemoItemModel>()
      let memoItems = try modelContext.fetch(descriptor)
      
      let allTags = memoItems.flatMap { $0.tags }
      return Array(Set(allTags)).sorted()
    } catch {
      print("获取标签失败: \(error)")
      return []
    }
  }
  
  /// 批量处理多个 MemoItem
  /// - Parameters:
  ///   - memoItems: Memo 数组
  ///   - modelContext: SwiftData 模型上下文
  ///   - completion: 完成回调，返回成功和失败的结果
  func batchGenerateAIResponses(
    for memoItems: [MemoItemModel],
    modelContext: ModelContext,
    completion: @escaping ([APIResponse], [NetworkError]) -> Void
  ) {
    let allTags = getAllTags(from: modelContext)
    var responses: [APIResponse] = []
    var errors: [NetworkError] = []
    let group = DispatchGroup()
    
    for memoItem in memoItems {
      group.enter()
      generateAIResponse(from: memoItem, allTags: allTags) { result in
        switch result {
        case .success(let response):
          responses.append(response)
        case .failure(let error):
          errors.append(error)
        }
        group.leave()
      }
    }
    
    group.notify(queue: .main) {
      completion(responses, errors)
    }
  }
}

// MARK: - 异步/await 支持

extension NetworkManager {
  
  /// 异步生成AI响应
  /// - Parameters:
  ///   - content: 文本内容
  ///   - tags: 标签数组
  ///   - isImage: 是否为图片
  /// - Returns: API响应
  @available(iOS 15.0, *)
  func generateAIResponse(
    content: String,
    tags: [String],
    isImage: Bool = false
  ) async throws -> APIResponse {
    return try await withCheckedThrowingContinuation { continuation in
      generateAIResponse(content: content, tags: tags, isImage: isImage) { result in
        switch result {
        case .success(let response):
          continuation.resume(returning: response)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// 异步从 MemoItemModel 生成 AI 响应
  /// - Parameters:
  ///   - memoItem: Memo Item
  ///   - allTags: 所有可用标签
  /// - Returns: API响应
  @available(iOS 15.0, *)
  func generateAIResponse(
    from memoItem: MemoItemModel,
    allTags: [String]
  ) async throws -> APIResponse {
    return try await withCheckedThrowingContinuation { continuation in
      generateAIResponse(from: memoItem, allTags: allTags) { result in
        switch result {
        case .success(let response):
          continuation.resume(returning: response)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}

// MARK: - 调试和测试支持

extension NetworkManager {
  
  /// 测试网络连接
  /// - Parameters:
  ///   - modelContext: SwiftData模型上下文（可选，用于获取现有标签）
  ///   - completion: 完成回调
  func testConnection(
    modelContext: ModelContext? = nil,
    completion: @escaping (Bool) -> Void
  ) {
    let allTags = modelContext != nil ? getAllTags(from: modelContext!) : []
    generateAIResponse(content: "测试连接", tags: allTags, isImage: false) { result in
      switch result {
      case .success:
        completion(true)
      case .failure:
        completion(false)
      }
    }
  }
  
  /// 创建示例请求用于测试
  /// - Returns: 示例请求数据
  func createSampleRequest() -> AIGenerationRequest {
    return AIGenerationRequest(
      tags: ["测试", "示例"],
      content: "这是一个测试请求",
      isimage: 0
    )
  }
}

// MARK: - MemoItem 处理扩展

extension NetworkManager {
  
  /// 为现有的MemoItem触发API分析
  /// - Parameters:
  ///   - memoItem: 要分析的备忘录项目
  ///   - modelContext: SwiftData模型上下文
  ///   - completion: 完成回调
  func triggerAPIAnalysis(
    for memoItem: MemoItemModel,
    modelContext: ModelContext,
    completion: @escaping (Result<APIResponse, NetworkError>) -> Void
  ) {
    guard !memoItem.isAPIProcessing else {
      completion(
        .failure(
          .networkError(
            NSError(
              domain: "APIProcessing", code: -1,
              userInfo: [NSLocalizedDescriptionKey: "API请求正在处理中"]))))
      return
    }
    
    // 标记开始API处理
    memoItem.startAPIProcessing()
    
    do {
      try modelContext.save()
    } catch {
      print("更新API处理状态失败: \(error)")
    }
    
    // 获取所有现有标签
    let allTags = getAllTags(from: modelContext)
    
    // 发送API请求
    generateAIResponse(from: memoItem, allTags: allTags) { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let response):
          // 保存API响应到MemoItem
          memoItem.setAPIResponse(response)
          
          // 更新标签（合并API返回的标签）
          let newTags = Set(memoItem.tags)
            .union(response.knowledge.tags)
            .union(response.schedule.tasks.flatMap { $0.tags })
          memoItem.tags = Array(newTags)
          
          // 同步标签到TagModel
          memoItem.syncTagsToTagModel(in: modelContext)
          
          // 更新标题
          if memoItem.title.isEmpty && !response.schedule.title.isEmpty {
            memoItem.title = response.schedule.title
          }
          
          completion(.success(response))
          
        case .failure(let error):
          memoItem.apiProcessingFailed()
          completion(.failure(error))
        }
        
        do {
          try modelContext.save()
        } catch {
          print("保存API响应失败: \(error)")
        }
      }
    }
  }
}
