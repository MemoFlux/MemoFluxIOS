//
//  ContentView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftUI
import UIKit

struct ContentView: View {

  init() {
    // TabBar 外观设置
    let tabBarAppearance = UITabBarAppearance()
    tabBarAppearance.configureWithDefaultBackground()
    tabBarAppearance.backgroundColor = UIColor.globalStyleBackgroundColor
    tabBarAppearance.shadowColor = UIColor.clear

    let scrollEdgeAppearance = UITabBarAppearance()
    scrollEdgeAppearance.configureWithOpaqueBackground()
    scrollEdgeAppearance.backgroundColor = UIColor.globalStyleBackgroundColor
    scrollEdgeAppearance.shadowColor = UIColor.clear

    UITabBar.appearance().standardAppearance = tabBarAppearance
    UITabBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
  }

  var body: some View {
    TabView {
      HomePageView()
        .tabItem {
          Image(systemName: "house")
          Text("主页")
        }
      CategoryView()
        .tabItem {
          Image(systemName: "chart.pie")
          Text("总结")
        }
      CategoryView()
        .tabItem {
          Image(systemName: "list.bullet")
          Text("分类")
        }
      CategoryView()
        .tabItem {
          Image(systemName: "gear")
          Text("设置")
        }
    }
    .background(Color.globalStyleBackgroundColor)
  }
}

#Preview {
  ContentView()
}
