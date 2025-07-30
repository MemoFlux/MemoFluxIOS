//
//  CategoryView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftData
import SwiftUI

struct CategoryView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var memos: [MemoItemModel]
  @Query private var tagModels: [TagModel]
  
  // 计算所有唯一的标签（从TagModel获取，如果为空则从Memo获取）
  private var allTags: [String] {
    if !tagModels.isEmpty {
      return tagModels.map { $0.name }.sorted()
    } else {
      // 兼容性：如果TagModel为空，从Memo获取
      let tagSet = Set(memos.flatMap { $0.tags })
      return Array(tagSet).sorted()
    }
  }
  
  // 计算每个标签对应的 Memo 数量
  private func memoCount(for tag: String) -> Int {
    return memos.filter { $0.tags.contains(tag) }.count
  }
  
  // 获取标签的使用频率（如果有TagModel）
  private func tagUsageCount(for tagName: String) -> Int {
    return tagModels.first { $0.name == tagName }?.usageCount ?? memoCount(for: tagName)
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        // 空状态
        if allTags.isEmpty {
          VStack(spacing: 16) {
            Image(systemName: "tag.slash")
              .font(.system(size: 48))
              .foregroundColor(.gray)
            
            Text("暂无标签")
              .font(.title2)
              .foregroundColor(.gray)
            
            Text("创建 Memo 时添加标签后，这里会显示所有标签")
              .font(.caption)
              .foregroundColor(.gray)
              .multilineTextAlignment(.center)
              .padding(.horizontal, 32)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          // 标签列表
          List(allTags, id: \.self) { tag in
            NavigationLink(destination: TagMemoListView(tag: tag)) {
              HStack {
                // 标签图标
                Image(systemName: "tag.fill")
                  .foregroundColor(.mainStyleBackgroundColor)
                  .frame(width: 20)
                
                // 标签名称
                Text(tag)
                  .font(.system(size: 16, weight: .medium))
                  .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(memoCount(for: tag))")
                  .font(.system(size: 14))
                  .foregroundColor(.gray)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(Color.grayBackgroundColor)
                  .cornerRadius(8)
              }
              .padding(.vertical, 4)
            }
          }
          .listStyle(PlainListStyle())
        }
      }
      .background(Color.globalStyleBackgroundColor)
      .navigationTitle("标签分类")
      .navigationBarTitleDisplayMode(.large)
      .onAppear {
        // 确保TagModel与现有Memo中的标签同步
        syncTagsFromMemosToTagModel()
      }
    }
  }
  
  // MARK: - 私有方法
  
  /// 同步Memo中的标签到TagModel
  private func syncTagsFromMemosToTagModel() {
    let allMemoTags = Set(memos.flatMap { $0.tags })
    let existingTagNames = Set(tagModels.map { $0.name })
    
    // 找出TagModel中缺少的标签
    let missingTags = allMemoTags.subtracting(existingTagNames)
    
    // 为缺少的标签创建TagModel
    for tagName in missingTags {
      TagManager.shared.createOrUpdateTag(name: tagName, in: modelContext)
    }
    
    // 保存更改
    do {
      try modelContext.save()
    } catch {
      print("同步标签到TagModel失败: \(error)")
    }
  }
}

// MARK: - 标签相关的 Memo 列表视图
struct TagMemoListView: View {
  let tag: String
  @Environment(\.modelContext) private var modelContext
  @Query private var allMemos: [MemoItemModel]
  
  // 过滤出包含指定标签的 Memo
  private var filteredMemos: [MemoItemModel] {
    return allMemos.filter { $0.tags.contains(tag) }
      .sorted { $0.createdAt > $1.createdAt }
  }
  
  var body: some View {
    VStack {
      if filteredMemos.isEmpty {
        // 空状态
        VStack(spacing: 16) {
          Image(systemName: "doc.text")
            .font(.system(size: 48))
            .foregroundColor(.gray)
          
          Text("暂无相关 Memo")
            .font(.title2)
            .foregroundColor(.gray)
          
          Text("还没有包含「\(tag)」标签的 Memo")
            .font(.caption)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        // Memo 列表
        List(filteredMemos) { memo in
          NavigationLink(destination: ListCellDetailView(item: memo)) {
            TagMemoRowView(memo: memo, highlightTag: tag)
          }
        }
        .listStyle(PlainListStyle())
      }
    }
    .background(Color.globalStyleBackgroundColor)
    .navigationTitle("标签 - \(tag)")
    .navigationBarTitleDisplayMode(.inline)
  }
}

// MARK: - 标签 Memo 行视图
struct TagMemoRowView: View {
  let memo: MemoItemModel
  let highlightTag: String
  
  var body: some View {
    HStack(spacing: 12) {
      // 图片或占位符
      if let image = memo.image {
        Image(uiImage: image)
          .resizable()
          .scaledToFill()
          .frame(width: 60, height: 60)
          .clipped()
          .cornerRadius(8)
      } else {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.grayBackgroundColor)
          .frame(width: 60, height: 60)
          .overlay(
            Image(systemName: "photo")
              .foregroundColor(.gray)
          )
      }
      
      // 内容区域
      VStack(alignment: .leading, spacing: 4) {
        // 标题
        Text(memo.title.isEmpty ? "无标题" : memo.title)
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(.primary)
          .lineLimit(1)
        
        // 内容预览
        if !memo.recognizedText.isEmpty {
          Text(memo.recognizedText)
            .font(.system(size: 14))
            .foregroundColor(.gray)
            .lineLimit(2)
        }
        
        // 标签和时间
        HStack {
          // 标签（高亮当前标签）
          HStack(spacing: 4) {
            ForEach(memo.tags.prefix(3), id: \.self) { tag in
              Text(tag)
                .font(.system(size: 12))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                  tag == highlightTag
                  ? Color.mainStyleBackgroundColor.opacity(0.2)
                  : Color.grayBackgroundColor
                )
                .foregroundColor(
                  tag == highlightTag
                  ? Color.mainStyleBackgroundColor
                  : Color.gray
                )
                .cornerRadius(4)
            }
            
            if memo.tags.count > 3 {
              Text("+\(memo.tags.count - 3)")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            }
          }
          
          Spacer()
          
          Text(memo.createdAt, style: .relative)
            .font(.system(size: 12))
            .foregroundColor(.gray)
        }
      }
      
      Spacer()
    }
    .padding(.vertical, 8)
  }
}

#Preview {
  CategoryView()
    .modelContainer(for: MemoItemModel.self, inMemory: true)
}
