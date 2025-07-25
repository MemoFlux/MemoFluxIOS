//
//  TextEditorView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftUI

struct TextEditorView: View {
  @Binding var inputText: String
  @Binding var inputTitle: String
  @FocusState var isTextEditorFocused: Bool
  @FocusState var isTitleFocused: Bool
  @Binding var useAIParsing: Bool  // AI解析选项

  private let titleHeight: CGFloat = 50
  private let contentHeight: CGFloat = 130

  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        HStack {
          TextField("输入标题", text: $inputTitle)
            .font(.headline)
            .foregroundColor(.primary)
            .focused($isTitleFocused)
            .submitLabel(.next)
            .onSubmit {
              isTextEditorFocused = true
            }

          Spacer()
        }
        .padding(.horizontal, 19)
        .padding(.vertical, 10)
        .frame(height: titleHeight)

        // 分隔线
        Divider()
          .background(Color.mainStyleBackgroundColor.opacity(0.3))
          .padding(.horizontal, 10)

        // 内容输入框
        ZStack(alignment: .topLeading) {
          UIKitTextEditor(text: $inputText)
            .frame(height: contentHeight)
            .padding(10)
            .padding(.horizontal, 5)

          // textEditor 占位符
          if inputText.isEmpty {
            Text("输入或粘贴文本内容")
              .foregroundColor(Color(UIColor.lightGray))
              .padding(.horizontal, 19)
              .padding(.vertical, 18)
              .allowsHitTesting(false)
          }
        }
      }

      HStack {
        Button(action: {
          useAIParsing.toggle()
        }) {
          HStack(spacing: 4) {
            Image(systemName: useAIParsing ? "checkmark.circle" : "circle")

            Text("使用AI解析")
          }
          .font(.subheadline)
          .foregroundColor(Color.mainStyleBackgroundColor)
        }
        .buttonStyle(PlainButtonStyle())

        Spacer()

        VStack(alignment: .trailing, spacing: 2) {
          Text("\(inputText.count)")
            .font(.caption)
            .foregroundColor(.gray)
        }
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
/// 键盘工具栏的实现
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

    // MARK: - 键盘工具栏
    let toolbar = UIToolbar()
    toolbar.sizeToFit()

    // MARK: - 粘贴按钮
    let pasteStackView = UIStackView()
    pasteStackView.axis = .horizontal
    pasteStackView.alignment = .center
    pasteStackView.spacing = 4

    let pasteImageView = UIImageView(image: UIImage(systemName: "doc.on.clipboard"))
    pasteImageView.tintColor = UIColor.mainStyleBackgroundColor
    pasteImageView.contentMode = .scaleAspectFit
    pasteImageView.translatesAutoresizingMaskIntoConstraints = false
    pasteImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
    pasteImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true

    let pasteLabel = UILabel()
    pasteLabel.text = "粘贴自剪切板"
    pasteLabel.textColor = UIColor.mainStyleBackgroundColor
    pasteLabel.font = UIFont.systemFont(ofSize: 14)

    pasteStackView.addArrangedSubview(pasteImageView)
    pasteStackView.addArrangedSubview(pasteLabel)

    // 粘贴点击手势
    let pasteTapGesture = UITapGestureRecognizer(
      target: context.coordinator, action: #selector(Coordinator.pasteButtonTapped))
    pasteStackView.addGestureRecognizer(pasteTapGesture)
    pasteStackView.isUserInteractionEnabled = true

    let pasteButton = UIBarButtonItem(customView: pasteStackView)

    // MARK: - 收回键盘按钮
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

    toolbar.items = [pasteButton, flexSpace, doneButton]

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

    @objc func pasteButtonTapped() {
      if let string = UIPasteboard.general.string {
        parent.text = string
      }
    }
  }
}

struct TextEditorViewPreview: View {
  @State private var inputText = ""
  @State private var inputTitle = ""
  @State private var useAIParsing = true
  @FocusState private var isTextEditorFocused: Bool

  var body: some View {
    TextEditorView(
      inputText: $inputText,
      inputTitle: $inputTitle,
      isTextEditorFocused: _isTextEditorFocused,
      useAIParsing: $useAIParsing
    )
    .padding()
  }
}

#Preview {
  TextEditorViewPreview()
}
