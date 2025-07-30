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
  
  static var baseURL: String? {
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
}
