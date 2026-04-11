//
//  SecureConfig.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/31.
//

import Foundation
import CryptoKit

struct SecureConfig {
  private static let encryptedBase64 = "EaBjCSn4W3wUYtdVWHaCTK+eTYYvZWJIrGsDmhSpBG5NC9JVA9SE0238zdERM+YhurA+"
  private static let keyBase64 = "5LZSFhH8CkEUiDf+vwWYCIbOPT6PzZu1u2ZV245T7IY="
  private static let encryptedArkBase64 = "e7MTGSpU5vtLharHuNFDuesuJWNbxMDTROabmoz4bRztSzjoj/T07Kh+ILLpRdYdM9hjWzcixazGqqdyoFbslEMUZ6rT0YJXvEtaQ3QWK7yJ6THxSg=="
  private static let arkKeyBase64 = "PHYt2c5/QJNswVJ96GMuDnk4196FWSP7FZV3kt/HydA="
  private static let encryptedArkAPIKeyBase64 = "S4XX0fVd/KCjypWkSmxuWXrg3TnCcjgAVlmCEsVbNOw+eYDa3avdOBN47a2QOaqGhcCowu7pId+r6ikGYJMGUA=="
  private static let arkAPIKeyKeyBase64 = "Pi910lOyj4N6vlQnyWyjXr0+v8bwa+9iFsKrNRlkJbk="
  private static let encryptedArkModelBase64 = "tYmK8ofeoKiKUvJWalJ1rRO/ZhUE9fPluOja4uUsZGHbmoQHoANwW9OxtBsgl9h9S1iZk1JzBdjI"
  private static let arkModelKeyBase64 = "n8AID4K8DJX1cclnp/zttsP4zpbyN1hxGuIEYGzl1e8="

  static var baseURL: String? {
    decrypt(encryptedBase64, keyBase64: keyBase64)
  }

  static var bailianBaseURL: String? {
    configuredValue(
      infoPlistKey: "BAILIAN_BASE_URL",
      environmentKey: "BAILIAN_BASE_URL",
      defaultValue: "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions"
    )
  }

  static var bailianAPIKey: String? {
    configuredValue(
      infoPlistKey: "BAILIAN_API_KEY",
      environmentKey: "BAILIAN_API_KEY"
    )
  }

  static var bailianVisionModelId: String? {
    configuredValue(
      infoPlistKey: "BAILIAN_VISION_MODEL_ID",
      environmentKey: "BAILIAN_VISION_MODEL_ID",
      defaultValue: "qwen-vl-plus"
    )
  }

  static var arkBaseURL: String? {
    decrypt(encryptedArkBase64, keyBase64: arkKeyBase64)
  }

  static var arkAPIKey: String? {
    decrypt(encryptedArkAPIKeyBase64, keyBase64: arkAPIKeyKeyBase64)
  }

  static var arkModelId: String? {
    decrypt(encryptedArkModelBase64, keyBase64: arkModelKeyBase64)
  }

  static var geminiBaseURL: String? {
    "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
  }

  static var geminiAPIKey: String? {
    if let infoPlistKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String {
      let trimmed = infoPlistKey.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmed.isEmpty {
        return trimmed
      }
    }

    if let envKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] {
      let trimmed = envKey.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmed.isEmpty {
        return trimmed
      }
    }

    return nil
  }

  private static func decrypt(_ encryptedBase64: String, keyBase64: String) -> String? {
    guard let encryptedData = Data(base64Encoded: encryptedBase64),
          let keyData = Data(base64Encoded: keyBase64) else {
      return nil
    }

    let key = SymmetricKey(data: keyData)

    do {
      let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
      let decryptedData = try AES.GCM.open(sealedBox, using: key)
      return String(data: decryptedData, encoding: .utf8)
    } catch {
      print("❌ Decryption failed: \(error)")
      return nil
    }
  }

  private static func configuredValue(
    infoPlistKey: String,
    environmentKey: String,
    defaultValue: String? = nil
  ) -> String? {
    if let infoPlistValue = Bundle.main.object(forInfoDictionaryKey: infoPlistKey) as? String {
      let trimmed = infoPlistValue.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmed.isEmpty {
        return trimmed
      }
    }

    if let environmentValue = ProcessInfo.processInfo.environment[environmentKey] {
      let trimmed = environmentValue.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmed.isEmpty {
        return trimmed
      }
    }

    return defaultValue
  }
}
