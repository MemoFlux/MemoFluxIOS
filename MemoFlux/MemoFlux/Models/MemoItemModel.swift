//
//  MemoItemModel.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import Foundation
import SwiftData
import SwiftUI

/// 首页 List cell 中 item 的数据模型
@Model
final class MemoItemModel: Identifiable {
  var id: UUID
  var imageData: Data?  // 存储图片
  var recognizedText: String
  var userInputText: String = ""
  var title: String
  var tags: [String]
  var createdAt: Date
  var scheduledDate: Date?
  var source: String
  
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
  var apiResponse: APIResponse? {
    guard let apiResponseData = apiResponseData else { return nil }
    return try? JSONDecoder().decode(APIResponse.self, from: apiResponseData)
  }
  
  init(image: UIImage, title: String = "", tags: [String] = [], source: String = "") {
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
    id: UUID = UUID(), imageData: Data? = nil, recognizedText: String = "", 
    userInputText: String = "", title: String = "",
    tags: [String] = [], createdAt: Date = Date(), scheduledDate: Date? = nil,
    source: String = "", apiResponseData: Data? = nil, isAPIProcessing: Bool = false,
    apiProcessedAt: Date? = nil, hasAPIResponse: Bool = false
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
  func setAPIResponse(_ response: APIResponse) {
    do {
      self.apiResponseData = try JSONEncoder().encode(response)
      self.hasAPIResponse = true
      self.isAPIProcessing = false
      self.apiProcessedAt = Date()
    } catch {
      print("保存API响应失败: \(error)")
      self.isAPIProcessing = false
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
}
