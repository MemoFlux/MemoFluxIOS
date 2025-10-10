//
//  AppDelegate.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/09/28.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 设置推送通知代理
    UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    return true
  }
  
  // MARK: - 远程推送通知回调
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    PushNotificationManager.shared.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    PushNotificationManager.shared.didFailToRegisterForRemoteNotifications(withError: error)
  }
  
  // MARK: - 接收远程推送通知
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("📨 Received remote notification: \(userInfo)")
    completionHandler(.newData)
  }
}

  
// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
  
  // 应用在前台时收到通知
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("📨 Will present notification: \(notification.request.content.title)")
    completionHandler([.banner, .badge, .sound])
  }
  
  // 用户点击通知
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    print("👆 User tapped notification: \(response.notification.request.content.title)")
    completionHandler()
  }
}