//
//  TagsSelectView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/25.
//

import SwiftData
import SwiftUI

struct TagsSelectView: View {
  @Binding var selectedTags: Set<String>
  let useAIParsing: Bool
  let apiResponse: APIResponse?
  
  // 从SwiftData查询所有MemoItemModel
  @Query private var memoItems: [MemoItemModel]
  
  // 获取SwiftData的ModelContext用于保存数据
  @Environment(\.modelContext) private var modelContext
  
  // 添加自定义标签的状态
  @State private var showingAddTagAlert = false
  @State private var newTagName = ""
  
  // 计算AI建议的标签
  private var aiSuggestedTags: [String] {
    guard let response = apiResponse else { return [] }
    
    var allAITags = Set<String>()
    
    // 从knowledge获取标签
    allAITags.formUnion(response.information.tags)
    
    // 从information获取标签
    // allAITags.formUnion(response.information.tags)
    
    // 从schedule获取标签
    for task in response.schedule.tasks {
      allAITags.formUnion(task.tags)
    }
    
    return Array(allAITags).sorted()
  }
  
  // 从SwiftData中获取所有本地标签
  private var localTags: [String] {
    var allTags = Set<String>()
    for item in memoItems {
      allTags.formUnion(item.tags)
    }
    return Array(allTags).sorted()
  }
  
  // 判断标签是否被选中的逻辑
  private func isTagSelected(_ tag: String) -> Bool {
    // AI建议的标签默认选中，除非用户主动取消选择
    if useAIParsing && aiSuggestedTags.contains(tag) {
      return selectedTags.contains(tag)
    }
    // 本地标签需要用户手动选择
    return selectedTags.contains(tag)
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // 标题和添加自定义按钮
      HStack {
        Text("添加标签")
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.black)
        
        Spacer()
        
        Button("添加自定义") {
          showingAddTagAlert = true
        }
        .font(.system(size: 12))
        .foregroundColor(.mainStyleBackgroundColor)
      }
      .padding(.bottom, 8)
      .padding(.horizontal, 5)
      
      // 卡片容器
      VStack(alignment: .leading, spacing: 0) {
        
        // AI建议标签部分（仅在使用AI解析且有建议标签时显示）
        if useAIParsing && !aiSuggestedTags.isEmpty {
          VStack(alignment: .leading, spacing: 12) {
            // AI建议标签标题
            HStack(spacing: 6) {
              Image(systemName: "sparkles")
                .font(.system(size: 12))
                .foregroundColor(.blue)
              
              Text("AI 建议标签")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.blue)
            }
            
            // AI建议标签芯片 - 使用FlowLayout替代LazyVGrid
            FlowLayout(spacing: 8) {
              ForEach(aiSuggestedTags, id: \.self) { tag in
                TagChipView(
                  tag: tag,
                  isSelected: isTagSelected(tag)
                ) {
                  toggleTag(tag)
                }
              }
            }
          }
          .padding(.bottom, 16)
          
          // 分隔线
          Divider()
            .background(Color.gray.opacity(0.3))
            .padding(.bottom, 16)
        }
        
        // 本地标签部分
        VStack(alignment: .leading, spacing: 12) {
          if useAIParsing && !aiSuggestedTags.isEmpty {
            // 如果有AI建议标签，显示"本地标签"标题
            Text("本地标签")
              .font(.system(size: 12, weight: .medium))
              .foregroundColor(.secondary)
          }
          
          // 本地标签内容
          if localTags.isEmpty {
            // 没有本地标签时显示提示文字
            Text("暂无本地标签")
              .font(.system(size: 14))
              .foregroundColor(.secondary)
              .frame(maxWidth: .infinity, alignment: .center)
              .padding(.vertical, 20)
          } else {
            // 本地标签芯片布局 - 使用FlowLayout替代LazyVGrid
            FlowLayout(spacing: 8) {
              ForEach(localTags, id: \.self) { tag in
                TagChipView(
                  tag: tag,
                  isSelected: selectedTags.contains(tag)
                ) {
                  toggleTag(tag)
                }
              }
            }
          }
        }
      }
      .padding(16)
      .background(Color.grayBackgroundColor)
      .cornerRadius(16)
    }
    .onAppear {
      // 当有AI建议标签时，自动选中它们
      if useAIParsing && !aiSuggestedTags.isEmpty {
        for tag in aiSuggestedTags {
          selectedTags.insert(tag)
        }
      }
    }
    .onChange(of: aiSuggestedTags) { newTags in
      // 当AI建议标签更新时，自动选中新的标签
      if useAIParsing {
        for tag in newTags {
          selectedTags.insert(tag)
        }
      }
    }
    .alert("添加自定义标签", isPresented: $showingAddTagAlert) {
      TextField("输入标签名称", text: $newTagName)
        .textInputAutocapitalization(.never)
      
      Button("取消", role: .cancel) {
        newTagName = ""
      }
      
      Button("确认") {
        addCustomTag()
      }
      .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    } message: {
      Text("请输入新标签的名称")
    }
  }
  
  private func toggleTag(_ tag: String) {
    if selectedTags.contains(tag) {
      selectedTags.remove(tag)
    } else {
      selectedTags.insert(tag)
    }
  }
  
  private func addCustomTag() {
    let trimmedTagName = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // 检查标签名称是否为空
    guard !trimmedTagName.isEmpty else {
      newTagName = ""
      return
    }
    
    // 检查标签是否已存在
    guard !localTags.contains(trimmedTagName) && !aiSuggestedTags.contains(trimmedTagName) else {
      newTagName = ""
      return
    }
    
    // 创建一个临时的MemoItem来保存新标签
    // 这样可以确保标签被保存到SwiftData中，并在下次查询时显示
    let tempMemo = MemoItemModel(
      imageData: Data(),
      recognizedText: "",
      title: "临时标签存储",
      tags: [trimmedTagName],
      source: "custom_tag"
    )
    
    modelContext.insert(tempMemo)
    
    do {
      try modelContext.save()
      
      selectedTags.insert(trimmedTagName)
      
      newTagName = ""
    } catch {
      print("保存自定义标签失败: \(error)")
      newTagName = ""
    }
  }
}

