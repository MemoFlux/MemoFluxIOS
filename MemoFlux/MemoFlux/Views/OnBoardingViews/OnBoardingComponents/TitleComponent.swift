//
//  TitleComponent.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import SwiftUI

struct TitleComponent: View {
    @State private var isAnimating = false
    let shouldHideComponents: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            if shouldHideComponents {
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.bottom, 20)
            }

            Text("欢迎使用")
                .foregroundColor(.primary)
                .fontWeight(.semibold)
                .font(.system(size: shouldHideComponents ? 32 : 28))
                .tracking(3)
                .lineLimit(1)
                .fixedSize()

            Text("MemoFlux")
                .foregroundStyle(Color.mainStyleBackgroundColor)
                .fontWeight(.bold)
                .font(.system(size: 42))
                .tracking(2)

            Text("智能备忘录助手")
                .foregroundColor(.secondary)
                .fontWeight(.medium)
                .font(.system(size: 16))
                .tracking(1)
                .padding(.top, 8)
        }
        .opacity(isAnimating ? 1 : 0)
        .scaleEffect(isAnimating ? 1.0 : 0.5)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    TitleComponent(shouldHideComponents: true)
        .padding(40)
        .background(Color.globalStyleBackgroundColor)
}
