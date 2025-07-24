//
//  TextInputButtonView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftUI

struct TextInputButtonView: View {
  var action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        Image(systemName: "text.bubble")
        Text("输入/粘贴文本内容")
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 60)
    }
    .background(Color.mainStyleBackgroundColor)
    .foregroundStyle(.white)
    .cornerRadius(15)
  }
}

#Preview {
  TextInputButtonView(action: {})
}


