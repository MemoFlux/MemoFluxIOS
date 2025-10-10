//
//  ContentView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftUI

struct ContentView: View {
  
  @State private var showOnBoarding = !OnBoardingManager.shared.hasSeenOnBoarding
  @State private var selectedTabIndex = 0
  
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
    if #available(iOS 26.0, *) {
      TabView(selection: $selectedTabIndex) {
        Tab("主页", systemImage: "house", value: 0) {
          HomePageView()
        }
        Tab("意图", systemImage: "calendar", value: 1) {
          IntentListView()
        }
        Tab("分类", systemImage: "list.bullet", value: 2) {
          CategoryView()
        }
        Tab("设置", systemImage: "gearshape", value: 3) {
          SettingsView()
        }
        
//        Tab("搜索", systemImage: "magnifyingglass", value: 4, role: .search) {
//          HomePageView()
//        }
      }
      .tabViewStyle(.sidebarAdaptable)
      .tabBarMinimizeBehavior(.onScrollDown)
    } else {
      TabView {
        HomePageView()
          .tabItem {
            Image(systemName: "house")
            Text("主页")
          }
        IntentListView()
          .tabItem {
            Image(systemName: "calendar")
            Text("意图")
          }
        CategoryView()
          .tabItem {
            Image(systemName: "list.bullet")
            Text("分类")
          }
        SettingsView()
          .tabItem {
            Image(systemName: "gearshape")
            Text("设置")
          }
      }
      .background(Color.globalStyleBackgroundColor)
      .sheet(isPresented: $showOnBoarding, onDismiss: {
        OnBoardingManager.shared.markOnBoardingAsSeen()
      }) {
        OnBoardingView(isPresented: $showOnBoarding)
          .transition(.opacity.combined(with: .scale))
      }
    }
  }
}

#Preview {
  ContentView()
}
