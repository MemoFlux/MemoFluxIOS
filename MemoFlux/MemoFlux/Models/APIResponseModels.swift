//
//  APIResponseModels.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/25.
//

import Foundation

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

// MARK: - 百炼兼容接口请求/响应

struct BailianChatCompletionRequest: Encodable {
  let model: String
  let messages: [Message]

  struct Message: Encodable {
    let role: String
    let content: [Content]
  }

  struct Content: Encodable {
    let type: String
    let text: String?
    let imageURL: ImageURL?

    init(text: String) {
      self.type = "text"
      self.text = text
      self.imageURL = nil
    }

    init(imageURL: String) {
      self.type = "image_url"
      self.text = nil
      self.imageURL = ImageURL(url: imageURL)
    }

    enum CodingKeys: String, CodingKey {
      case type
      case text
      case imageURL = "image_url"
    }
  }

  struct ImageURL: Encodable {
    let url: String
  }
}

struct BailianChatCompletionResponse: Decodable {
  let choices: [Choice]

  struct Choice: Decodable {
    let message: Message
  }

  struct Message: Decodable {
    let role: String?
    let content: JSONValue
  }
}

enum JSONValue: Codable {
  case string(String)
  case number(Double)
  case bool(Bool)
  case object([String: JSONValue])
  case array([JSONValue])
  case null

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if container.decodeNil() {
      self = .null
    } else if let string = try? container.decode(String.self) {
      self = .string(string)
    } else if let bool = try? container.decode(Bool.self) {
      self = .bool(bool)
    } else if let int = try? container.decode(Int.self) {
      self = .number(Double(int))
    } else if let double = try? container.decode(Double.self) {
      self = .number(double)
    } else if let object = try? container.decode([String: JSONValue].self) {
      self = .object(object)
    } else if let array = try? container.decode([JSONValue].self) {
      self = .array(array)
    } else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Unsupported JSON value"
      )
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    switch self {
    case .string(let value):
      try container.encode(value)
    case .number(let value):
      try container.encode(value)
    case .bool(let value):
      try container.encode(value)
    case .object(let value):
      try container.encode(value)
    case .array(let value):
      try container.encode(value)
    case .null:
      try container.encodeNil()
    }
  }

  var stringValue: String? {
    guard case .string(let value) = self else { return nil }
    return value
  }

  var objectValue: [String: Any]? {
    guard case .object(let value) = self else { return nil }
    return value.mapValues { $0.foundationValue }
  }

  var arrayValue: [Any]? {
    guard case .array(let value) = self else { return nil }
    return value.map { $0.foundationValue }
  }

  var foundationValue: Any {
    switch self {
    case .string(let value):
      return value
    case .number(let value):
      if value.rounded(.towardZero) == value {
        return Int(value)
      }
      return value
    case .bool(let value):
      return value
    case .object(let value):
      return value.mapValues { $0.foundationValue }
    case .array(let value):
      return value.map { $0.foundationValue }
    case .null:
      return NSNull()
    }
  }
}

// MARK: - 网络错误类型
enum NetworkError: Error, LocalizedError {
  case invalidURL
  case noData
  case decodingError(Error)
  case serverError(Int)
  case unauthorized
  case invalidConfiguration(String)
  case invalidResponseFormat(String)
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
    case .invalidConfiguration(let message):
      return "配置错误: \(message)"
    case .invalidResponseFormat(let message):
      return "响应格式错误: \(message)"
    case .networkError(let error):
      return "网络错误: \(error.localizedDescription)"
    }
  }
}
