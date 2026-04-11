//
//  KeychainHelper.swift
//  MemoFlux
//
//  Created by OpenAI Codex on 2026/3/31.
//

import Foundation
import Security

enum KeychainHelper {
  private static let service = "com.shuoma.memoflux.ai-models"
  
  static func set(_ value: String, for account: String) {
    guard let data = value.data(using: .utf8) else { return }
    
    let query: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account
    ]
    
    let attributes: [CFString: Any] = [
      kSecValueData: data
    ]
    
    let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    if status == errSecSuccess {
      return
    }
    
    var item = query
    item[kSecValueData] = data
    SecItemAdd(item as CFDictionary, nil)
  }
  
  static func string(for account: String) -> String? {
    let query: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account,
      kSecReturnData: true,
      kSecMatchLimit: kSecMatchLimitOne
    ]
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    guard status == errSecSuccess,
          let data = result as? Data,
          let value = String(data: data, encoding: .utf8) else {
      return nil
    }
    
    return value
  }
  
  static func removeValue(for account: String) {
    let query: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account
    ]
    
    SecItemDelete(query as CFDictionary)
  }
}
