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
  
  // 按日期分组
  private var groupedItems: [(String, [MemoItemModel])] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: memoItems) { item in
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
      NavigationStack {
        ScrollView {
          LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
            ForEach(groupedItems, id: \.0) { section in
              Section {
                LazyVStack(spacing: 12) {
                  ForEach(section.1) { item in
                    NavigationLink(destination: ListCellDetailView(item: item)) {
                      MemoCardView(item: item, modelContext: modelContext)
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
        .navigationTitle("Memo")
        .background(Color.globalStyleBackgroundColor)
      }
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
  
  @State private var textHeight: CGFloat = 0
  @State private var imageHeight: CGFloat = 0
  
  private var isPortrait: Bool {
    guard let image = item.image else { return false }
    let aspectRatio = image.size.width / image.size.height
    return aspectRatio < 0.85
  }
  
  var body: some View {
    VStack(spacing: 0) {
      if isPortrait {
        // 横向布局
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
        // 纵向布局
        VStack(alignment: .leading, spacing: 12) {
          imageView
          contentView
          timeSourceView
        }
        .padding(16)
      }
    }
    .background(Color.white)
    .cornerRadius(16)
    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    .onAppear {
      if item.recognizedText.isEmpty, let image = item.image {
        recognizeText(for: item, image: image)
      }
    }
  }
  
  private var contentView: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(item.title.isEmpty ? "默认标题" : item.title)
        .font(.system(size: 16, weight: .bold))
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(2)
      
      if !item.recognizedText.isEmpty {
        Text(item.recognizedText)
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
      } else {
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
      } else {
        Rectangle()
          .fill(Color.gray.opacity(0.3))
          .cornerRadius(12)
          .overlay(Image(systemName: "photo").foregroundColor(.gray))
      }
    }
  }
  
  // TODO: - 高度计算待优化
  // MARK: - 文本高度行数计算
  /// 注意：isPortrait表示图片是纵向的，但布局逻辑中：
  /// isPortrait = true 时使用横向布局（图片在左，文本在右）
  /// isPortrait = false 时使用纵向布局（图片在上，文本在下）
  private func getTextLineLimit() -> Int? {
    
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
              Text(tag)
                .font(.system(size: 12))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.gray.opacity(0.1))
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
  
  return MemoListView(memoItems: testItems, modelContext: context)
    .modelContainer(container)
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

