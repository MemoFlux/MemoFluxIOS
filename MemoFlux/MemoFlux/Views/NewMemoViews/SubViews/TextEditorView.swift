//
//  TextEditorView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftUI

struct TextEditorView: View {
  @Binding var inputText: String
  @FocusState var isTextEditorFocused: Bool
  
  private let fixedHeight: CGFloat = 180  // 输入框高度
  
  var body: some View {
    VStack {
      ZStack(alignment: .topLeading) {
        UIKitTextEditor(text: $inputText)
          .frame(height: fixedHeight)
          .padding(10)
          .padding(.horizontal, 5)
        
        // 手动添加占位符
        if inputText.isEmpty {
          Text("输入或粘贴文本内容")
            .foregroundColor(.gray)
            .padding(.horizontal, 22)
            .padding(.vertical, 18)
            .allowsHitTesting(false)
        }
      }
      
      HStack {
        Button(action: {
          if let string = UIPasteboard.general.string {
            inputText = string
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
  }
}

// MARK: - UIKit TextEditor 包装器
struct UIKitTextEditor: UIViewRepresentable {
  @Binding var text: String
  
  func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.delegate = context.coordinator
    textView.font = UIFont.systemFont(ofSize: 16)
    textView.backgroundColor = UIColor.clear
    textView.textColor = UIColor.label
    textView.isScrollEnabled = true
    textView.isEditable = true
    textView.isUserInteractionEnabled = true
    
    // 键盘工具栏
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    // 完成按钮以收回键盘
    let doneButton = UIBarButtonItem(
      title: "完成",
      style: .done,
      target: context.coordinator,
      action: #selector(Coordinator.doneButtonTapped)
    )
    
    doneButton.tintColor = UIColor.mainStyleBackgroundColor
    
    let flexSpace = UIBarButtonItem(
      barButtonSystemItem: .flexibleSpace,
      target: nil,
      action: nil
    )
    
    // 工具栏item
    toolbar.items = [flexSpace, doneButton]
    
    textView.inputAccessoryView = toolbar
    
    context.coordinator.textView = textView
    
    return textView
  }
  
  func updateUIView(_ uiView: UITextView, context: Context) {
    if uiView.text != text {
      uiView.text = text
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UITextViewDelegate {
    let parent: UIKitTextEditor
    weak var textView: UITextView?
    
    init(_ parent: UIKitTextEditor) {
      self.parent = parent
    }
    
    func textViewDidChange(_ textView: UITextView) {
      parent.text = textView.text
    }
    
    @objc func doneButtonTapped() {
      textView?.resignFirstResponder()
    }
  }
}

struct TextEditorViewPreview: View {
  @State private var inputText = ""
  @FocusState private var isTextEditorFocused: Bool
  
  var body: some View {
    TextEditorView(
      inputText: $inputText,
      isTextEditorFocused: _isTextEditorFocused
    )
    .padding()
  }
}

#Preview {
  TextEditorViewPreview()
}
