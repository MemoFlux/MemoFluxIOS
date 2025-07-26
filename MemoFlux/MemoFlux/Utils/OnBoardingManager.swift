//
//  OnBoardingManager.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import Foundation

/// OnBoarding管理器
class OnBoardingManager {
    
    static let shared = OnBoardingManager()
    
    private let hasSeenOnBoardingKey = "hasSeenOnBoarding"
    
    private init() {}
    
    /// 检查用户是否已经看过OnBoarding
    var hasSeenOnBoarding: Bool {
        return UserDefaults.standard.bool(forKey: hasSeenOnBoardingKey)
    }
    
    /// 标记用户已经看过OnBoarding
    func markOnBoardingAsSeen() {
        UserDefaults.standard.set(true, forKey: hasSeenOnBoardingKey)
    }
    
    /// 重置OnBoarding状态（用于调试）
    func resetOnBoardingStatus() {
        UserDefaults.standard.removeObject(forKey: hasSeenOnBoardingKey)
    }
    
    /// 强制显示OnBoarding
    func forceShowOnBoarding() {
        UserDefaults.standard.set(false, forKey: hasSeenOnBoardingKey)
    }
}