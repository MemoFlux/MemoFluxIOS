//
//  MemoFluxApp.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftData
import SwiftUI
import UserNotifications
import UIKit

@main
struct MemoFluxApp: App {
  @StateObject private var pushNotificationManager = PushNotificationManager.shared
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  // 用于处理 Deep Link 分享的图片
  @State private var sharedImage: UIImage?
  @State private var showSharedMemoView = false
  
  // ⚠️ 需要与 Share Extension 里配置的 App Group ID 保持一致
  private let appGroupId = "group.com.xiaobai.memofluxapp"
  
  init() {
    // 初始化推送通知管理器
    PushNotificationManager.shared.initializePushNotifications()
  }
  
  func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if granted {
        print("Permission granted for notifications.")
      } else {
        print("Permission denied.")
      }
    }
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .preferredColorScheme(.light)  // 暂时强制浅色模式显示，未来适配深色模式后再更改
        .environmentObject(pushNotificationManager)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didFinishLaunchingNotification)) { _ in
          // 应用启动完成后注册远程推送
          registerForRemoteNotifications()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
          // 应用变为活跃状态时检查推送状态
          pushNotificationManager.checkAuthorizationStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: .registerForRemoteNotifications)) { _ in
          // 监听设备令牌注册请求
          print("📱 收到设备令牌注册请求")
          registerForRemoteNotifications()
        }
        // 处理 URL Scheme
        .onOpenURL { url in
          handleOpenURL(url)
        }
        // 弹出创建 Memo 视图（带有分享的图片）
        // 用全屏更贴近“进入创建页”的体验
        .fullScreenCover(isPresented: $showSharedMemoView) {
          AddMemoItemView(initialImage: sharedImage)
        }
    }
    .modelContainer(for: [MemoItemModel.self, TagModel.self, ScheduleTaskModel.self])
  }
  
  // MARK: - URL Handling
  private func handleOpenURL(_ url: URL) {
    print("🚀 App opened with URL: \(url.absoluteString)")
    
    // 解析 URL: memoflux://share?imagePath=...
    guard url.scheme == "memoflux", url.host == "share" else { return }
    
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
          let queryItems = components.queryItems else { return }
    
    if let imagePath = queryItems.first(where: { $0.name == "imagePath" })?.value, !imagePath.isEmpty {
      // 从 App Group 容器读取图片
      if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) {
        let fileURL = sharedContainerURL.appendingPathComponent(imagePath)
        if let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) {
          DispatchQueue.main.async {
            self.sharedImage = image
            self.showSharedMemoView = true
          }
          
          // 可选：读取后删除临时文件
          try? FileManager.default.removeItem(at: fileURL)
        } else {
          print("❌ Failed to load image from shared container")
        }
      }
    }
  }
  
  // MARK: - 注册远程推送通知
  private func registerForRemoteNotifications() {
    print("🚀 应用启动，开始注册远程推送通知")
    
    DispatchQueue.main.async {
      // 检查当前授权状态
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        if settings.authorizationStatus == .authorized {
          DispatchQueue.main.async {
            // 注册远程推送通知
            UIApplication.shared.registerForRemoteNotifications()
            print("📱 已调用 registerForRemoteNotifications")
          }
        } else {
          print("⚠️ 推送通知未授权，无法注册远程推送")
        }
      }
    }
  }
}
