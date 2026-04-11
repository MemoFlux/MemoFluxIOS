//
//  AddMemoItemView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import PhotosUI
import SwiftUI
import Vision
import Translation
import NaturalLanguage

struct AddMemoItemView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @ObservedObject private var languageManager = LanguageManager.shared
  @ObservedObject private var modelStore = AIModelStore.shared
  
  @State private var showingImagePicker = false
  @State private var showingCamera = false
  @State private var inputTitle = ""
  @State private var inputText = ""
  @State private var useAIParsing = true  // AI解析选项，默认开启
  @State private var selectedTags = Set<String>() // 选中标签
  
  @State private var selectedImage: UIImage?
  @State private var selectedPhotoItem: PhotosPickerItem?
  
  // 解析相关状态
  @State private var recognizedText = ""
  @State private var isParsingInProgress = false
  @State private var apiResponse: APIResponse?
  @State private var hasAttemptedParsing = false
  
  // 翻译相关状态
  @State private var translationConfig: Any?
  @State private var isTranslating = false
  
  // 图片处理相关状态
  @State private var imageBase64: String?
  @State private var isImageProcessing = false
  
  @FocusState private var isTextEditorFocused: Bool
  
  // 自定义初始化器，允许传入初始图片
  init(initialImage: UIImage? = nil) {
    if let image = initialImage {
      _selectedImage = State(initialValue: image)
    }
  }
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 10) {
          TextEditorView(
            inputText: $inputText,
            inputTitle: $inputTitle,
            isTextEditorFocused: _isTextEditorFocused,
            selectedModelName: modelStore.selectedModel.name
          )
          .padding(.bottom, 5)
          
          ImageActionButtonsView(
            cameraAction: { showingCamera = true },
            photoPickerAction: { showingImagePicker = true }
          )
          
          HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
              HStack {
                Text(AppStrings.onePhotoLimit)
                  .font(.caption)
                  .foregroundStyle(.gray)
                  .frame(maxWidth: .infinity, alignment: .leading)
                
                NavigationLink(destination: AddShortcutView()) {
                  HStack(spacing: 0) {
                    Text(AppStrings.recommendShortcut)
                    Image(systemName: "chevron.right.circle")
                  }
                }
                .font(.caption)
                .padding(.trailing, 5)
              }
              
              if let image = selectedImage {
                withAnimation {
                  VStack(alignment: .leading, spacing: 5) {
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
                              imageBase64 = nil
                              // 重置解析状态
                              apiResponse = nil
                              hasAttemptedParsing = false
                            }
                          }
                        ) {
                          Label(AppStrings.deletePhoto, systemImage: "trash")
                        }
                      }
                    
                    if isImageProcessing {
                      HStack {
                        ProgressView()
                          .scaleEffect(0.7)
                        Text(AppStrings.processingImage)
                          .font(.caption)
                          .foregroundColor(.secondary)
                      }
                    } else if imageBase64 != nil {
                      HStack {
                        Image(systemName: "checkmark.circle.fill")
                          .foregroundColor(.green)
                          .font(.caption)
                        Text(AppStrings.imageProcessed)
                          .font(.caption)
                          .foregroundColor(.secondary)
                      }
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
            isTranslating: isTranslating,
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
      .navigationTitle(AppStrings.createMemo)
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
              // 自动进行OCR识别和图片处理
              recognizeTextFromImage(uiImage)
              processImageForAPI(uiImage)
            }
          }
        }
      }
      .onChange(of: selectedImage) { newImage in
        if let image = newImage {
          recognizeTextFromImage(image)
          processImageForAPI(image)
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
      .onChange(of: imageBase64) { _ in
        if hasAttemptedParsing {
          apiResponse = nil
          hasAttemptedParsing = false
        }
      }
      // 如果初始有图片（例如从分享扩展进入），自动触发处理
      .onAppear {
        if let image = selectedImage {
          recognizeTextFromImage(image)
          processImageForAPI(image)
        }
      }
      .contentShape(Rectangle())  // 点击背景关闭键盘
      .onTapGesture {
        isTextEditorFocused = false
      }
      .modifier(TranslationApplier(config: translationConfig, action: { session in
        await translateResponse(session: session)
      }))
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(AppStrings.cancel) {
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
      return AppStrings.parsing
    } else if hasAttemptedParsing {
      return AppStrings.parseAgain
    } else {
      return AppStrings.parse
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
  
  // MARK: - 图片处理
  private func processImageForAPI(_ image: UIImage) {
    isImageProcessing = true
    
    ImageProcessor.shared.compressAndEncodeToBase64Async(image: image) { base64String in
      DispatchQueue.main.async {
        isImageProcessing = false
        imageBase64 = base64String
        
        if base64String == nil {
          print("图片处理失败")
        }
      }
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
  
  // MARK: - 判断是否有图片内容
  private func hasImageContent() -> Bool {
    return selectedImage != nil && imageBase64 != nil
  }
  
  // MARK: - 执行AI解析
  private func performAIParsing() {
    // 如果同时有图片和文字，优先解析图片
    if hasImageContent() {
      // 使用图片进行解析
      guard let image = selectedImage else { return }
      
      isParsingInProgress = true
      apiResponse = nil
      
      Task {
        do {
          let response = try await NetworkManager.shared.generateFromImageBase64(
            image: image,
            supplementaryText: inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
              ? nil : inputText,
            tags: TagManager.shared.getAllTagNames(from: modelContext),
            model: modelStore.selectedModel
          )
          
          await MainActor.run {
            isParsingInProgress = false
            hasAttemptedParsing = true
            apiResponse = response
            // 自动触发翻译
            triggerTranslation()
          }
        } catch {
          await MainActor.run {
            isParsingInProgress = false
            hasAttemptedParsing = true
            print("图片AI解析失败: \(error.localizedDescription)")
          }
        }
      }
    } else {
      // 没有图片时，使用文本进行解析
      let content = getContentForParsing()
      guard !content.isEmpty else { return }
      
      isParsingInProgress = true
      apiResponse = nil
      
      Task {
        do {
          let response = try await NetworkManager.shared.generateFromText(
            content,
            tags: TagManager.shared.getAllTagNames(from: modelContext),
            model: modelStore.selectedModel
          )
          
          await MainActor.run {
            isParsingInProgress = false
            hasAttemptedParsing = true
            apiResponse = response
            // 自动触发翻译
            triggerTranslation()
          }
        } catch {
          await MainActor.run {
            isParsingInProgress = false
            hasAttemptedParsing = true
            print("文本AI解析失败: \(error.localizedDescription)")
          }
        }
      }
    }
  }

  // MARK: - 翻译逻辑
  private func triggerTranslation() {
    if #available(iOS 18.0, *) {
      guard let response = apiResponse else { return }
      
      guard shouldTranslate(response) else {
        translationConfig = nil
        isTranslating = false
        print("🌐 Skip translation: AI response is already in English")
        return
      }
      
      translationConfig = TranslationSession.Configuration(target: Locale.Language(identifier: "en"))
    }
  }
  
  private func translateResponse(session: Any) async {
    guard #available(iOS 18.0, *), 
          let translationSession = session as? TranslationSession,
          var response = apiResponse else { return }
    
    await MainActor.run { isTranslating = true }
    
    let sourceStrings = response.allTranslatableStrings
    var translatedStrings = [String]()
    
    do {
      // 批量翻译
      let requests = sourceStrings.map { TranslationSession.Request(sourceText: $0) }
      let responses = try await translationSession.translations(from: requests)
      translatedStrings = responses.map { $0.targetText }
      
      await MainActor.run {
        response.applyTranslations(translatedStrings)
        self.apiResponse = response
        self.isTranslating = false
      }
    } catch {
      if String(describing: error).contains("unsupportedLanguagePairing") {
        await MainActor.run {
          self.translationConfig = nil
          self.isTranslating = false
        }
        print("🌐 Skip translation: unsupported language pairing")
        return
      }
      
      print("翻译失败: \(error)")
      await MainActor.run { isTranslating = false }
    }
  }
  
  private func shouldTranslate(_ response: APIResponse) -> Bool {
    let sourceStrings = response.allTranslatableStrings
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
    
    guard !sourceStrings.isEmpty else { return false }
    
    let combinedText = sourceStrings.joined(separator: "\n")
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(combinedText)
    
    if recognizer.dominantLanguage == .english {
      return false
    }
    
    return !isLikelyEnglishText(combinedText)
  }
  
  private func isLikelyEnglishText(_ text: String) -> Bool {
    let letters = text.unicodeScalars.filter { CharacterSet.letters.contains($0) }
    guard !letters.isEmpty else { return false }
    
    let nonASCII = letters.filter { !$0.isASCII }
    if nonASCII.isEmpty {
      return true
    }
    
    let nonASCIIRatio = Double(nonASCII.count) / Double(letters.count)
    return nonASCIIRatio < 0.15
  }
  
}

// MARK: - 辅助组件
struct TranslationApplier: ViewModifier {
  let config: Any?
  let action: @Sendable (Any) async -> Void
  
  func body(content: Content) -> some View {
    if #available(iOS 18.0, *), let translationConfig = config as? TranslationSession.Configuration {
      content.translationTask(translationConfig) { session in
        await action(session)
      }
    } else {
      content
    }
  }
}

#Preview {
  NavigationStack {
    AddMemoItemView()
  }
}
