//
//  MemoFluxApp.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftData
import SwiftUI

@main
struct MemoFluxApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .preferredColorScheme(.light)  // 暂时强制浅色模式显示，未来适配深色模式后再更改
    }
    .modelContainer(for: [MemoItemModel.self, TagModel.self, ScheduleTaskModel.self])
  }
}
