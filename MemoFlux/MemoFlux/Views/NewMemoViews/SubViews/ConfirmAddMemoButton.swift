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
  let onSave: () -> Void
  
  var body: some View {
    Button {
      saveMemo()
    } label: {
      Text("创建 Memo")
        .font(.system(size: 14, weight: .medium))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.mainStyleBackgroundColor)
        .cornerRadius(12)
    }
    .padding(.top, 30)
  }
  
  private func saveMemo() {
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
    
    // 保存到 SwiftData
    modelContext.insert(newMemo)
    
    do {
      try modelContext.save()
      // 保存成功后调用回调
      onSave()
    } catch {
      print("保存 Memo 失败: \(error)")
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
    onSave: {
      print("保存完成 - 这是预览模式")
    }
  )
  .padding()
  .background(Color.globalStyleBackgroundColor)
}
