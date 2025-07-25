//
//  MemoListView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftData
import SwiftUI
import Vision
import VisionKit

struct MemoListView: View {
  let memoItems: [MemoItemModel]
  let modelContext: ModelContext
  
  // 搜索相关状态
  @State private var searchText = ""
  @Binding var isSearchActive: Bool
  
  // 初始化方法，支持可选的搜索状态绑定
  init(memoItems: [MemoItemModel], modelContext: ModelContext, isSearchActive: Binding<Bool>? = nil)
  {
    self.memoItems = memoItems
    self.modelContext = modelContext
    self._isSearchActive = isSearchActive ?? .constant(false)
  }
  
  // 过滤后的备忘录
  private var filteredItems: [MemoItemModel] {
    if searchText.isEmpty {
      return memoItems
    } else {
      return memoItems.filter { item in
        // 搜索标题
        item.title.localizedCaseInsensitiveContains(searchText)
        // 搜索识别文本
        || item.recognizedText.localizedCaseInsensitiveContains(searchText)
        // 搜索标签
        || item.tags.contains { tag in
          tag.localizedCaseInsensitiveContains(searchText)
        }
        // 搜索来源
        || item.source.localizedCaseInsensitiveContains(searchText)
      }
    }
  }
  
  // 按日期分组
  private var groupedItems: [(String, [MemoItemModel])] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: filteredItems) { item in
      if calendar.isDateInToday(item.createdAt) {
        return "今天"
      } else if calendar.isDateInYesterday(item.createdAt) {
        return "昨天"
      } else {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: item.createdAt)
      }
    }
    
    return grouped.sorted { first, second in
      if first.key == "今天" { return true }
      if second.key == "今天" { return false }
      if first.key == "昨天" { return true }
      if second.key == "昨天" { return false }
      return first.key > second.key
    }
  }
  
  var body: some View {
    if memoItems.isEmpty {
      ContentUnavailableView(
        "没有内容", systemImage: "photo", description: Text("请从快捷指令或其他来源导入内容。"))
    } else {
      VStack(spacing: 0) {
        if !searchText.isEmpty && filteredItems.isEmpty {
          ContentUnavailableView(
            "没有找到相关内容",
            systemImage: "magnifyingglass",
            description: Text("尝试使用其他关键词搜索")
          )
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          ScrollView {
            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
              ForEach(groupedItems, id: \.0) { section in
                Section {
                  LazyVStack(spacing: 12) {
                    ForEach(section.1) { item in
                      NavigationLink(destination: ListCellDetailView(item: item)) {
                        MemoCardView(
                          item: item,
                          modelContext: modelContext,
                          searchText: searchText
                        )
                      }
                      .buttonStyle(PlainButtonStyle())
                    }
                  }
                  .padding(.horizontal, 16)
                } header: {
                  SectionHeaderView(title: section.0)
                }
              }
            }
            .padding(.top, 8)
          }
        }
      }
      .navigationTitle("Memo")
      .background(Color.globalStyleBackgroundColor)
      .searchable(
        text: $searchText,
        isPresented: $isSearchActive,
        placement: .navigationBarDrawer(displayMode: .automatic),
        prompt: "搜索Memo..."
      )
    }
  }
}

/// 分组标题视图
struct SectionHeaderView: View {
  let title: String
  
  var body: some View {
    HStack {
      Text(title)
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.primary)
        .padding(.leading, 21)
      
      Rectangle()
        .fill(Color.gray.opacity(0.3))
        .frame(height: 1)
        .padding(.leading, 8)
    }
    .padding(.vertical, 8)
    .background(Color.globalStyleBackgroundColor)
  }
}

/// 独立的卡片 Cell 视图
struct MemoCardView: View {
  let item: MemoItemModel
  let modelContext: ModelContext
  let searchText: String
  
  @State private var textHeight: CGFloat = 0
  @State private var imageHeight: CGFloat = 0
  
