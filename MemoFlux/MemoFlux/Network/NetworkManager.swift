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
  
  // API配置
  private let baseURL = SecureConfig.baseURL!
  private let apiToken = ""  // 不再需要，但先暂时留空备用
  
  private let session: URLSession
  
  private init() {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 30.0
    config.timeoutIntervalForResource = 60.0
    self.session = URLSession(configuration: config)
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
    isImage: Bool = false
  ) async throws -> APIResponse {
    guard let url = URL(string: "\(baseURL)/GeneralReq/") else {
      throw NetworkError.invalidURL
    }
    
    let request = AIGenerationRequest(
      tags: tags,
      content: content,
      isimage: isImage ? 1 : 0
    )
    
    return try await performRequest(url: url, requestBody: request)
  }

  /// 从MemoItemModel生成AI响应（异步版本）
  /// - Parameters:
  ///   - memoItem: Memo item
  ///   - allTags: 所有可用标签
  /// - Returns: API响应
  @available(iOS 15.0, *)
  func requestAIResponse(
    from memoItem: MemoItemModel,
    allTags: [String]
  ) async throws -> APIResponse {
    // 如果有图片，使用Base64编码发送
    if let image = memoItem.image {
      return try await generateFromImageBase64(image: image, tags: allTags)
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
      isImage: false
    )
  }
  
  // MARK: - Private Methods
  
  @available(iOS 15.0, *)
  private func performRequest<T: Codable>(
    url: URL,
    requestBody: T
  ) async throws -> APIResponse {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    // request.addValue(apiToken, forHTTPHeaderField: "Authorization")
    
    let jsonData: Data
    do {
      jsonData = try JSONEncoder().encode(requestBody)
      request.httpBody = jsonData
      
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        print("🚀 发送请求到: \(url)")
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
        print("📥 收到响应: \(jsonString)")
      }
      
      do {
        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
        return apiResponse
      } catch {
        print("❌ 解析错误: \(error)")
        throw NetworkError.decodingError(error)
      }
      
    } catch let error as NetworkError {
      throw error
    } catch {
      throw NetworkError.networkError(error)
    }
  }
}
