//
//  TextEditorView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftUI
import UIKit

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
        // 标题输入框
        UIKitTextInput(
          text: $inputTitle,
          placeholder: "输入标题",
          inputType: .textField,
          font: UIFont.preferredFont(forTextStyle: .headline),
          onNext: {
            isTextEditorFocused = true
          }
        )
        .frame(height: titleHeight)
        .padding(.horizontal, 19)

        Divider()
          .background(Color.mainStyleBackgroundColor.opacity(0.3))
          .padding(.horizontal, 10)

        ZStack(alignment: .topLeading) {
          UIKitTextInput(
            text: $inputText,
            placeholder: "",
            inputType: .textEditor,
            font: UIFont.systemFont(ofSize: 16)
          )
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

// MARK: - 统一文本输入包装器

/// 输入类型枚举
enum TextInputType {
  case textField
  case textEditor
}

/// 统一 UIKit 文本输入包装器
struct UIKitTextInput: UIViewRepresentable {
  @Binding var text: String
  let placeholder: String
  let inputType: TextInputType
  let font: UIFont
  let onNext: (() -> Void)?

  init(
    text: Binding<String>,
    placeholder: String,
    inputType: TextInputType,
    font: UIFont,
    onNext: (() -> Void)? = nil
  ) {
    self._text = text
    self.placeholder = placeholder
    self.inputType = inputType
    self.font = font
    self.onNext = onNext
  }

  func makeUIView(context: Context) -> UIView {
    switch inputType {
    case .textField:
      return createTextField(context: context)
    case .textEditor:
      return createTextView(context: context)
    }
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    switch inputType {
    case .textField:
      if let textField = uiView as? UITextField, textField.text != text {
        textField.text = text
      }
    case .textEditor:
      if let textView = uiView as? UITextView, textView.text != text {
        textView.text = text
      }
    }
  }

  func makeCoordinator() -> TextInputCoordinator {
    TextInputCoordinator(self)
  }

  // MARK: - Private Methods

  private func createTextField(context: Context) -> UITextField {
    let textField = UITextField()
    textField.delegate = context.coordinator
    textField.placeholder = placeholder
    textField.font = font
    textField.backgroundColor = UIColor.clear
    textField.textColor = UIColor.label
    textField.returnKeyType = .next
    textField.inputAccessoryView = KeyboardToolbarFactory.createToolbar(
      coordinator: context.coordinator
    )

    context.coordinator.textField = textField
    return textField
  }

  private func createTextView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.delegate = context.coordinator
    textView.font = font
    textView.backgroundColor = UIColor.clear
    textView.textColor = UIColor.label
    textView.isScrollEnabled = true
    textView.isEditable = true
    textView.isUserInteractionEnabled = true
    textView.inputAccessoryView = KeyboardToolbarFactory.createToolbar(
      coordinator: context.coordinator
    )

    context.coordinator.textView = textView
    return textView
  }
}

// MARK: - 协调器

class TextInputCoordinator: NSObject, UITextFieldDelegate, UITextViewDelegate {
  let parent: UIKitTextInput
  weak var textField: UITextField?
  weak var textView: UITextView?

  init(_ parent: UIKitTextInput) {
    self.parent = parent
  }

  // MARK: - UITextFieldDelegate

  func textField(
    _ textField: UITextField,
    shouldChangeCharactersIn range: NSRange,
    replacementString string: String
  ) -> Bool {
    let newText =
      (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
    parent.text = newText
    return true
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    parent.onNext?()
    return true
  }

  // MARK: - UITextViewDelegate

  func textViewDidChange(_ textView: UITextView) {
    parent.text = textView.text
  }

  // MARK: - Toolbar Actions

  @objc func doneButtonTapped() {
    textField?.resignFirstResponder()
    textView?.resignFirstResponder()
  }

  @objc func pasteButtonTapped() {
    if let string = UIPasteboard.general.string {
      parent.text = string
      textField?.text = string
      textView?.text = string
    }
  }
}

// MARK: - 键盘工具栏 Factory
struct KeyboardToolbarFactory {
  static func createToolbar(coordinator: TextInputCoordinator) -> UIToolbar {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()

    let pasteButton = createPasteButton(coordinator: coordinator)
    let doneButton = createDoneButton(coordinator: coordinator)
    let flexSpace = UIBarButtonItem(
      barButtonSystemItem: .flexibleSpace,
      target: nil,
      action: nil
    )

    toolbar.items = [pasteButton, flexSpace, doneButton]
    return toolbar
  }

  private static func createPasteButton(coordinator: TextInputCoordinator) -> UIBarButtonItem {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.spacing = 4

    let imageView = UIImageView(image: UIImage(systemName: "doc.on.clipboard"))
    imageView.tintColor = UIColor.mainStyleBackgroundColor
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
    imageView.heightAnchor.constraint(equalToConstant: 16).isActive = true

    let label = UILabel()
    label.text = "粘贴自剪切板"
    label.textColor = UIColor.mainStyleBackgroundColor
    label.font = UIFont.systemFont(ofSize: 14)

    stackView.addArrangedSubview(imageView)
    stackView.addArrangedSubview(label)

    let tapGesture = UITapGestureRecognizer(
      target: coordinator,
      action: #selector(TextInputCoordinator.pasteButtonTapped)
    )
    stackView.addGestureRecognizer(tapGesture)
    stackView.isUserInteractionEnabled = true

    return UIBarButtonItem(customView: stackView)
  }

  private static func createDoneButton(coordinator: TextInputCoordinator) -> UIBarButtonItem {
    let button = UIBarButtonItem(
      title: "完成",
      style: .done,
      target: coordinator,
      action: #selector(TextInputCoordinator.doneButtonTapped)
    )
    button.tintColor = UIColor.mainStyleBackgroundColor
    return button
  }
}

// MARK: - Preview

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