  // 初始化方法，searchText 参数可选
  init(item: MemoItemModel, modelContext: ModelContext, searchText: String = "") {
    self.item = item
    self.modelContext = modelContext
    self.searchText = searchText
  }
  
  private var isPortrait: Bool {
    guard let image = item.image else { return false }
    let aspectRatio = image.size.width / image.size.height
    return aspectRatio < 0.85
  }
  
  // 判断是否有图片
  private var hasImage: Bool {
    return item.image != nil
  }
  
  var body: some View {
    VStack(spacing: 0) {
      if hasImage {
        // 有图片时的布局
        if isPortrait {
          // 横向布局（图片在左，文本在右）
          VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
              imageView
                .frame(width: 120)
              contentView
            }
            
            timeSourceView
          }
          .padding(16)
        } else {
          // 纵向布局（图片在上，文本在下）
          VStack(alignment: .leading, spacing: 12) {
            imageView
            contentView
            timeSourceView
          }
          .padding(16)
        }
      } else {
        // 纯文本布局（无图片）
        VStack(alignment: .leading, spacing: 12) {
          contentView
          timeSourceView
        }
        .padding(16)
      }
    }
    .background(Color.white)
    .cornerRadius(16)
    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    .contextMenu {
      // 编辑按钮
      Button {
        // TODO: 实现编辑逻辑
        print("编辑 Memo: \(item.title)")
      } label: {
        Label("编辑", systemImage: "pencil.line")
      }
      .tint(.black)
      
      // 删除按钮
      Button(role: .destructive) {
        deleteMemo()
      } label: {
        Label("删除", systemImage: "trash")
      }
    }
    .onAppear {
      if item.recognizedText.isEmpty, let image = item.image {
        recognizeText(for: item, image: image)
      }
    }
  }
  
  // MARK: - 删除 Memo
  private func deleteMemo() {
    withAnimation {
      modelContext.delete(item)
      
      do {
        try modelContext.save()
      } catch {
        print("删除 Memo 失败: \(error)")
      }
    }
  }
  
  private var contentView: some View {
    VStack(alignment: .leading, spacing: 8) {
      // 高亮显示搜索结果的标题
      HighlightedText(
        text: item.title.isEmpty ? "无标题" : item.title,
        searchText: searchText
      )
      .font(.system(size: 16, weight: .bold))
      .foregroundColor(.primary)
      .frame(maxWidth: .infinity, alignment: .leading)
      .lineLimit(2)
      
      if !item.recognizedText.isEmpty {
        // 高亮显示搜索结果的识别文本
        HighlightedText(
          text: item.recognizedText,
          searchText: searchText
        )
        .font(.system(size: 14))
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(getTextLineLimit())
        .background(
          GeometryReader { geo in
            Color.clear.onAppear {
              textHeight = geo.size.height
            }
          })
      } else if hasImage {
        // 只有在有图片时才显示"正在识别文字..."
        Text("正在识别文字...")
          .font(.system(size: 14))
          .foregroundColor(.secondary)
      }
    }
  }
  
  private var imageView: some View {
    Group {
      if let image = item.image {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
          .cornerRadius(12)
          .background(
            GeometryReader { geo in
              Color.clear.onAppear {
                imageHeight = geo.size.height
              }
            })
      }
    }
  }
  
  // MARK: - 文本高度行数计算
  private func getTextLineLimit() -> Int? {
    // 如果没有图片，使用更多行数显示文本
    if !hasImage {
      return 8  // 纯文本 Memo 可以显示更多行
    }
    
    if !isPortrait {
      // 纵向布局
      return 5
    } else {
      // 横向布局
      if imageHeight == 0 {
        return 5
      }
      
      // 标题高度估算
      let titleLineHeight: CGFloat = 20  // 16pt字体的行高约20pt
      let estimatedTitleHeight: CGFloat = item.title.isEmpty ? 0 : (titleLineHeight * 2 + 8)  // 2行标题 + 8pt间距
      
      let textLineHeight: CGFloat = 18  // 14pt字体的行高约18pt
      
      // 计算可用于文本内容的高度
      let bottomAreaHeight: CGFloat = 40
      let totalSpacing: CGFloat = 8
      
      // 图片高度 - 标题高度 - 底部标签和时间区域高度 - 各种间距
      let availableTextHeight = imageHeight - estimatedTitleHeight - bottomAreaHeight - totalSpacing
      
      // 最大行数
      let maxLines = max(5, Int(availableTextHeight / textLineHeight))
      
      return min(maxLines + 2, 20)
    }
  }
  
  // MARK: - 底部信息视图
  private var timeSourceView: some View {
    HStack(alignment: .bottom) {
      VStack(alignment: .leading, spacing: 4) {
        if !item.tags.isEmpty {
          FlowLayout(spacing: 6) {
            ForEach(item.tags, id: \.self) { tag in
              // 高亮显示搜索结果的标签
              HighlightedText(text: tag, searchText: searchText)
                .font(.system(size: 12))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                  // 如果标签匹配搜索文本，使用高亮背景色
                  tag.localizedCaseInsensitiveContains(searchText) && !searchText.isEmpty
                  ? Color.mainStyleBackgroundColor.opacity(0.2)
                  : Color.gray.opacity(0.1)
                )
                .cornerRadius(5)
                .foregroundColor(.secondary)
            }
          }
        }
      }
      
      Spacer()
      
      Text(timeString(from: item.createdAt))
        .font(.system(size: 12))
        .foregroundColor(.secondary)
    }
  }
  
  // MARK: - 时间格式化Str
  private func timeString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
  }
  
  // MARK: - 文字识别
  private func recognizeText(for item: MemoItemModel, image: UIImage) {
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
        item.recognizedText = text
        try? modelContext.save()
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
}

