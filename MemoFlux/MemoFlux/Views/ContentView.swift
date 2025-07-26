//
//  ContentView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftUI

struct ContentView: View {
  
  @State private var showOnBoarding = !OnBoardingManager.shared.hasSeenOnBoarding
  
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
    // 主界面
    TabView {
      HomePageView()
        .tabItem {
          Image(systemName: "house")
          Text("主页")
        }
      CategoryView()
        .tabItem {
          Image(systemName: "list.bullet")
          Text("分类")
        }
    }
    .background(Color.globalStyleBackgroundColor)
    .sheet(isPresented: $showOnBoarding) {
      OnBoardingView(isPresented: $showOnBoarding)
        .transition(.opacity.combined(with: .scale))
        .onChange(of: showOnBoarding) { newValue in
          if !newValue {
#if !DEBUG
            // 用户完成了OnBoarding，保存状态
            OnBoardingManager.shared.markOnBoardingAsSeen()
#endif
          }
        }
    }
  }
}

#Preview {
  ContentView()
}
