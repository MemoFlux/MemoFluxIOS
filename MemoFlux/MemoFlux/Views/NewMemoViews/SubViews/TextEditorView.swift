//
//  TextEditorView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftUI

struct TextEditorView: View {
  @Binding var inputText: String
  @Binding var textEditorHeight: CGFloat
  @Binding var isHeightAdjusted: Bool
  @Binding var showingTextInput: Bool
  @FocusState var isTextEditorFocused: Bool
  let originalHeight: CGFloat
  var calculateTextHeight: () -> CGFloat
  
  var body: some View {
    VStack {
      TextEditor(text: $inputText)
        .frame(height: textEditorHeight)
        .padding(10)
        .padding(.horizontal, 5)
        .focused($isTextEditorFocused)
        .onChange(of: isTextEditorFocused) { focused in
          if focused {
            if isHeightAdjusted && !inputText.isEmpty {
              withAnimation {
                textEditorHeight = originalHeight
                isHeightAdjusted = false
              }
            }
          } else {
            if inputText.isEmpty {
              withAnimation {
                showingTextInput = false
              }
            } else {
              withAnimation {
                textEditorHeight = calculateTextHeight()
                isHeightAdjusted = true  // 标记高度已调整
              }
            }
          }
        }
      
      HStack {
        Button(action: {
          if let string = UIPasteboard.general.string {
            inputText = string
            DispatchQueue.main.asyncAfter(deadline: .now()) {
              withAnimation {
                textEditorHeight = calculateTextHeight()
                isHeightAdjusted = true
              }
            }
          }
        }) {
          HStack {
            Image(systemName: "doc.on.clipboard")
              .foregroundColor(Color.mainStyleBackgroundColor)
              .background(Color.white.opacity(0.8))
            Text("从剪贴板粘贴")
              .foregroundColor(Color.mainStyleBackgroundColor)
              .font(.subheadline)
          }
        }
        
        Spacer()
        
        Text("\(inputText.count)")
          .font(.caption)
          .foregroundColor(.gray)
          .padding(8)
      }
      .padding(.horizontal, 15)
      .padding(.bottom, 5)
    }
    .overlay(
      ZStack {
        RoundedRectangle(cornerRadius: 15)
          .stroke(Color.mainStyleBackgroundColor, lineWidth: 2)
      }
    )
    .onTapGesture { _ in
      // 点击TextEditor外部区域关闭键盘
      if !isTextEditorFocused {
        isTextEditorFocused = false
      }
    }
  }
}

// 由于TextEditorView需要多个绑定参数，无法直接创建预览
// 如果需要预览，可以创建一个包装视图
struct TextEditorViewPreview: View {
  @State private var inputText = "预览文本"
  @State private var textEditorHeight: CGFloat = 180
  @State private var isHeightAdjusted = false
  @State private var showingTextInput = true
  @FocusState private var isTextEditorFocused: Bool
  
  var body: some View {
    TextEditorView(
      inputText: $inputText,
      textEditorHeight: $textEditorHeight,
      isHeightAdjusted: $isHeightAdjusted,
      showingTextInput: $showingTextInput,
      isTextEditorFocused: _isTextEditorFocused,
      originalHeight: 180,
      calculateTextHeight: { 180 }
    )
    .padding()
  }
}

#Preview {
  TextEditorViewPreview()
}
