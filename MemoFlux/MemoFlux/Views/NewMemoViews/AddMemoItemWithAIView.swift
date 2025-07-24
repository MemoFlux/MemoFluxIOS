//
//  AddMemoItemWithAIView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import PhotosUI
import SwiftUI

struct AddMemoItemWithAIView: View {
  @Environment(\.dismiss) private var dismiss

  @State private var showingTextInput = false
  @State private var showingImagePicker = false
  @State private var showingCamera = false
  @State private var inputText = ""
  @State private var textEditorHeight: CGFloat = 60 * 3
  @State private var isHeightAdjusted = false  // 标记高度是否已调整
  @State private var keyboardShown = false

  @State private var selectedImage: UIImage?
  @State private var selectedPhotoItem: PhotosPickerItem?

  @FocusState private var isTextEditorFocused: Bool

  private let originalHeight: CGFloat = 180  // 原始高度

  var body: some View {
    NavigationStack {
      VStack(spacing: 10) {
        if !showingTextInput {
          TextInputButtonView {
            withAnimation {
              showingTextInput = true
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextEditorFocused = true
              }
            }
          }
          .padding(.bottom, 5)
        } else {
          TextEditorView(
            inputText: $inputText,
            textEditorHeight: $textEditorHeight,
            isHeightAdjusted: $isHeightAdjusted,
            showingTextInput: $showingTextInput,
            isTextEditorFocused: _isTextEditorFocused,
            originalHeight: originalHeight,
            calculateTextHeight: calculateTextHeight
          )
          .padding(.bottom, 5)
        }

        ImageActionButtonsView(
          cameraAction: { showingCamera = true },
          photoPickerAction: { showingImagePicker = true }
        )

        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: 5) {
            HStack {
              Text("* 暂时只能拍摄/选择一张照片")
                .font(.caption)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)

              NavigationLink(destination: AddShortcutView()) {
                HStack(spacing: 0) {
                  Text("推荐使用快捷指令！")
                  Image(systemName: "chevron.right.circle")
                }
              }
              .font(.caption)
              .padding(.trailing, 5)
            }

            if let image = selectedImage {
              withAnimation {
                Image(uiImage: image)
                  .resizable()
                  .scaledToFit()
                  .frame(height: 80)
                  .cornerRadius(15)
                  .contextMenu {
                    Button(
                      role: .destructive,
                      action: {
                        withAnimation {
                          selectedImage = nil
                          selectedPhotoItem = nil
                        }
                      }
                    ) {
                      Label("删除照片", systemImage: "trash")
                    }
                  }
              }
            }
          }
          .padding(.leading, 5)
        }
        .padding(.horizontal, 6)

        AnalysisModuleView()
          .padding(.top)

        Spacer()
      }
      .padding()
      .padding(.horizontal, 5)
      .navigationTitle("创建Memo")
      .fullScreenCover(isPresented: $showingCamera) {  // 相机调用
        CameraView(image: $selectedImage, isShown: $showingCamera)
          .ignoresSafeArea()
      }
      .photosPicker(  // 相册调用
        isPresented: $showingImagePicker,
        selection: $selectedPhotoItem,
        matching: .images,
        photoLibrary: .shared()
      )
      .onChange(of: selectedPhotoItem) { newItem in
        Task {
          if let data = try? await newItem?.loadTransferable(type: Data.self),
            let uiImage = UIImage(data: data)
          {
            withAnimation {
              selectedImage = uiImage
            }
          }
        }
      }
      .contentShape(Rectangle())  // 点击背景关闭键盘
      .onTapGesture {
        isTextEditorFocused = false
      }
      .onAppear {  // 监听键盘显示
        NotificationCenter.default.addObserver(
          forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main
        ) { _ in
          keyboardShown = true
        }
        NotificationCenter.default.addObserver(
          forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main
        ) { _ in
          keyboardShown = false
          // 键盘隐藏时调整高度
          if !inputText.isEmpty {
            withAnimation {
              textEditorHeight = calculateTextHeight()
              isHeightAdjusted = true
            }
          }
        }
      }
      .onDisappear {
        NotificationCenter.default.removeObserver(
          self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(
          self, name: UIResponder.keyboardWillHideNotification, object: nil)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("取消") {
            dismiss()
          }
        }
      }
    }
  }

  private func calculateTextHeight() -> CGFloat {
    let lineHeight: CGFloat = 25  // 估计的单行高度
    let minHeight: CGFloat = lineHeight  // 最小高度为一行

    if inputText.isEmpty {
      return minHeight
    }

    // 行数
    let lines = inputText.components(separatedBy: "\n").count
    // 每行平均字符数
    let avgCharsPerLine: CGFloat = 30
    // 额外行数
    let additionalLines = inputText.count / Int(avgCharsPerLine)

    // 总行数
    let totalLines = max(lines, 1) + additionalLines
    // 限制最大高度
    let maxHeight: CGFloat = 60 * 3

    return min(max(CGFloat(totalLines) * lineHeight, minHeight), maxHeight)
  }
}

#Preview {
  NavigationStack {
    AddMemoItemWithAIView()
  }
}
