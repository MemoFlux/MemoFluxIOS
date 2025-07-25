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
  private let baseURL = "http://localhost:8000"
  private let apiToken = "Bearer NkuxThqAzsfOucZgRDo1NZm-_VHHHsyeCLO1RH-ToJg "
  
  private let session: URLSession
  
  private init() {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 30.0
    config.timeoutIntervalForResource = 60.0
    self.session = URLSession(configuration: config)
  }
  
  // MARK: - AI生成请求
  
  /// 发送AI生成请求
  /// - Parameters:
  ///   - content: 文本内容
  ///   - tags: 标签数组
  ///   - isImage: 是否为图片 (0: 文本, 1: 图片)
  ///   - completion: 完成回调
  func generateAIResponse(
    content: String,
    tags: [String] = [],
    isImage: Bool = false,
    completion: @escaping (Result<APIResponse, NetworkError>) -> Void
  ) {
    guard let url = URL(string: "\(baseURL)/aigen/") else {
      completion(.failure(.invalidURL))
      return
    }
    
    let request = AIGenerationRequest(
      tags: tags,
      content: content,
      isimage: isImage ? 1 : 0
    )
    
    performRequest(url: url, requestBody: request, completion: completion)
  }
  
  /// 从MemoItemModel生成AI响应
  /// - Parameters:
  ///   - memoItem: Memo item
  ///   - allTags: 所有可用标签
  ///   - completion: 完成回调
  func generateAIResponse(
    from memoItem: MemoItemModel,
    allTags: [String] = [],
    completion: @escaping (Result<APIResponse, NetworkError>) -> Void
  ) {
    // 使用 contentForAPI 计算属性获取内容
    let content = memoItem.contentForAPI
    
    // 如果内容为空，延迟一段时间等待OCR识别完成
    if content.isEmpty && memoItem.image != nil {
      // 等待OCR识别完成后再发送请求
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        self.generateAIResponse(from: memoItem, allTags: allTags, completion: completion)
      }
      return
    }
    
    // 如果内容仍然为空，返回错误
    guard !content.isEmpty else {
      completion(.failure(.networkError(NSError(domain: "ContentEmpty", code: -1, userInfo: [NSLocalizedDescriptionKey: "内容为空，无法发送请求"]))))
      return
    }
    
    // 修复：无论是否有图片，都发送文本内容，isImage 设置为 false
    let isImage = false
    
    generateAIResponse(
      content: content,
      tags: allTags,
      isImage: isImage,
      completion: completion
    )
  }
  
  // MARK: - Private Methods
  
  private func performRequest<T: Codable>(
    url: URL,
    requestBody: T,
    completion: @escaping (Result<APIResponse, NetworkError>) -> Void
  ) {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(apiToken, forHTTPHeaderField: "Authorization")
    
    do {
      let jsonData = try JSONEncoder().encode(requestBody)
      request.httpBody = jsonData
      
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        print("🚀 发送请求到: \(url)")
        print("📦 请求体: \(jsonString)")
      }
      
    } catch {
      completion(.failure(.decodingError(error)))
      return
    }
    
    let task = session.dataTask(with: request) { data, response, error in
      DispatchQueue.main.async {
        if let error = error {
          completion(.failure(.networkError(error)))
          return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
          completion(.failure(.noData))
          return
        }
        
        switch httpResponse.statusCode {
        case 200...299:
          break
        case 401:
          completion(.failure(.unauthorized))
          return
        default:
          completion(.failure(.serverError(httpResponse.statusCode)))
          return
        }
        
        guard let data = data else {
          completion(.failure(.noData))
          return
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
          print("📥 收到响应: \(jsonString)")
        }
        
        do {
          let response = try JSONDecoder().decode(APIResponse.self, from: data)
          completion(.success(response))
        } catch {
          print("❌ 解析错误: \(error)")
          completion(.failure(.decodingError(error)))
        }
      }
    }
    
    task.resume()
  }
}
