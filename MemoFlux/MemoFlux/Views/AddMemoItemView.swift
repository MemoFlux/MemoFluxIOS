//
//  AddMemoItemView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import PhotosUI
import SwiftUI

// MARK: - 主视图
struct AddMemoItemView: View {
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
          TextInputButton {
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
        
        ImageActionButtons(
          cameraAction: { showingCamera = true },
          photoPickerAction: { showingImagePicker = true }
        )
        
        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: 5) {
            HStack {
              Text("* 暂时只能拍摄/选择一张照片")
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.leading, 5)
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
                  .cornerRadius(10)
                  .padding(.leading, 5)
              }
            }
          }
        }
        .padding(.horizontal, 6)
        
        Spacer()
      }
      .padding()
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

// MARK: - 输入文本按钮
struct TextInputButton: View {
  var action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        Image(systemName: "text.bubble")
        Text("输入/粘贴文本内容")
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 20)
    }
    .background(Color.mainStyleBackgroundColor)
    .foregroundStyle(.white)
    .cornerRadius(15)
    .padding(.horizontal, 5)
  }
}

// MARK: - 文本编辑器
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
          .padding(.horizontal, 5)
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

// MARK: - 图像操作按钮
struct ImageActionButtons: View {
  var cameraAction: () -> Void
  var photoPickerAction: () -> Void
  
  var body: some View {
    VStack(spacing: 10) {
      HStack(spacing: 10) {
        Button(action: cameraAction) {
          HStack {
            Image(systemName: "camera")
            Text("拍照")
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 20)
        }
        .foregroundStyle(.white)
        .background(Color.mainStyleBackgroundColor)
        .cornerRadius(15)
        
        Button(action: photoPickerAction) {
          HStack {
            Image(systemName: "photo")
            Text("从相册选择")
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 20)
        }
        .foregroundStyle(.white)
        .background(Color.mainStyleBackgroundColor)
        .cornerRadius(15)
      }
      .padding(.horizontal, 5)
    }
  }
}

// MARK: - 相机视图
struct CameraView: UIViewControllerRepresentable {
  @Binding var image: UIImage?
  @Binding var isShown: Bool
  
  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    
    // 相机可用性检查
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      picker.sourceType = .camera
    } else {
      // 若相机不可用，使用照片库
      picker.sourceType = .photoLibrary
    }
    
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let parent: CameraView
    
    init(_ parent: CameraView) {
      self.parent = parent
    }
    
    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      if let image = info[.originalImage] as? UIImage {
        DispatchQueue.main.async {
          withAnimation {
            self.parent.image = image
          }
        }
      }
      parent.isShown = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.isShown = false
    }
  }
}

#Preview {
  NavigationStack {
    AddMemoItemView()
  }
}
