//
//  FeatureView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import SwiftUI

struct FeatureView: View {
    let info: FeatureInfo
    let accentColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(accentColor.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    info.image
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(accentColor)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(info.title)
                    .foregroundStyle(.primary)
                    .font(.system(size: 16, weight: .semibold))

                Text(info.content)
                    .foregroundStyle(.secondary)
                    .font(.system(size: 14, weight: .regular))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }

            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    FeatureView(
        info: FeatureInfo(
            image: Image(systemName: "camera.fill"),
            title: "智能图片识别",
            content: "拍照或选择图片，自动识别文字内容并进行AI分析，快速创建备忘录。"
        ),
        accentColor: Color.mainStyleBackgroundColor
    )
    .padding()
    .background(Color.globalStyleBackgroundColor)
}
