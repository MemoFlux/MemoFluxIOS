//
//  TranslationManager.swift
//  MemoFlux
//
//  Created by AI on 2025/12/18.
//

import Foundation
import Translation

/// 本地翻译管理器，利用 iOS 18.0+ 的 Translation 框架进行设备端翻译
@available(iOS 18.0, *)
class TranslationManager {
    static let shared = TranslationManager()
    
    private init() {}
    
    /// 翻译单个字符串
    /// 注意：此方法需要从视图中使用 .translationTask 获得 session 才能工作更好
    
    @available(iOS 18.0, *)
    struct TranslationRequest {
        let text: String
        let sourceLanguage: Locale.Language?
        let targetLanguage: Locale.Language
    }
    
    /// 翻译 APIResponse 中的关键字段
    @available(iOS 18.0, *)
    func translateAPIResponse(_ response: APIResponse, session: Any) async -> APIResponse {
        guard let translationSession = session as? TranslationSession else {
            return response
        }
        
        var translatedResponse = response
        
        // 1. 翻译最可能的分类
        if !response.mostPossibleCategory.isEmpty {
            if let translated = try? await translationSession.translate(response.mostPossibleCategory).targetText {
                translatedResponse.mostPossibleCategory = translated
            }
        }
        
        return translatedResponse
    }
}