// MARK: - 高亮文本组件
/// 用于高亮显示搜索结果的文本组件
struct HighlightedText: View {
  let text: String
  let searchText: String
  
  var body: some View {
    if searchText.isEmpty {
      Text(text)
    } else {
      let attributedString = createHighlightedAttributedString()
      Text(AttributedString(attributedString))
    }
  }
  
  private func createHighlightedAttributedString() -> NSAttributedString {
    let attributedString = NSMutableAttributedString(string: text)
    let range = NSRange(location: 0, length: text.count)
    
    // 设置默认属性
    attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: range)
    
    // 查找并高亮匹配的文本
    let searchRange = text.lowercased().range(of: searchText.lowercased())
    if let searchRange = searchRange {
      let nsRange = NSRange(searchRange, in: text)
      attributedString.addAttribute(
        .backgroundColor, value: UIColor.systemYellow.withAlphaComponent(0.3), range: nsRange)
      attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: nsRange)
    }
    
    return attributedString
  }
}

// MARK: - Tag多行显示
/// 流式布局容器，实现 Tag 多行显示
struct FlowLayout: Layout {
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

// MARK: - 预览相关
#Preview {
  // 测试用 ModelContext
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: MemoItemModel.self, configurations: config)
  let context = container.mainContext
  
  let testItems = createTestMemoItems()
  
  for item in testItems {
    context.insert(item)
  }
  
  // 创建搜索状态绑定
  @State var isSearchActive = false
  
  return NavigationStack {
    MemoListView(
      memoItems: testItems,
      modelContext: context,
      isSearchActive: $isSearchActive
    )
  }
  .modelContainer(container)
  .preferredColorScheme(.light) // 确保使用浅色模式进行预览
}

