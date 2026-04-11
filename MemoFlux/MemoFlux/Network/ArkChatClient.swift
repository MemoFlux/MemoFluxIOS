//
//  ArkChatClient.swift
//  MemoFlux
//
//  Created by OpenAI Codex on 2026/3/31.
//

import Foundation

final class ArkChatClient {
  static let shared = ArkChatClient()
  
  private let session: URLSession
  
  private init() {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 120.0
    configuration.timeoutIntervalForResource = 300.0
    session = URLSession(configuration: configuration)
  }
  
  @available(iOS 15.0, *)
  func analyzeContent(
    text: String?,
    imageBase64: String?,
    serviceConfiguration: AIServiceConfiguration,
    tags: [String]
  ) async throws -> APIResponse {
    switch serviceConfiguration.requestStyle {
    case .openAICompatibleChatCompletions:
      return try await analyzeContent(
        text: text,
        imageBase64: imageBase64,
        tags: tags,
        modelId: serviceConfiguration.modelId,
        apiKey: serviceConfiguration.apiKey,
        baseURL: serviceConfiguration.baseURL
      )
    }
  }
  
  @available(iOS 15.0, *)
  func analyzeContent(
    text: String?,
    imageBase64: String?,
    tags: [String],
    modelId: String? = SecureConfig.arkModelId,
    apiKey: String? = SecureConfig.arkAPIKey,
    baseURL: String? = SecureConfig.arkBaseURL
  ) async throws -> APIResponse {
    let trimmedText = text?.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedImage = imageBase64?.trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard !(trimmedText?.isEmpty ?? true) || !(trimmedImage?.isEmpty ?? true) else {
      throw NetworkError.networkError(
        NSError(
          domain: "ArkChatClient",
          code: -1,
          userInfo: [NSLocalizedDescriptionKey: "文本和图片内容不能同时为空"]
        )
      )
    }
    
    guard let baseURL, let url = URL(string: baseURL) else {
      throw NetworkError.invalidURL
    }
    
    guard let apiKey, !apiKey.isEmpty else {
      throw NetworkError.invalidConfiguration("缺少 Ark API Key")
    }
    
    guard let modelId, !modelId.isEmpty else {
      throw NetworkError.invalidConfiguration("缺少 Ark 模型配置")
    }
    
    let requestBody = try makeRequestBody(
      text: trimmedText,
      imageBase64: trimmedImage,
      tags: tags,
      modelId: modelId
    )
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.timeoutInterval = 300.0
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.httpBody = requestBody
    
    print(
      """
      🚀 Ark request prepared \
      model=\(modelId) \
      tags=\(tags.count) \
      hasImage=\(!(trimmedImage?.isEmpty ?? true)) \
      imageChars=\(trimmedImage?.count ?? 0) \
      textChars=\(trimmedText?.count ?? 0) \
      payloadBytes=\(requestBody.count)
      """
    )
    
    do {
      let (data, response) = try await session.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.noData
      }
      
      if let rawResponse = String(data: data, encoding: .utf8) {
        print("📥 Ark response: \(rawResponse)")
      }
      
      guard 200...299 ~= httpResponse.statusCode else {
        if httpResponse.statusCode == 401 {
          throw NetworkError.unauthorized
        }
        throw NetworkError.serverError(httpResponse.statusCode)
      }
      
      return try parseAPIResponse(from: data)
    } catch let error as NetworkError {
      throw error
    } catch let error as URLError where error.code == .timedOut {
      throw NetworkError.networkError(
        NSError(
          domain: error.errorCode.description,
          code: error.errorCode,
          userInfo: [NSLocalizedDescriptionKey: "图片解析超时，请稍后重试或换一张更小的图片"]
        )
      )
    } catch {
      throw NetworkError.networkError(error)
    }
  }
  
  private func makeRequestBody(
    text: String?,
    imageBase64: String?,
    tags: [String],
    modelId: String
  ) throws -> Data {
    let hasImage = !(imageBase64?.isEmpty ?? true)
    let promptObject = try makePromptObject(text: text, tags: tags, isImage: hasImage)
    
    var content = [[String: Any]]()
    
    if let imageBase64, !imageBase64.isEmpty {
      content.append(
        [
          "type": "image_url",
          "image_url": [
            "url": "data:image/jpeg;base64,\(imageBase64)"
          ]
        ]
      )
    }
    
    content.append(
      [
        "type": "text",
        "text": promptObject
      ]
    )
    
    let requestObject: [String: Any] = [
      "model": modelId,
      "messages": [
        [
          "role": "user",
          "content": content
        ]
      ]
    ]
    
    return try JSONSerialization.data(withJSONObject: requestObject, options: [])
  }
  
  private func makePromptObject(text: String?, tags: [String], isImage: Bool) throws -> String {
    var promptObject: [String: Any] = [
      "tags": tags,
      "isimage": isImage ? 1 : 0,
      "instruction": ArkPrompt.instruction,
      "schema": try ArkPrompt.schemaObject()
    ]
    
    if let text, !text.isEmpty {
      promptObject["userContent"] = text
    }
    
    let data = try JSONSerialization.data(withJSONObject: promptObject, options: [])
    guard let json = String(data: data, encoding: .utf8) else {
      throw NetworkError.invalidResponseFormat("无法生成 Ark prompt")
    }
    
    return json
  }
  
  private func parseAPIResponse(from data: Data) throws -> APIResponse {
    let rootObject = try jsonObject(from: data)
    
    guard
      let choices = rootObject["choices"] as? [[String: Any]],
      let firstChoice = choices.first,
      let message = firstChoice["message"] as? [String: Any]
    else {
      throw NetworkError.invalidResponseFormat("Ark 返回缺少 choices.message")
    }
    
    let rawContent: Any
    if let content = message["content"] {
      rawContent = content
    } else {
      throw NetworkError.invalidResponseFormat("Ark 返回缺少 message.content")
    }
    
    var structuredObject: [String: Any]
    
    if let contentString = rawContent as? String {
      let normalizedString = stripCodeFenceIfNeeded(contentString)
      structuredObject = try jsonObject(from: Data(normalizedString.utf8))
    } else if let contentObject = rawContent as? [String: Any] {
      structuredObject = contentObject
    } else if let contentArray = rawContent as? [[String: Any]],
              let contentText = extractText(from: contentArray) {
      let normalizedString = stripCodeFenceIfNeeded(contentText)
      structuredObject = try jsonObject(from: Data(normalizedString.utf8))
    } else {
      throw NetworkError.invalidResponseFormat("message.content 不是可解析的 JSON")
    }
    
    sanitizeResponse(&structuredObject)
    
    let normalizedData = try JSONSerialization.data(withJSONObject: structuredObject, options: [])
    do {
      return try JSONDecoder().decode(APIResponse.self, from: normalizedData)
    } catch {
      throw NetworkError.decodingError(error)
    }
  }
  
  private func sanitizeResponse(_ response: inout [String: Any]) {
    let informationSource = dictionary(from: response["information"])
      ?? dictionary(from: response["knowledge"])
      ?? [:]
    let scheduleSource = dictionary(from: response["schedule"]) ?? [:]
    
    response = [
      "mostPossibleCategory": string(
        from: response["mostPossibleCategory"],
        response["most_possible_category"],
        response["most_possbile_category"]
      ),
      "information": sanitizeInformation(informationSource),
      "schedule": sanitizeSchedule(scheduleSource)
    ]
  }
  
  private func sanitizeInformation(_ information: [String: Any]) -> [String: Any] {
    let rawItems =
      array(from: information["informationItems"])
      ?? array(from: information["information_items"])
      ?? array(from: information["knowledge_items"])
      ?? []
    
    let items = rawItems.enumerated().map { index, rawItem in
      sanitizeInformationItem(dictionary(from: rawItem) ?? [:], fallbackID: index + 1)
    }
    
    let relatedItems =
      stringArray(
        from: information["relatedItems"],
        information["related_items"]
      )
    
    return [
      "title": string(from: information["title"]),
      "informationItems": items,
      "relatedItems": relatedItems,
      "summary": string(from: information["summary"]),
      "tags": sanitizedTags(from: information["tags"])
    ]
  }
  
  private func sanitizeInformationItem(
    _ item: [String: Any],
    fallbackID: Int
  ) -> [String: Any] {
    var sanitizedItem: [String: Any] = [
      "id": int(from: item["id"]) ?? fallbackID,
      "header": string(from: item["header"]),
      "content": string(from: item["content"])
    ]
    
    if let node = sanitizeNode(dictionary(from: item["node"])) {
      sanitizedItem["node"] = node
    } else {
      sanitizedItem["node"] = NSNull()
    }
    
    return sanitizedItem
  }
  
  private func sanitizeNode(_ node: [String: Any]?) -> [String: Any]? {
    guard let node else { return nil }
    guard let targetID = int(from: node["targetId"], node["target_id"], node["targert_id"]) else {
      return nil
    }
    
    return [
      "targetId": targetID,
      "relationship": string(from: node["relationship"])
    ]
  }
  
  private func sanitizeSchedule(_ schedule: [String: Any]) -> [String: Any] {
    let rawTasks = array(from: schedule["tasks"]) ?? []
    let tasks = rawTasks.compactMap { rawTask in
      dictionary(from: rawTask)
    }
    .map { sanitizeTask($0) }
    
    return [
      "title": string(from: schedule["title"]),
      "category": string(from: schedule["category"]),
      "tasks": tasks
    ]
  }
  
  private func sanitizeTask(_ task: [String: Any]) -> [String: Any] {
    let rawStatus = string(from: task["status"], task["taskStatus"])
    
    return [
      "startTime": string(from: task["startTime"], task["start_time"]),
      "endTime": string(from: task["endTime"], task["end_time"]),
      "people": stringArray(from: task["people"]),
      "theme": string(from: task["theme"]),
      "coreTasks": stringArray(from: task["coreTasks"], task["core_tasks"]),
      "position": stringArray(from: task["position"]),
      "tags": sanitizedTags(from: task["tags"]),
      "category": string(from: task["category"]),
      "suggestedActions": stringArray(from: task["suggestedActions"], task["suggested_actions"]),
      "status": normalizedTaskStatus(rawStatus),
      "id": normalizedTaskID(from: task)
    ]
  }
  
  private func sanitizedTags(from value: Any?) -> [String] {
    let tags = stringArray(from: value)
    return Array(tags.prefix(6))
  }
  
  private func normalizedTaskStatus(_ rawValue: String) -> String {
    switch rawValue.uppercased() {
    case "PENDING":
      return ScheduleTask.TaskStatus.pending.rawValue
    case "COMPLETED":
      return ScheduleTask.TaskStatus.completed.rawValue
    case "IGNORED":
      return ScheduleTask.TaskStatus.ignored.rawValue
    default:
      return rawValue
    }
  }
  
  private func normalizedTaskID(from task: [String: Any]) -> String {
    if let uuidString = task["id"] as? String,
       let validUUID = UUID(uuidString: uuidString) {
      return validUUID.uuidString
    }
    
    return generatedTaskID(from: task)
  }
  
  private func generatedTaskID(from task: [String: Any]) -> String {
    let startTime = string(from: task["startTime"], task["start_time"])
    let endTime = string(from: task["endTime"], task["end_time"])
    let theme = string(from: task["theme"])
    let category = string(from: task["category"])
    let seed = "\(startTime)-\(endTime)-\(theme)-\(category)"
    return UUID(uuidString: seed.sha256UUID)?.uuidString ?? UUID().uuidString
  }
  
  private func stripCodeFenceIfNeeded(_ text: String) -> String {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.hasPrefix("```") else { return trimmed }
    
    let lines = trimmed.components(separatedBy: .newlines)
    guard lines.count >= 3 else { return trimmed }
    
    let body = lines.dropFirst().dropLast().joined(separator: "\n")
    return body.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  private func jsonObject(from data: Data) throws -> [String: Any] {
    guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw NetworkError.invalidResponseFormat("JSON 根节点不是对象")
    }
    return object
  }
  
  private func extractText(from contentArray: [[String: Any]]) -> String? {
    for item in contentArray {
      if let text = item["text"] as? String, !text.isEmpty {
        return text
      }
      
      if let text = item["content"] as? String, !text.isEmpty {
        return text
      }
    }
    
    return nil
  }
  
  private func dictionary(from value: Any?) -> [String: Any]? {
    value as? [String: Any]
  }
  
  private func array(from value: Any?) -> [Any]? {
    value as? [Any]
  }
  
  private func string(from values: Any?...) -> String {
    for value in values {
      if let string = value as? String {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
          return trimmed
        }
      }
      
      if let number = value as? NSNumber {
        return number.stringValue
      }
    }
    
    return ""
  }
  
  private func int(from values: Any?...) -> Int? {
    for value in values {
      if let intValue = value as? Int {
        return intValue
      }
      
      if let number = value as? NSNumber {
        return number.intValue
      }
      
      if let string = value as? String,
         let intValue = Int(string.trimmingCharacters(in: .whitespacesAndNewlines)) {
        return intValue
      }
    }
    
    return nil
  }
  
  private func stringArray(from values: Any?...) -> [String] {
    for value in values {
      if let array = value as? [Any] {
        let strings = array.compactMap { element -> String? in
          if let string = element as? String {
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
          }
          
          if let number = element as? NSNumber {
            return number.stringValue
          }
          
          return nil
        }
        
        if !strings.isEmpty {
          return strings
        }
      }
    }
    
    return []
  }
}

