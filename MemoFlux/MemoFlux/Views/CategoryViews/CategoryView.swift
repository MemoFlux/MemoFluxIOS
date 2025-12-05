//
//  CategoryView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftData
import SwiftUI

struct CategoryView: View {
  @ObservedObject private var languageManager = LanguageManager.shared
  @Environment(\.modelContext) private var modelContext
  @Query private var memos: [MemoItemModel]
  @Query private var tagModels: [TagModel]
  
  @State private var sortOption: SortOption = .count
  
  enum SortOption {
    case name
    case count
  }
  
  // 计算所有唯一的标签（从TagModel获取，如果为空则从Memo获取）
  private var allTags: [String] {
    let tags: [String]
    if !tagModels.isEmpty {
      tags = tagModels.map { $0.name }
    } else {
      // 兼容性：如果TagModel为空，从Memo获取
      let tagSet = Set(memos.flatMap { $0.tags })
      tags = Array(tagSet)
    }
    
    switch sortOption {
    case .name:
      return tags.sorted()
    case .count:
      return tags.sorted {
        let count1 = tagUsageCount(for: $0)
        let count2 = tagUsageCount(for: $1)
        if count1 == count2 {
          return $0 < $1
        }
        return count1 > count2
      }
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
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          // 顶部标题和排序按钮
          HStack {
            Text(AppStrings.tagCategories)
              .font(.title2)
              .fontWeight(.bold)
            
            Spacer()
            
            Menu {
              Button {
                sortOption = .count
              } label: {
                if sortOption == .count {
                  Label(AppStrings.sortByCount, systemImage: "checkmark")
                } else {
                  Text(AppStrings.sortByCount)
                }
              }
              
              Button {
                sortOption = .name
              } label: {
                if sortOption == .name {
                  Label(AppStrings.sortByName, systemImage: "checkmark")
                } else {
                  Text(AppStrings.sortByName)
                }
              }
            } label: {
              HStack(spacing: 4) {
                Text(AppStrings.sortBy)
                Image(systemName: "chevron.down")
                  .font(.caption)
              }
              .font(.subheadline)
              .foregroundColor(.gray)
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background(Color.grayBackgroundColor.opacity(0.5))
              .cornerRadius(16)
            }
          }
          .padding(.horizontal)
          .padding(.top)
          
          // 空状态
          if allTags.isEmpty {
            emptyStateView
          } else {
            // 标签流式布局
            CategoryFlowLayout(spacing: 12) {
              ForEach(allTags, id: \.self) { tag in
                NavigationLink(destination: TagMemoListView(tag: tag)) {
                  CategoryTagChipView(tag: tag, count: memoCount(for: tag))
                }
              }
            }
            .padding(.horizontal)
          }
        }
      }
      .background(Color.globalStyleBackgroundColor)
      .navigationTitle(AppStrings.tabCategory) // 使用 TabBar 的标题或者 tagCategories
      .navigationBarTitleDisplayMode(.inline)
      .onAppear {
        // 确保TagModel与现有Memo中的标签同步
        syncTagsFromMemosToTagModel()
      }
    }
  }
  
  private var emptyStateView: some View {
    VStack(spacing: 16) {
      Image(systemName: "tag.slash")
        .font(.system(size: 48))
        .foregroundColor(.gray)
      
      Text(AppStrings.noTags)
        .font(.title2)
        .foregroundColor(.gray)
      
      Text(AppStrings.tagsDescription)
        .font(.caption)
        .foregroundColor(.gray)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 100)
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

// MARK: - Tag Chip View
struct CategoryTagChipView: View {
  let tag: String
  let count: Int
  
  // 预定义的柔和颜色方案 (背景色, 文字色)
  private let colorPairs: [(Color, Color)] = [
    (Color(red: 254/255, green: 226/255, blue: 226/255), Color(red: 220/255, green: 38/255, blue: 38/255)), // Red
    (Color(red: 254/255, green: 243/255, blue: 199/255), Color(red: 217/255, green: 119/255, blue: 6/255)), // Amber
    (Color(red: 220/255, green: 252/255, blue: 231/255), Color(red: 22/255, green: 163/255, blue: 74/255)), // Green
    (Color(red: 219/255, green: 234/255, blue: 254/255), Color(red: 37/255, green: 99/255, blue: 235/255)), // Blue
    (Color(red: 224/255, green: 231/255, blue: 255/255), Color(red: 79/255, green: 70/255, blue: 229/255)), // Indigo
    (Color(red: 243/255, green: 232/255, blue: 255/255), Color(red: 147/255, green: 51/255, blue: 234/255)), // Purple
    (Color(red: 252/255, green: 231/255, blue: 243/255), Color(red: 219/255, green: 39/255, blue: 119/255)), // Pink
    (Color(red: 255/255, green: 237/255, blue: 213/255), Color(red: 234/255, green: 88/255, blue: 12/255)), // Orange
    (Color(red: 207/255, green: 250/255, blue: 254/255), Color(red: 8/255, green: 145/255, blue: 178/255)), // Cyan
    (Color(red: 241/255, green: 245/255, blue: 249/255), Color(red: 71/255, green: 85/255, blue: 105/255))  // Slate
  ]
  
  private var colors: (Color, Color) {
    let index = abs(tag.hashValue) % colorPairs.count
    return colorPairs[index]
  }
  
  var body: some View {
    HStack(spacing: 6) {
      Text("# \(tag)")
        .font(.system(size: 16, weight: .medium))
      
//      if count > 0 {
//        Text("\(count)")
//          .font(.system(size: 12))
//          .padding(.horizontal, 6)
//          .padding(.vertical, 2)
//          .background(Color.white.opacity(0.5))
//          .cornerRadius(8)
//      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(colors.0)
    .foregroundColor(colors.1)
    .cornerRadius(12)
  }
}

// MARK: - Flow Layout (Copied locally to ensure independence)
struct CategoryFlowLayout: Layout {
  var spacing: CGFloat
  
  init(spacing: CGFloat = 8) {
    self.spacing = spacing
  }
  
  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
    let result = arrangeSubviews(proposal: proposal, subviews: subviews)
    return result.size
  }
  
  func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void
  ) {
    let result = arrangeSubviews(proposal: proposal, subviews: subviews)
    
    for (index, position) in result.positions.enumerated() {
      let point = CGPoint(x: position.x + bounds.minX, y: position.y + bounds.minY)
      subviews[index].place(at: point, proposal: ProposedViewSize(result.sizes[index]))
    }
  }
  
  private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (
    positions: [CGPoint], sizes: [CGSize], size: CGSize
  ) {
    guard !subviews.isEmpty else { return ([], [], .zero) }
    
    let maxWidth = proposal.width ?? .infinity
    var positions: [CGPoint] = []
    var sizes: [CGSize] = []
    
    var currentX: CGFloat = 0
    var currentY: CGFloat = 0
    var lineHeight: CGFloat = 0
    
    for subview in subviews {
      let size = subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
      sizes.append(size)
      
      // 换行
      if currentX + size.width > maxWidth, currentX > 0 {
        currentX = 0
        currentY += lineHeight + spacing
        lineHeight = 0
      }
      
      positions.append(CGPoint(x: currentX, y: currentY))
      lineHeight = max(lineHeight, size.height)
      currentX += size.width + spacing
    }
    
    let totalHeight = currentY + lineHeight
    return (positions, sizes, CGSize(width: maxWidth, height: totalHeight))
  }
}

// MARK: - 标签相关的 Memo 列表视图
struct TagMemoListView: View {
  let tag: String
  @ObservedObject private var languageManager = LanguageManager.shared
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
          
          Text(AppStrings.noRelatedMemos)
            .font(.title2)
            .foregroundColor(.gray)
          
          Text(AppStrings.noMemosWithTag(tag))
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
    .navigationTitle(AppStrings.tagTitle(tag))
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
        Text(memo.title.isEmpty ? AppStrings.noTitle : memo.title)
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
