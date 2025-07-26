//
//  OnBoardingView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import SwiftUI

struct OnBoardingView: View {
  
  @State private var isAnimating = false
  @State private var backgroundOpacity = 0.0
  @Binding var isPresented: Bool
  
  var body: some View {
    ZStack {
      LinearGradient(
        gradient: Gradient(colors: [
          Color.globalStyleBackgroundColor,
          Color.globalStyleBackgroundColor.opacity(0.8),
          Color.mainStyleBackgroundColor.opacity(0.1)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()
      .opacity(backgroundOpacity)
      
      ScrollView {
        VStack(alignment: .center, spacing: 40) {
          Spacer(minLength: 60)
          
          TitleComponent(shouldHideComponents: !isAnimating)
            .offset(y: isAnimating ? 0 : 200)
          
          FeatureComponent(accentColor: Color.mainStyleBackgroundColor)
            .opacity(isAnimating ? 1 : 0)
            .padding(.horizontal, 45)
          
          Spacer(minLength: 120)
        }
        .padding(.vertical, 24)
      }
      .safeAreaInset(edge: .bottom) {
        BottomComponent(isPresented: $isPresented)
          .opacity(isAnimating ? 1 : 0)
      }
    }
    .onAppear {
      withAnimation(.easeInOut(duration: 1.0)) {
        backgroundOpacity = 1.0
      }
      
      withAnimation(.easeInOut(duration: 0.8).delay(1.6)) {
        isAnimating = true
      }
    }
  }
}

#Preview {
  OnBoardingView(isPresented: .constant(true))
}
