//
//  PushNotificationManager.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/09/28.
//

import Foundation
import UserNotifications
import SwiftUI

class PushNotificationManager: NSObject, ObservableObject {
  static let shared = PushNotificationManager()
  
  @Published var deviceToken: String?
  @Published var isAuthorized: Bool = false
  @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
  @Published var isInitialized: Bool = false
  
  private override init() {
    super.init()
    checkAuthorizationStatus()
  }
  
  // MARK: - 初始化推送通知
  func initializePushNotifications() {
    print("🔔 初始化推送通知管理器")
    checkAuthorizationStatus()
    
    // 设置通知中心代理
    UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    
    DispatchQueue.main.async {
      self.isInitialized = true
    }
  }
  
  // MARK: - 请求推送权限
  func requestPermission() {
    print("🔐 请求推送通知权限")
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
      DispatchQueue.main.async {
        self?.isAuthorized = granted
        if granted {
          print("✅ 推送通知权限已授权")
          // 权限获取成功后，触发设备令牌注册
          self?.triggerDeviceTokenRegistration()
        } else {
          print("❌ 推送通知权限被拒绝")
          if let error = error {
            print("权限错误: \(error.localizedDescription)")
          }
        }
      }
    }
  }
  
  // MARK: - 检查授权状态
  func checkAuthorizationStatus() {
    UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
      DispatchQueue.main.async {
        self?.authorizationStatus = settings.authorizationStatus
        self?.isAuthorized = settings.authorizationStatus == .authorized
        print("📋 当前推送授权状态: \(settings.authorizationStatus.rawValue)")
        
        // 如果已经授权，尝试注册设备令牌
        if settings.authorizationStatus == .authorized {
          self?.triggerDeviceTokenRegistration()
        }
      }
    }
  }
  
  // MARK: - 触发设备令牌注册
  private func triggerDeviceTokenRegistration() {
    print("📱 触发设备令牌注册")
    DispatchQueue.main.async {
      // 通过通知触发主应用注册远程推送
      NotificationCenter.default.post(name: .registerForRemoteNotifications, object: nil)
    }
  }
  
  // MARK: - 处理设备令牌注册成功
  func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
    let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    
    DispatchQueue.main.async {
      self.deviceToken = tokenString
      print("🎯 设备令牌获取成功: \(tokenString)")
      print("📋 设备令牌 (供后端测试): \(tokenString)")
      
      // 发送设备令牌到服务器
      self.sendDeviceTokenToServer(tokenString)
    }
  }
  
  // MARK: - 处理设备令牌注册失败
  func didFailToRegisterForRemoteNotifications(withError error: Error) {
    DispatchQueue.main.async {
      self.deviceToken = nil
      print("💥 设备令牌获取失败: \(error.localizedDescription)")
    }
  }
  
  // MARK: - 发送设备令牌到服务器
  private func sendDeviceTokenToServer(_ token: String) {
    print("🚀 准备发送设备令牌到服务器: \(token)")
    
    // TODO: - 实现发送设备令牌到后端服务器的逻辑
    // 这里可以调用你的API来保存设备令牌
    
    // 示例代码（需要根据实际API调整）:
    /*
     let url = URL(string: "https://your-api.com/device-token")!
     var request = URLRequest(url: url)
     request.httpMethod = "POST"
     request.setValue("application/json", forHTTPHeaderField: "Content-Type")
     
     let body = ["device_token": token, "platform": "ios"]
     request.httpBody = try? JSONSerialization.data(withJSONObject: body)
     
     URLSession.shared.dataTask(with: request) { data, response, error in
     if let error = error {
     print("❌ 发送设备令牌失败: \(error.localizedDescription)")
     } else {
     print("✅ 设备令牌发送成功")
     }
     }.resume()
     */
    
    // 临时：仅打印令牌供后端测试使用
    print("📋 设备令牌 (供后端测试): \(token)")
  }
  
  // MARK: - 处理推送通知点击
  func handleNotificationResponse(_ response: UNNotificationResponse) {
    let userInfo = response.notification.request.content.userInfo
    print("📱 用户点击了推送通知: \(userInfo)")
    
    // TODO: 根据推送通知内容执行相应操作
    // 例如：导航到特定页面、更新数据等
  }
  
  // MARK: - 生成设备令牌（供测试使用）
  func generateDeviceTokenForTesting() {
    print("🧪 开始生成设备令牌（测试模式）")
    
    // 首先检查权限
    checkAuthorizationStatus()
    
    // 如果没有权限，请求权限
    if !isAuthorized {
      requestPermission()
    } else {
      // 如果已有权限，直接触发注册
      triggerDeviceTokenRegistration()
    }
  }
}

// MARK: - 通知名称扩展
extension Notification.Name {
  static let registerForRemoteNotifications = Notification.Name("registerForRemoteNotifications")
}

// MARK: - 通知代理
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
  static let shared = NotificationDelegate()
  
  private override init() {}
  
  // 应用在前台时收到推送通知
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("📨 应用在前台收到推送通知")
    // 在前台也显示通知
    completionHandler([.banner, .badge, .sound])
  }
  
  // 用户点击推送通知
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    print("👆 用户点击了推送通知")
    PushNotificationManager.shared.handleNotificationResponse(response)
    completionHandler()
  }
}

// MARK: - UNAuthorizationStatus Extension
extension UNAuthorizationStatus {
  var description: String {
    switch self {
    case .notDetermined:
      return "未确定"
    case .denied:
      return "已拒绝"
    case .authorized:
      return "已授权"
    case .provisional:
      return "临时授权"
    case .ephemeral:
      return "临时授权(App Clip)"
    @unknown default:
      return "未知状态"
    }
  }
}
