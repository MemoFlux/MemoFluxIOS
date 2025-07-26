//
//  AddMemoItemView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import PhotosUI
import SwiftUI
import UIKit
import Vision

struct AddMemoItemView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  
  @State private var showingImagePicker = false
  @State private var showingCamera = false
  @State private var inputTitle = ""
  @State private var inputText = ""
  @State private var useAIParsing = true  // AI解析选项，默认开启
  @State private var selectedTags: Set<String> = ["工作"]  // 添加选中标签状态
  
  @State private var selectedImage: UIImage?
  @State private var selectedPhotoItem: PhotosPickerItem?
  
  // 新增：解析相关状态
  @State private var recognizedText = ""
  @State private var isParsingInProgress = false
  @State private var apiResponse: APIResponse?
  @State private var hasAttemptedParsing = false
  
  @FocusState private var isTextEditorFocused: Bool
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 10) {
          TextEditorView(
            inputText: $inputText,
            inputTitle: $inputTitle,
            isTextEditorFocused: _isTextEditorFocused,
            useAIParsing: $useAIParsing
          )
          .padding(.bottom, 5)
          
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
                            recognizedText = ""
                            // 重置解析状态
                            apiResponse = nil
                            hasAttemptedParsing = false
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
          
          // MARK: - 解析视图
          if useAIParsing {
            parseButton
              .padding(.top, 10)
            
            AnalysisModuleView(apiResponse: apiResponse, isLoading: isParsingInProgress)
              .padding(.top, 10)
            
            IntentDetectView(apiResponse: apiResponse, isLoading: isParsingInProgress)
              .padding(.top, 10)
          }
          
          TagsSelectView(
            selectedTags: $selectedTags,
            useAIParsing: useAIParsing,
            apiResponse: apiResponse
          )
          .padding(.top, 10)
          
          ConfirmAddMemoButton(
            title: inputTitle,
            text: inputText,
            image: selectedImage,
            tags: selectedTags,
            modelContext: modelContext,
            apiResponse: apiResponse,
            useAIParsing: useAIParsing,
            onSave: {
              dismiss()
            }
          )
          
          // 保证内容不被键盘遮挡
          Spacer(minLength: 100)
        }
        .padding()
        .padding(.horizontal, 5)
      }
      .background(Color.globalStyleBackgroundColor)
      .ignoresSafeArea(.keyboard)
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
              // 自动进行OCR识别
              recognizeTextFromImage(uiImage)
            }
          }
        }
      }
      .onChange(of: selectedImage) { newImage in
        if let image = newImage {
          recognizeTextFromImage(image)
        }
      }
      // 监听文本变化，重置解析状态
      .onChange(of: inputText) { _ in
        if hasAttemptedParsing {
          apiResponse = nil
          hasAttemptedParsing = false
        }
      }
      .onChange(of: recognizedText) { _ in
        if hasAttemptedParsing {
          apiResponse = nil
          hasAttemptedParsing = false
        }
      }
      .contentShape(Rectangle())  // 点击背景关闭键盘
      .onTapGesture {
        isTextEditorFocused = false
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
  
  // MARK: - 解析按钮
  private var parseButton: some View {
    Button(action: performAIParsing) {
      HStack {
        if isParsingInProgress {
          ProgressView()
            .scaleEffect(0.8)
            .foregroundColor(.white)
        }
        Text(getParseButtonText())
          .font(.system(size: 14, weight: .medium))
      }
      .foregroundColor(.white)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .background(
        isParsingInProgress || getContentForParsing().isEmpty
        ? Color.gray.opacity(0.7) : Color.mainStyleBackgroundColor
      )
      .cornerRadius(15)
      .disabled(isParsingInProgress || getContentForParsing().isEmpty)
    }
  }
  
  // MARK: - 获取解析按钮文本
  private func getParseButtonText() -> String {
    if isParsingInProgress {
      return "解析中..."
    } else if hasAttemptedParsing {
      return "再次解析"
    } else {
      return "解析"
    }
  }
  
  // MARK: - OCR文字识别
  private func recognizeTextFromImage(_ image: UIImage) {
    let request = VNRecognizeTextRequest { (request, error) in
      guard error == nil else {
        print("文字识别错误: \(error!.localizedDescription)")
        return
      }
      
      guard let observations = request.results as? [VNRecognizedTextObservation] else {
        return
      }
      
      let recognizedStrings = observations.compactMap { observation in
        return observation.topCandidates(1).first?.string
      }
      
      let text = recognizedStrings.joined(separator: "\n")
      
      DispatchQueue.main.async {
        recognizedText = text
      }
    }
    
    request.recognitionLanguages = ["zh-CN", "en-US"]
    request.recognitionLevel = .accurate
    
    guard let cgImage = image.cgImage else { return }
    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    
    do {
      try requestHandler.perform([request])
    } catch {
      print("无法执行文字识别请求: \(error.localizedDescription)")
    }
  }
  
  // MARK: - 获取解析内容
  private func getContentForParsing() -> String {
    if !inputText.isEmpty {
      return inputText
    } else if !recognizedText.isEmpty {
      return recognizedText
    }
    return ""
  }
  
  // MARK: - 执行AI解析
  private func performAIParsing() {
    let content = getContentForParsing()
    guard !content.isEmpty else { return }
    
    isParsingInProgress = true
    apiResponse = nil
    
    NetworkManager.shared.generateFromText(content) { result in
      DispatchQueue.main.async {
        isParsingInProgress = false
        hasAttemptedParsing = true  // 已经尝试过解析操作
        
        switch result {
        case .success(let response):
          apiResponse = response
        case .failure(let error):
          print("AI解析失败: \(error.localizedDescription)")
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    AddMemoItemView()
  }
}