private enum ArkPrompt {
  static let instruction = "Understand the content according to the specified json schema and return only the specified json format, without adding unnecessary fields. STRICTLY reply in English. ALWAYS generate a concise, specific, human-readable title that captures the core intent. For 'information.title' or 'schedule.title', write a short summary title in 4-10 words, clear enough to be shown as the main memo title, and never leave the dominant title empty. For each task 'theme', write a short action-focused title in 2-8 words. Avoid filler words, generic titles, and repeated prefixes. STRICTLY LIMIT all 'tags' arrays to a maximum of 6 items. If there are more, select only the 6 most important tags. The 'tags' field contains a list of existing tags. When generating tags for the content, prioritize using these existing tags if they are relevant. Only create new tags if no existing tags are suitable. For 'startTime', use the format 'yyyy-MM-dd HH:mm'. If no specific time (HH:mm) is identified, use 'yyyy-MM-dd'. If the date cannot be determined, return 'Today'."
  
  static let schema = """
  {
    "type": "object",
    "properties": {
      "mostPossibleCategory": { "type": "string" },
      "schedule": {
        "type": "object",
        "properties": {
          "title": {
            "type": "string",
            "description": "Overall concise summary title for the main schedule intent, 4-10 English words."
          },
          "category": { "type": "string" },
          "tasks": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "startTime": { "type": "string" },
                "endTime": { "type": "string" },
                "people": { "type": "array", "items": { "type": "string" } },
                "theme": {
                  "type": "string",
                  "description": "Concise action-focused task title, 2-8 English words."
                },
                "coreTasks": { "type": "array", "items": { "type": "string" } },
                "position": { "type": "array", "items": { "type": "string" } },
                "tags": { "type": "array", "items": { "type": "string" }, "maxItems": 6 },
                "category": { "type": "string" },
                "suggestedActions": { "type": "array", "items": { "type": "string" } }
              },
              "required": ["startTime", "endTime", "people", "theme", "coreTasks", "position", "tags", "category", "suggestedActions"],
              "additionalProperties": false
            }
          }
        },
        "required": ["title", "category", "tasks"],
        "additionalProperties": false
      },
      "information": {
        "type": "object",
        "properties": {
          "title": {
            "type": "string",
            "description": "Overall concise summary title for the main information intent, 4-10 English words."
          },
          "informationItems": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "id": { "type": "number" },
                "header": { "type": "string" },
                "content": { "type": "string" },
                "node": {
                  "anyOf": [
                    {
                      "type": "object",
                      "properties": {
                        "targetId": { "type": "number" },
                        "relationship": { "type": "string" }
                      },
                      "required": ["targetId", "relationship"],
                      "additionalProperties": false
                    },
                    { "type": "null" }
                  ]
                }
              },
              "required": ["id", "header", "content", "node"],
              "additionalProperties": false
            }
          },
          "relatedItems": {
            "type": "array",
            "items": { "type": "string" }
          },
          "summary": { "type": "string" },
          "tags": {
            "type": "array",
            "items": { "type": "string" },
            "maxItems": 6
          }
        },
        "required": ["title", "informationItems", "relatedItems", "summary", "tags"],
        "additionalProperties": false
      }
    },
    "required": ["mostPossibleCategory", "schedule", "information"],
    "additionalProperties": false
  }
  """
  
  static func schemaObject() throws -> [String: Any] {
    guard
      let data = schema.data(using: .utf8),
      let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    else {
      throw NetworkError.invalidResponseFormat("Ark schema 无法解析")
    }
    
    return object
  }
}
