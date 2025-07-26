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
  let apiResponse: APIResponse?  // 新增：API解析结果
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

    // 创建新的 MemoItemModel
    let newMemo: MemoItemModel

    if let image = image {
      // 如果有图片，使用图片初始化
      newMemo = MemoItemModel(
        image: image,
        title: title,
        tags: Array(tags),
        source: "手动创建"
      )
      // 设置识别的文本
      newMemo.recognizedText = text
    } else {
      // 如果没有图片，使用完整初始化方法
      newMemo = MemoItemModel(
        imageData: nil,
        recognizedText: text,
        title: title,
        tags: Array(tags),
        createdAt: Date(),
        source: "手动创建"
      )
    }

    // 如果有API解析结果，直接保存
    if let response = apiResponse {
      newMemo.setAPIResponse(response)

      // 更新标签（合并API返回的标签和用户选择的标签）
      let apiTags = Set(response.knowledge.tags)
        .union(response.information.tags)
        .union(response.schedule.tasks.flatMap { $0.tags })
      let finalTags = Set(tags).union(apiTags)
      newMemo.tags = Array(finalTags)
    }

    // 保存到 SwiftData
    modelContext.insert(newMemo)

    do {
      try modelContext.save()
      print("Memo保存成功")

      // 如果没有API解析结果，发送API请求
      if apiResponse == nil {
        sendAPIRequest(for: newMemo)
      } else {
        // 有API解析结果，直接完成保存
        isSaving = false
        onSave()
      }

    } catch {
      print("保存 Memo 失败: \(error)")
      isSaving = false
    }
  }

  private func sendAPIRequest(for memoItem: MemoItemModel) {
    // 标记开始API处理
    memoItem.startAPIProcessing()

    // 保存状态更新
    do {
      try modelContext.save()
    } catch {
      print("更新API处理状态失败: \(error)")
    }

    // 获取所有现有标签
    let allTags = NetworkManager.shared.getAllTags(from: modelContext)

    // 发送API请求
    NetworkManager.shared.generateAIResponse(
      content: memoItem.contentForAPI,
      tags: allTags,
      isImage: memoItem.image != nil
    ) { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let response):
          print("API请求成功")
          // 保存API响应到MemoItem
          memoItem.setAPIResponse(response)

          // 更新标签（合并API返回的标签）
          let newTags = Set(memoItem.tags)
            .union(response.knowledge.tags)
            .union(response.information.tags)
            .union(response.schedule.tasks.flatMap { $0.tags })
          memoItem.tags = Array(newTags)

        case .failure(let error):
          print("API请求失败: \(error.localizedDescription)")
          memoItem.apiProcessingFailed()
        }

        // 保存更新
        do {
          try modelContext.save()
          print("API响应保存成功")
        } catch {
          print("保存API响应失败: \(error)")
        }

        // 完成保存流程
        isSaving = false
        onSave()
      }
    }
  }
}

#Preview {
  // 创建一个模拟的 ModelContext 用于预览
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: MemoItemModel.self, configurations: config)
  let context = container.mainContext

  return ConfirmAddMemoButton(
    title: "测试标题",
    text: "这是一段测试文本内容，用于预览按钮的显示效果。",
    image: nil,
    tags: ["工作", "测试"],
    modelContext: context,
    apiResponse: nil,  // 新增参数
    onSave: {
      print("保存完成 - 这是预览模式")
    }
  )
  .padding()
  .background(Color.globalStyleBackgroundColor)
}
