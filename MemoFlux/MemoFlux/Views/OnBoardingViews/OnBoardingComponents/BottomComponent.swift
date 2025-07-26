//
//  BottomComponent.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import SwiftUI

struct BottomComponent: View {
    @Binding var isPresented: Bool
    @State private var isAnimating: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Button("开始使用 MemoFlux") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPresented = false
                }
            }
            .buttonStyle(OnBoardingButtonStyle())
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 24)
        .opacity(isAnimating ? 1 : 0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).delay(2.2)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - OnBoarding按钮样式
struct OnBoardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.mainStyleBackgroundColor)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    VStack {
        Spacer()
    }
    .safeAreaInset(edge: .bottom) {
        BottomComponent(isPresented: .constant(true))
    }
    .background(Color.globalStyleBackgroundColor)
}
