//
//  NetworkManager.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import Foundation
import SwiftData

/// 网络请求管理器
class NetworkManager: ObservableObject {
  static let shared = NetworkManager()
  
  private init() {
  }
  
  // MARK: - 发送AI生成请求

  /// 发送AI生成请求（异步版本）
  /// - Parameters:
  ///   - content: 文本内容
  ///   - tags: 标签数组
  ///   - isImage: 是否为图片 (0: 文本, 1: 图片)
  /// - Returns: API响应
  @available(iOS 15.0, *)
  func requestAIResponse(
    content: String,
    tags: [String],
    isImage: Bool = false,
    model: AIModelProfile = AIModelStore.shared.selectedModel
  ) async throws -> APIResponse {
    return try await ArkChatClient.shared.analyzeContent(
      text: isImage ? nil : content,
      imageBase64: isImage ? content : nil,
      serviceConfiguration: model.serviceConfiguration,
      tags: tags
    )
  }

  /// 从MemoItemModel生成AI响应（异步版本）
  /// - Parameters:
  ///   - memoItem: Memo item
  ///   - allTags: 所有可用标签
  /// - Returns: API响应
  @available(iOS 15.0, *)
  func requestAIResponse(
    from memoItem: MemoItemModel,
    allTags: [String],
    model: AIModelProfile = AIModelStore.shared.selectedModel
  ) async throws -> APIResponse {
    if let image = memoItem.image {
      return try await generateFromImageBase64(
        image: image,
        supplementaryText: supplementaryTextForImageAnalysis(from: memoItem),
        tags: allTags,
        model: model
      )
    }
    
    // 无图片时使用文本内容
    let content = memoItem.contentForAPI
    
    // 如果内容为空，返回错误
    guard !content.isEmpty else {
      throw NetworkError.networkError(
        NSError(
          domain: "ContentEmpty", code: -1, userInfo: [NSLocalizedDescriptionKey: "内容为空，无法发送请求"]
        ))
    }
    
    return try await requestAIResponse(
      content: content,
      tags: allTags,
      isImage: false,
      model: model
    )
  }
}

private extension NetworkManager {
  func supplementaryTextForImageAnalysis(from memoItem: MemoItemModel) -> String? {
    let segments = [
      memoItem.title,
      memoItem.userInputText
    ]
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
    
    guard !segments.isEmpty else { return nil }
    return segments.joined(separator: "\n\n")
  }
}
