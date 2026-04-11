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

  /// 从文本内容生成 AI 响应（文本仍走后端服务）
  @available(iOS 15.0, *)
  func generateFromText(
    _ text: String,
    tags: [String],
    model _: AIModelProfile = AIModelStore.shared.selectedModel
  ) async throws -> APIResponse {
    try await requestAIResponse(content: text, tags: tags, isImage: false)
  }

  /// 从图片识别文本生成 AI 响应（OCR 文本仍走后端服务）
  @available(iOS 15.0, *)
  func generateFromImage(
    recognizedText: String,
    tags: [String],
    model _: AIModelProfile = AIModelStore.shared.selectedModel
  ) async throws -> APIResponse {
    try await requestAIResponse(content: recognizedText, tags: tags, isImage: false)
  }

  /// 图片直连阿里百炼视觉模型
  @available(iOS 15.0, *)
  func requestBailianImageResponse(
    image: UIImage,
    config: ImageProcessor.CompressionConfig = .highQuality,
    tags: [String]
  ) async throws -> APIResponse {
    let retryConfigs = deduplicatedConfigs(startingWith: config)
    var lastError: Error?

    for (index, currentConfig) in retryConfigs.enumerated() {
      do {
        let base64String = try await compressImageToBase64(image: image, config: currentConfig)
        print(
          "🖼️ Bailian image attempt \(index + 1)/\(retryConfigs.count) " +
          "size=\(Int(currentConfig.maxWidth))x\(Int(currentConfig.maxHeight)) " +
          "quality=\(currentConfig.compressionQuality) " +
          "base64Chars=\(base64String.count)"
        )

        return try await BailianChatClient.shared.analyzeImage(
          imageBase64: base64String,
          tags: tags
        )
      } catch {
        lastError = error

        guard isTimeoutError(error), index < retryConfigs.count - 1 else {
          throw error
        }

        print("⏳ Bailian image attempt timed out, retrying with smaller image…")
      }
    }

    throw lastError ?? NetworkError.networkError(
      NSError(
        domain: "ImageProcessing",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "图片处理失败"]
      )
    )
  }

  /// 兼容旧调用点的包装器；实际已切换为百炼图片直连。
  @available(iOS 15.0, *)
  func generateFromImageBase64(
    image: UIImage,
    supplementaryText _: String? = nil,
    config: ImageProcessor.CompressionConfig = .highQuality,
    tags: [String],
    model _: AIModelProfile = AIModelStore.shared.selectedModel
  ) async throws -> APIResponse {
    try await requestBailianImageResponse(image: image, config: config, tags: tags)
  }

  private func compressImageToBase64(
    image: UIImage,
    config: ImageProcessor.CompressionConfig
  ) async throws -> String {
    try await withCheckedThrowingContinuation { continuation in
      ImageProcessor.shared.compressAndEncodeToBase64Async(image: image, config: config) { base64String in
        guard let base64String else {
          continuation.resume(throwing: NetworkError.networkError(
            NSError(
              domain: "ImageProcessing",
              code: -1,
              userInfo: [NSLocalizedDescriptionKey: "图片处理失败"]
            )
          ))
          return
        }

        continuation.resume(returning: base64String)
      }
    }
  }

  private func deduplicatedConfigs(
    startingWith initialConfig: ImageProcessor.CompressionConfig
  ) -> [ImageProcessor.CompressionConfig] {
    let configs = [
      initialConfig,
      .bailianOptimized,
      .bailianFallback,
      .lowQuality
    ]

    var seen = Set<String>()
    return configs.filter { config in
      let key = "\(config.maxWidth)x\(config.maxHeight)-\(config.compressionQuality)"
      return seen.insert(key).inserted
    }
  }

  private func isTimeoutError(_ error: Error) -> Bool {
    if let urlError = error as? URLError {
      return urlError.code == .timedOut
    }

    if let networkError = error as? NetworkError,
       case .networkError(let wrappedError) = networkError {
      return isTimeoutError(wrappedError)
    }

    let nsError = error as NSError
    return nsError.domain == NSURLErrorDomain && nsError.code == URLError.timedOut.rawValue
  }

  // MARK: - SwiftData 集成

  func getAllTags(from modelContext: ModelContext) -> [String] {
    TagManager.shared.getAllTagNames(from: modelContext)
  }

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

  /// 为现有的 MemoItem 触发 API 分析（异步版本）
  @available(iOS 15.0, *)
  func triggerAPIAnalysis(
    for memoItem: MemoItemModel,
    modelContext: ModelContext
  ) async throws -> APIResponse {
    guard !memoItem.isAPIProcessing else {
      throw NetworkError.networkError(
        NSError(
          domain: "APIProcessing",
          code: -1,
          userInfo: [NSLocalizedDescriptionKey: "API请求正在处理中"]
        )
      )
    }

    memoItem.startAPIProcessing()

    do {
      try modelContext.save()
    } catch {
      print("更新API处理状态失败: \(error)")
    }

    let allTags = getAllTags(from: modelContext)

    do {
      let response = try await requestAIResponse(from: memoItem, allTags: allTags)

      await MainActor.run {
        memoItem.setAPIResponse(response, in: modelContext)

        let newTags = Set(memoItem.tags)
          .union(response.information.tags)
          .union(response.schedule.tasks.flatMap { $0.tags })
        memoItem.tags = Array(newTags)

        memoItem.syncTagsToTagModel(in: modelContext)

        if memoItem.title.isEmpty, let preferredTitle = response.preferredDisplayTitle {
          memoItem.title = preferredTitle
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
