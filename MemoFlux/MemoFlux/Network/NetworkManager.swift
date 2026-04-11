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

  // 文本解析仍然走现有后端服务。
  private let baseURL = SecureConfig.baseURL
  private let session: URLSession

  private init() {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 30.0
    configuration.timeoutIntervalForResource = 60.0
    session = URLSession(configuration: configuration)
  }

  // MARK: - 发送 AI 生成请求

  /// 发送 AI 生成请求（文本仍走后端服务）
  /// - Parameters:
  ///   - content: 文本内容
  ///   - tags: 标签数组
  ///   - isImage: 是否为图片 (0: 文本, 1: 图片)
  /// - Returns: API 响应
  @available(iOS 15.0, *)
  func requestAIResponse(
    content: String,
    tags: [String],
    isImage: Bool = false,
    model _: AIModelProfile = AIModelStore.shared.selectedModel
  ) async throws -> APIResponse {
    guard let baseURL, let url = URL(string: "\(baseURL)/GeneralReq/") else {
      throw NetworkError.invalidURL
    }

    let request = AIGenerationRequest(
      tags: tags,
      content: content,
      isimage: isImage ? 1 : 0
    )

    return try await performRequest(url: url, requestBody: request)
  }

  /// 从 MemoItemModel 生成 AI 响应（图片直连百炼，文本仍走后端）
  @available(iOS 15.0, *)
  func requestAIResponse(
    from memoItem: MemoItemModel,
    allTags: [String],
    model _: AIModelProfile = AIModelStore.shared.selectedModel
  ) async throws -> APIResponse {
    if let image = memoItem.image {
      return try await requestBailianImageResponse(image: image, tags: allTags)
    }

    let content = memoItem.contentForAPI

    guard !content.isEmpty else {
      throw NetworkError.networkError(
        NSError(
          domain: "ContentEmpty",
          code: -1,
          userInfo: [NSLocalizedDescriptionKey: "内容为空，无法发送请求"]
        )
      )
    }

    return try await requestAIResponse(
      content: content,
      tags: allTags,
      isImage: false
    )
  }

  // MARK: - Private Methods

  @available(iOS 15.0, *)
  private func performRequest<T: Encodable>(
    url: URL,
    requestBody: T
  ) async throws -> APIResponse {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let jsonData: Data
    do {
      jsonData = try JSONEncoder().encode(requestBody)
      request.httpBody = jsonData

      if let jsonString = String(data: jsonData, encoding: .utf8) {
        print("🚀 发送后端文本请求到: \(url)")
        print("📦 请求体: \(jsonString)")
      }
    } catch {
      throw NetworkError.decodingError(error)
    }

    do {
      let (data, response) = try await session.data(for: request)

      guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.noData
      }

      switch httpResponse.statusCode {
      case 200...299:
        break
      case 401:
        throw NetworkError.unauthorized
      default:
        throw NetworkError.serverError(httpResponse.statusCode)
      }

      if let jsonString = String(data: data, encoding: .utf8) {
        print("📥 收到后端文本响应: \(jsonString)")
      }

      do {
        return try JSONDecoder().decode(APIResponse.self, from: data)
      } catch {
        print("❌ 后端文本响应解析错误: \(error)")
        throw NetworkError.decodingError(error)
      }
    } catch let error as NetworkError {
      throw error
    } catch {
      throw NetworkError.networkError(error)
    }
  }
}
