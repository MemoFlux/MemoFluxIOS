//
//  MemoFluxApp.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftData
import SwiftUI
import UserNotifications

@main
struct MemoFluxApp: App {
  init() {
    
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
    }
    .modelContainer(for: [MemoItemModel.self, TagModel.self, ScheduleTaskModel.self])
  }
}
