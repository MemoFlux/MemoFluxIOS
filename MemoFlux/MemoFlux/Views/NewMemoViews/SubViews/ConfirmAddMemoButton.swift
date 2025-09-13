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
    
    // 如果有API响应，设置API响应数据，但不自动添加AI建议的标签
    if let response = apiResponse {
      newMemo.setAPIResponse(response, in: modelContext)
      // 移除自动合并AI标签的逻辑，只保留用户选中的标签
      // 用户选中的标签已经在上面的MemoItemModel初始化时设置了
    }
    
    modelContext.insert(newMemo)
    
    do {
      try modelContext.save()
      print("Memo保存成功")
      
      // 移除在创建Memo时发送API请求的逻辑
      // API请求只应该在"解析"按钮上触发，而不是在"创建Memo"按钮上
      isSaving = false
      onSave()
      
    } catch {
      print("保存 Memo 失败: \(error)")
      isSaving = false
    }
  }
  
  // MARK: - 以下方法已不再使用
  /*
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
   
   private func handleAPIResponse(result: Result<APIResponse, NetworkError>, memoItem: MemoItemModel)
   {
   switch result {
   case .success(let response):
   print("API请求成功")
   
   memoItem.setAPIResponse(response)
   
   // 移除自动添加AI建议标签的逻辑
   // 保持memo的标签为用户选中的标签，不自动添加AI建议的标签
   // let newTags = Set(memoItem.tags)
   //   .union(response.knowledge.tags)
   //   .union(response.information.tags)
   //   .union(response.schedule.tasks.flatMap { $0.tags })
   // memoItem.tags = Array(newTags)
   
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
   */
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
