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
  
  /// 从文本内容生成AI响应（异步版本）
  /// - Parameters:
  ///   - text: 文本内容
  ///   - tags: 要传入的标签
  /// - Returns: API响应
  @available(iOS 15.0, *)
  func generateFromText(
    _ text: String,
    tags: [String]
  ) async throws -> APIResponse {
    return try await requestAIResponse(content: text, tags: tags, isImage: false)
  }

  /// 从图片识别文本生成AI响应（异步版本）
  /// - Parameters:
  ///   - recognizedText: 图片识别的文本
  ///   - tags: 要传入的标签
  /// - Returns: API响应
  @available(iOS 15.0, *)
  func generateFromImage(
    recognizedText: String,
    tags: [String]
  ) async throws -> APIResponse {
    // 发送识别出的文本内容，isImage 设置为 false
    return try await requestAIResponse(content: recognizedText, tags: tags, isImage: false)
  }

  /// 从图片Base64编码生成AI响应（异步版本）
  /// - Parameters:
  ///   - image: 原始图片
  ///   - config: 图片压缩配置
  ///   - tags: 要传入的标签
  /// - Returns: API响应
  @available(iOS 15.0, *)
  func generateFromImageBase64(
    image: UIImage,
    config: ImageProcessor.CompressionConfig = .highQuality,
    tags: [String]
  ) async throws -> APIResponse {
    // 异步处理图片压缩和编码
    return try await withCheckedThrowingContinuation { continuation in
      ImageProcessor.shared.compressAndEncodeToBase64Async(image: image, config: config) {
        base64String in
        guard let base64String = base64String else {
          continuation.resume(throwing: NetworkError.networkError(
            NSError(
              domain: "ImageProcessing", code: -1, userInfo: [NSLocalizedDescriptionKey: "图片处理失败"]
            )))
          return
        }

        // 发送Base64编码的图片数据
        Task {
          do {
            let response = try await self.requestAIResponse(
              content: base64String, tags: tags, isImage: true
            )
            continuation.resume(returning: response)
          } catch {
            continuation.resume(throwing: error)
          }
        }
      }
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
}



// MARK: - MemoItem 处理扩展

extension NetworkManager {
  
  /// 为现有的MemoItem触发API分析（异步版本）
  /// - Parameters:
  ///   - memoItem: 要分析的备忘录项目
  ///   - modelContext: SwiftData模型上下文
  /// - Returns: API响应
  @available(iOS 15.0, *)
  func triggerAPIAnalysis(
    for memoItem: MemoItemModel,
    modelContext: ModelContext
  ) async throws -> APIResponse {
    guard !memoItem.isAPIProcessing else {
      throw NetworkError.networkError(
        NSError(
          domain: "APIProcessing", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "API请求正在处理中"]))
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

    do {
      // 发送API请求
      let response = try await requestAIResponse(from: memoItem, allTags: allTags)
      
      // 在主线程更新UI相关数据
      await MainActor.run {
        // 保存API响应到MemoItem
        memoItem.setAPIResponse(response, in: modelContext)

        // 更新标签（合并API返回的标签）
        let newTags = Set(memoItem.tags)
          .union(response.information.tags)
          .union(response.schedule.tasks.flatMap { $0.tags })
        memoItem.tags = Array(newTags)

        // 同步标签到TagModel
        memoItem.syncTagsToTagModel(in: modelContext)

        // 更新标题
        if memoItem.title.isEmpty && !response.schedule.title.isEmpty {
          memoItem.title = response.schedule.title
        }

        do {
          try modelContext.save()
        } catch {
          print("保存API响应失败: \(error)")
        }
      }
      
      return response
      
    } catch {
      await MainActor.run {
        memoItem.apiProcessingFailed()
        do {
          try modelContext.save()
        } catch {
          print("保存API处理失败状态失败: \(error)")
        }
      }
      throw error
    }
  }
}
