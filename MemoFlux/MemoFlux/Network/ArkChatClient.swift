//
//  ArkChatClient.swift
//  MemoFlux
//
//  Created by OpenAI Codex on 2026/3/31.
//

import Foundation

final class BailianChatClient {
  static let shared = BailianChatClient()

  private let session: URLSession

  private init() {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 120.0
    configuration.timeoutIntervalForResource = 300.0
    session = URLSession(configuration: configuration)
  }

  @available(iOS 15.0, *)
  func analyzeImage(
    imageBase64: String,
    tags: [String],
    modelId: String? = SecureConfig.bailianVisionModelId,
    apiKey: String? = SecureConfig.bailianAPIKey,
    baseURL: String? = SecureConfig.bailianBaseURL
  ) async throws -> APIResponse {
    let trimmedImage = imageBase64.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmedImage.isEmpty else {
      throw NetworkError.networkError(
        NSError(
          domain: "BailianChatClient",
          code: -1,
          userInfo: [NSLocalizedDescriptionKey: "图片内容不能为空"]
        )
      )
    }

    guard let baseURL, let url = URL(string: baseURL) else {
      throw NetworkError.invalidURL
    }

    guard let apiKey, !apiKey.isEmpty else {
      throw NetworkError.invalidConfiguration("缺少百炼 API Key")
    }

    guard let modelId, !modelId.isEmpty else {
      throw NetworkError.invalidConfiguration("缺少百炼模型配置")
    }

    let requestBody = try makeRequestBody(
      imageBase64: trimmedImage,
      tags: tags,
      modelId: modelId
    )
    let requestData = try JSONEncoder().encode(requestBody)

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.timeoutInterval = 300.0
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.httpBody = requestData

    print(
      """
      🚀 Bailian request prepared \
      model=\(modelId) \
      tags=\(tags.count) \
      imageChars=\(trimmedImage.count) \
      payloadBytes=\(requestData.count)
      """
    )

    do {
      let (data, response) = try await session.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.noData
      }

      if let rawResponse = String(data: data, encoding: .utf8) {
        print("📥 Bailian response: \(rawResponse)")
      }

      guard 200...299 ~= httpResponse.statusCode else {
        if httpResponse.statusCode == 401 {
          throw NetworkError.unauthorized
        }
        throw NetworkError.serverError(httpResponse.statusCode)
      }

      let completion = try JSONDecoder().decode(BailianChatCompletionResponse.self, from: data)
      return try parseAPIResponse(from: completion)
    } catch let error as NetworkError {
      throw error
    } catch let error as URLError where error.code == .timedOut {
      throw NetworkError.networkError(
        NSError(
          domain: NSURLErrorDomain,
          code: error.errorCode,
          userInfo: [NSLocalizedDescriptionKey: "图片解析超时，请稍后重试或换一张更小的图片"]
        )
      )
    } catch let error as DecodingError {
      throw NetworkError.decodingError(error)
    } catch {
      throw NetworkError.networkError(error)
    }
  }

  private func makeRequestBody(
    imageBase64: String,
    tags: [String],
    modelId: String
  ) throws -> BailianChatCompletionRequest {
    let prompt = try makePrompt(tags: tags)

    return BailianChatCompletionRequest(
      model: modelId,
      messages: [
        .init(
          role: "user",
          content: [
            .init(imageURL: "data:image/jpeg;base64,\(imageBase64)"),
            .init(text: prompt)
          ]
        )
      ]
    )
  }

  private func makePrompt(tags: [String]) throws -> String {
    let promptObject: [String: Any] = [
      "instruction": BailianPrompt.instruction,
      "outputRequirements": BailianPrompt.outputRequirements,
      "existingTags": tags,
      "schema": try BailianPrompt.schemaObject()
    ]

    let data = try JSONSerialization.data(withJSONObject: promptObject, options: [.prettyPrinted])
    guard let json = String(data: data, encoding: .utf8) else {
      throw NetworkError.invalidResponseFormat("无法生成百炼提示词")
    }

    return json
  }

  private func parseAPIResponse(from completion: BailianChatCompletionResponse) throws -> APIResponse {
    guard let firstChoice = completion.choices.first else {
      throw NetworkError.invalidResponseFormat("百炼返回缺少 choices")
    }

    let rawContent = firstChoice.message.content
    let structuredObject: [String: Any]

    if let contentString = rawContent.stringValue {
      let normalizedString = normalizedJSONString(from: contentString)
      structuredObject = try jsonObject(from: Data(normalizedString.utf8))
    } else if let contentObject = rawContent.objectValue {
      structuredObject = contentObject
    } else if let contentArray = rawContent.arrayValue,
              let contentText = extractText(from: contentArray) {
      let normalizedString = normalizedJSONString(from: contentText)
      structuredObject = try jsonObject(from: Data(normalizedString.utf8))
    } else {
      throw NetworkError.invalidResponseFormat("百炼 message.content 不是可解析的 JSON")
    }

    var sanitizedObject = structuredObject
    sanitizeResponse(&sanitizedObject)

    let normalizedData = try JSONSerialization.data(withJSONObject: sanitizedObject, options: [])

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

  private func normalizedJSONString(from text: String) -> String {
    let stripped = stripCodeFenceIfNeeded(text)
    guard let startIndex = stripped.firstIndex(of: "{"),
          let endIndex = stripped.lastIndex(of: "}") else {
      return stripped.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    return String(stripped[startIndex...endIndex])
      .trimmingCharacters(in: .whitespacesAndNewlines)
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

  private func extractText(from contentArray: [Any]) -> String? {
    for item in contentArray {
      if let text = item as? String, !text.isEmpty {
        return text
      }

      guard let dictionary = item as? [String: Any] else { continue }

      if let text = dictionary["text"] as? String, !text.isEmpty {
        return text
      }

      if let text = dictionary["content"] as? String, !text.isEmpty {
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

private enum BailianPrompt {
  static let instruction = """
  Analyze the uploaded image and return exactly one JSON object that matches the provided schema.
  Do not output markdown, code fences, explanations, notes, or extra fields.
  Keep all user-facing strings in Simplified Chinese unless the image is clearly dominated by another language.
  Prioritize the provided existing tags when they are relevant. Create new tags only when necessary.
  """

  static let outputRequirements = """
  - Output must be valid JSON only.
  - The root keys must be mostPossibleCategory, information, schedule.
  - information.title and schedule.title should be concise display titles.
  - tags arrays should contain at most 6 items.
  - If no schedule is present, return an empty tasks array.
  - If no information items are obvious, still return a concise summary and an empty informationItems array.
  """

  static let schema = """
  {
    "type": "object",
    "properties": {
      "mostPossibleCategory": { "type": "string" },
      "information": {
        "type": "object",
        "properties": {
          "title": { "type": "string" },
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
      },
      "schedule": {
        "type": "object",
        "properties": {
          "title": { "type": "string" },
          "category": { "type": "string" },
          "tasks": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "startTime": { "type": "string" },
                "endTime": { "type": "string" },
                "people": { "type": "array", "items": { "type": "string" } },
                "theme": { "type": "string" },
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
      }
    },
    "required": ["mostPossibleCategory", "information", "schedule"],
    "additionalProperties": false
  }
  """

  static func schemaObject() throws -> [String: Any] {
    guard
      let data = schema.data(using: .utf8),
      let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    else {
      throw NetworkError.invalidResponseFormat("百炼 schema 无法解析")
    }

    return object
  }
}