// 测试数据辅助函数
private func createTestMemoItems() -> [MemoItemModel] {
  let calendar = Calendar.current
  
  // 创建不同尺寸的测试图片
  let portraitImage = createTestImage(width: 300, height: 400, color: .systemBlue)
  let landscapeImage = createTestImage(width: 400, height: 300, color: .systemGreen)
  let squareImage = createTestImage(width: 300, height: 300, color: .systemOrange)
  
  return [
    // 今天
    MemoItemModel(
      imageData: portraitImage.pngData(),
      recognizedText: "产品设计周会要点记录\n\n讨论了新版App的交互设计方案，重点关注用户引导流程和首页信息展示的优化。确定了下一阶段的开发重点。",
      title: "产品设计周会",
      tags: ["会议", "产品"],
      createdAt: Date(),
      source: "备忘录"
    ),
    
    MemoItemModel(
      imageData: landscapeImage.pngData(),
      recognizedText: "用户调研数据分析结果\n\n根据最新一轮用户调研，80%的用户对新增的智能分类功能表示满意，但对搜索体验仍有改进需求。建议优化搜索算法。",
      title: "用户调研分析",
      tags: ["数据", "用户"],
      createdAt: calendar.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
      source: "邮件"
    ),
    
    MemoItemModel(
      imageData: squareImage.pngData(),
      recognizedText: "短文本测试",
      title: "简短内容",
      tags: ["测试"],
      createdAt: calendar.date(byAdding: .hour, value: -4, to: Date()) ?? Date(),
      source: "快捷指令"
    ),
    
    // 昨天
    MemoItemModel(
      imageData: portraitImage.pngData(),
      recognizedText:
        "竞品分析：同类App功能对比\n\n对市场上5款同类信息收集App进行了功能和用户体验对比，我们在信息处理速度上有优势，但在多设备同步方面需要改进。\n\n主要发现：\n1. 竞品A的搜索功能更强大\n2. 竞品B的界面设计更简洁\n3. 我们的OCR识别准确率最高\n竞品分析：同类App功能对比\n\n对市场上5款同类信息收集App进行了功能和用户体验对比，我们在信息处理速度上有优势，但在多设备同步方面需要改进。\n\n主要发现：\n1. 竞品A的搜索功能更强大\n2. 竞品B的界面设计更简洁\n3. 我们的OCR识别准确率最高",
      title: "竞品分析报告",
      tags: ["竞品", "分析"],
      createdAt: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
      source: "文档"
    ),
    
    MemoItemModel(
      imageData: landscapeImage.pngData(),
      recognizedText: "项目进度更新：信息流优化\n\n信息流算法优化已完成70%，预计下周可以进入内测阶段。重点解决了信息重复和相关性排序问题。",
      title: "项目进度更新",
      tags: ["项目", "开发"],
      createdAt: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
      source: "工作群"
    ),
    
    // 更早
    MemoItemModel(
      imageData: squareImage.pngData(),
      recognizedText:
        "这是一个很长的文本内容，用来测试当文本内容很多时，卡片的布局是否能够正确显示。这段文本包含了多行内容，可以测试文本的换行和高度自适应功能。我们需要确保无论文本多长，卡片都能正确显示，并且保持良好的视觉效果。",
      title: "长文本测试",
      tags: ["测试", "长文本"],
      createdAt: calendar.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
      source: "测试数据"
    ),
  ]
}

// 测试图片辅助函数
private func createTestImage(width: CGFloat, height: CGFloat, color: UIColor) -> UIImage {
  let size = CGSize(width: width, height: height)
  let renderer = UIGraphicsImageRenderer(size: size)
  
  return renderer.image { context in
    color.setFill()
    context.fill(CGRect(origin: .zero, size: size))
    
    let text = "测试图片\n\(Int(width))×\(Int(height))"
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 16, weight: .medium),
      .foregroundColor: UIColor.white,
    ]
    
    let textSize = text.size(withAttributes: attributes)
    let textRect = CGRect(
      x: (width - textSize.width) / 2,
      y: (height - textSize.height) / 2,
      width: textSize.width,
      height: textSize.height
    )
    
    text.draw(in: textRect, withAttributes: attributes)
  }
}
