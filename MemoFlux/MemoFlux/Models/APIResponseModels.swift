//
//  APIResponseModels.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/25.
//

import Foundation
import SwiftData

// MARK: - 请求模型
struct AIGenerationRequest: Codable {
  let tags: [String]
  let content: String
  let isimage: Int
  
  enum CodingKeys: String, CodingKey {
    case tags
    case content
    case isimage
  }
}

// MARK: - 网络错误类型
enum NetworkError: Error, LocalizedError {
  case invalidURL
  case noData
  case decodingError(Error)
  case serverError(Int)
  case unauthorized
  case networkError(Error)
  
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "无效的URL"
    case .noData:
      return "没有接收到数据"
    case .decodingError(let error):
      return "数据解析错误: \(error.localizedDescription)"
    case .serverError(let code):
      return "服务器错误: \(code)"
    case .unauthorized:
      return "未授权访问"
    case .networkError(let error):
      return "网络错误: \(error.localizedDescription)"
    }
  }
}

