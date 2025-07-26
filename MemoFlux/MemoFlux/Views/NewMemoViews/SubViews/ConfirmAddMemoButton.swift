//
//  ConfirmAddMemoButton.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/25.
//

import SwiftData
import SwiftUI

struct ConfirmAddMemoButton: View {
  let title: String
  let text: String
  let image: UIImage?
  let tags: Set<String>
  let modelContext: ModelContext
  let apiResponse: APIResponse?
  let useAIParsing: Bool
  let onSave: () -> Void
  
  @State private var isSaving = false
  
  var body: some View {
    Button {
      saveMemo()
    } label: {
      HStack {
        if isSaving {
          ProgressView()
            .scaleEffect(0.8)
            .foregroundColor(.white)
        }
        Text(isSaving ? "创建中..." : "创建 Memo")
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(.white)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .background(isSaving ? Color.gray : Color.mainStyleBackgroundColor)
      .cornerRadius(12)
    }
    .disabled(isSaving)
    .padding(.top, 30)
  }
  
  private func saveMemo() {
    isSaving = true
    
    let newMemo: MemoItemModel
    
    if let image = image {
      newMemo = MemoItemModel(
        image: image,
        title: title,
        tags: Array(tags),
        source: "手动创建"
      )
      
      // 如果有图片，将用户输入的文本保存为用户原文，OCR识别结果保存为recognizedText
      newMemo.userInputText = text
      // recognizedText 在 AddMemoItemView 中通过 OCR 自动设置
    } else {
      newMemo = MemoItemModel(
        imageData: nil,
        recognizedText: text,
        title: title,
        tags: Array(tags),
        createdAt: Date(),
        source: "手动创建"
      )
    }
    
    if let response = apiResponse {
      newMemo.setAPIResponse(response)
      
      let apiTags = Set(response.knowledge.tags)
        .union(response.information.tags)
        .union(response.schedule.tasks.flatMap { $0.tags })
      let finalTags = Set(tags).union(apiTags)
      newMemo.tags = Array(finalTags)
    }
    
    modelContext.insert(newMemo)
    
    do {
      try modelContext.save()
      print("Memo保存成功")
      
      // 根据useAIParsing决定是否发送API请求
      if useAIParsing && apiResponse == nil {
        sendAPIRequest(for: newMemo)
      } else {
        // 不使用AI解析或已有API解析结果，直接保存
        isSaving = false
        onSave()
      }
      
    } catch {
      print("保存 Memo 失败: \(error)")
      isSaving = false
    }
  }
  
  private func sendAPIRequest(for memoItem: MemoItemModel) {
    memoItem.startAPIProcessing()
    
    do {
      try modelContext.save()
    } catch {
      print("更新API处理状态失败: \(error)")
    }
    
    let allTags = NetworkManager.shared.getAllTags(from: modelContext)
    
    // 判断是否有图片，决定使用哪种API请求方式
    if let image = memoItem.image {
      // 有图片：使用图片Base64编码发送API请求
      NetworkManager.shared.generateFromImageBase64(image: image) { result in
        DispatchQueue.main.async {
          handleAPIResponse(result: result, memoItem: memoItem)
        }
      }
    } else {
      // 无图片：使用文本内容发送API请求
      NetworkManager.shared.generateAIResponse(
        content: memoItem.contentForAPI,
        tags: allTags,
        isImage: false
      ) { result in
        DispatchQueue.main.async {
          handleAPIResponse(result: result, memoItem: memoItem)
        }
      }
    }
  }
  
  // MARK: - 处理API响应（新增辅助方法）
  private func handleAPIResponse(result: Result<APIResponse, NetworkError>, memoItem: MemoItemModel) {
    switch result {
    case .success(let response):
      print("API请求成功")
      
      memoItem.setAPIResponse(response)
      
      let newTags = Set(memoItem.tags)
        .union(response.knowledge.tags)
        .union(response.information.tags)
        .union(response.schedule.tasks.flatMap { $0.tags })
      memoItem.tags = Array(newTags)
      
    case .failure(let error):
      print("API请求失败: \(error.localizedDescription)")
      memoItem.apiProcessingFailed()
    }
    
    do {
      try modelContext.save()
      print("API响应保存成功")
    } catch {
      print("保存API响应失败: \(error)")
    }
    
    isSaving = false
    onSave()
  }
}

// MARK: - 预览
#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: MemoItemModel.self, configurations: config)
  let context = container.mainContext
  
  ConfirmAddMemoButton(
    title: "测试标题",
    text: "这是一段测试文本内容，用于预览按钮的显示效果。",
    image: nil,
    tags: ["工作", "测试"],
    modelContext: context,
    apiResponse: nil,
    useAIParsing: true,
    onSave: {
      print("保存完成 - 这是预览模式")
    }
  )
  .padding()
  .background(Color.globalStyleBackgroundColor)
}