struct TagChipView: View {
  let tag: String
  let isSelected: Bool
  let onTap: () -> Void
  
  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 4) {
        Text(tag)
          .font(.system(size: 14))
          .foregroundColor(isSelected ? .white : .grayTextColor)
          .lineLimit(1)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .frame(minWidth: 60)  // Tag最小宽度
      .background(
        isSelected
        ? Color.mainStyleBackgroundColor
        : Color.buttonUnavailableBackgroundColor
      )
      .clipShape(.capsule)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

// MARK: - FlowLayout实现
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

#Preview {
  struct PreviewWrapper: View {
    @State private var selectedTags = Set<String>()
    
    var body: some View {
      VStack(spacing: 20) {
        // 普通状态
        TagsSelectView(
          selectedTags: $selectedTags,
          useAIParsing: false,
          apiResponse: nil
        )
        
        // 带AI建议的状态
        TagsSelectView(
          selectedTags: $selectedTags,
          useAIParsing: true,
          apiResponse: createSampleAPIResponse()
        )
      }
      .padding()
      .background(Color.gray.opacity(0.05))
    }
    
    // 示例 API 响应
    private func createSampleAPIResponse() -> APIResponse {
      let informationResponse = MemoItemModel.Information(
        title: "AI技术学习路线图",
        informationItems: [
          InformationItem(
            id: 0,
            header: "机器学习基础",
            content: "了解机器学习的基本概念、算法和应用场景，为深入学习AI技术打下基础。",
            node: InformationNode(targetId: 0, relationship: "PARENT")
          ),
          InformationItem(
            id: 1,
            header: "深度学习框架",
            content: "学习TensorFlow、PyTorch等主流深度学习框架的使用方法。",
            node: InformationNode(targetId: 1, relationship: "CHILD")
          ),
          InformationItem(
            id: 2,
            header: "实践项目",
            content: "通过实际项目练习，将理论知识转化为实践能力。",
            node: InformationNode(targetId: 1, relationship: "CHILD")
          )
        ],
        relatedItems: ["机器学习", "深度学习", "人工智能"],
        summary: "这是一个关于AI技术学习的完整路线图，包含了从基础概念到实践应用的全面学习内容。",
        tags: ["AI", "技术", "学习", "机器学习"]
      )
      
      let scheduleResponse = MemoItemModel.Schedule(
        title: "AI学习计划",
        category: "学习",
        tasks: [
          ScheduleTask(
            startTime: "2024-05-16T09:00:00+08:00",
            endTime: "2024-05-16T17:00:00+08:00",
            people: [],
            theme: "机器学习基础学习",
            coreTasks: ["学习线性回归算法", "练习数据预处理", "完成基础练习题"],
            position: [],
            tags: ["学习", "AI", "算法"],
            category: "学习",
            suggestedActions: ["阅读相关文档", "完成编程练习", "总结学习笔记"],
            id: UUID()
          ),
          ScheduleTask(
            startTime: "2024-05-17T14:00:00+08:00",
            endTime: "2024-05-17T18:00:00+08:00",
            people: [],
            theme: "深度学习框架实践",
            coreTasks: ["安装TensorFlow", "完成第一个神经网络", "调试模型参数"],
            position: [],
            tags: ["实践", "深度学习", "TensorFlow"],
            category: "学习",
            suggestedActions: ["搭建开发环境", "跟随教程实践", "记录遇到的问题"],
            id: UUID()
          )
        ]
      )
      
      return APIResponse(
        mostPossibleCategory: "INFORMATION",
        information: informationResponse,
        schedule: scheduleResponse
      )
    }
  }
  
  return PreviewWrapper()
}
