//
//  ListCellDetailView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import EventKit
import SwiftData
import SwiftUI

// MARK: - 数据类型枚举
enum DataType: String, CaseIterable {
  case knowledge = "信息"
  // case information = "信息"
  case schedule = "日程"
}

struct ListCellDetailView: View {
  let item: MemoItemModel
  
  @Environment(\.modelContext) private var modelContext
  
  @State private var selectedDataType: DataType = .knowledge
  @State private var isManuallyTriggering = false
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        if let image = item.image {
          Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .cornerRadius(10)
            .shadow(radius: 3)
            .frame(maxWidth: .infinity)
            .frame(maxHeight: UIScreen.main.bounds.height / 2)
        }
        
        // 显示标题：优先使用item.title，如果为空则使用API响应中最可能类别的标题
        let displayTitle = getDisplayTitle()
        if !displayTitle.isEmpty {
          Text(displayTitle)
            .font(.title)
            .fontWeight(.bold)
            .padding(.horizontal)
        }
        
        basicInfoSection
        
        tagsSection
        
        Divider()
          .padding(.vertical, 8)
        
        apiDataSection
      }
      .padding(.vertical)
    }
    .navigationTitle("详细信息")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          // 暂时不实现编辑功能
        }) {
          Image(systemName: "square.and.pencil")
        }
      }
    }
    .background(Color.globalStyleBackgroundColor)
    .onAppear {
      setDefaultDataTypeFromAPIResponse()
    }
    .onChange(of: item.apiResponse) { newResponse in
      setDefaultDataTypeFromAPIResponse()
    }
  }
  
  // MARK: - 基本信息部分
  private var basicInfoSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: "calendar")
        Text("创建时间: \(item.createdAt.formatted(date: .abbreviated, time: .shortened))")
        Spacer()
      }
      .font(.subheadline)
      .foregroundColor(.secondary)
      .padding(.horizontal)
      
      if !item.source.isEmpty {
        HStack {
          Image(systemName: "link")
          Text("来源: \(item.source)")
          Spacer()
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
        .padding(.horizontal)
      }
      
      // API处理状态
      if item.isAPIProcessing {
        HStack {
          Image(systemName: "brain")
          Text("AI正在分析中...")
          ProgressView()
            .scaleEffect(0.8)
          Spacer()
        }
        .font(.subheadline)
        .foregroundColor(.blue)
        .padding(.horizontal)
      } else if item.hasAPIResponse, let processedAt = item.apiProcessedAt {
        HStack {
          Image(systemName: "brain.head.profile")
          Text("AI分析完成: \(processedAt.formatted(date: .omitted, time: .shortened))")
          Spacer()
        }
        .font(.subheadline)
        .foregroundColor(.green)
        .padding(.horizontal)
      }
    }
  }
  
  // MARK: - 标签部分
  private var tagsSection: some View {
    Group {
      if !item.tags.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack {
            ForEach(item.tags, id: \.self) { tag in
              Text(tag)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
            }
          }
          .padding(.horizontal)
        }
      }
    }
  }
  
  // MARK: - API 数据展示部分
  private var apiDataSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      // 显示用户输入的原文（如果有）
      if !item.userInputText.isEmpty {
        VStack(alignment: .leading, spacing: 10) {
          Text("用户原文")
            .font(.headline)
            .padding(.leading, 5)
          
          Text(item.userInputText)
            .font(.body)
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(15)
        }
        .padding(.horizontal, 16)
      }
      
      // 显示摘要（如果有API响应）
//      if let response = item.apiResponse, !response.information.summary.isEmpty {
//        VStack(alignment: .leading, spacing: 10) {
//          Text("AI 摘要")
//            .font(.headline)
//            .padding(.leading, 5)
//          
//          Text(response.information.summary)
//            .font(.body)
//            .foregroundColor(.secondary)
//            .padding()
//            .background(Color.blue.opacity(0.1))
//            .cornerRadius(15)
//          
//          Text("AI 解析内容")
//            .font(.headline)
//            .padding(.leading, 5)
//        }
//        .padding(.horizontal, 16)
//      }
      
      // 根据API响应状态显示不同内容
      if item.isAPIProcessing {
        // 正在处理API请求
        VStack(spacing: 16) {
          ProgressView("AI正在分析内容...")
            .frame(maxWidth: .infinity, alignment: .center)
          
          Text("请稍候，AI正在为您分析内容并生成智能解析结果")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding()
        
      } else if let response = item.apiResponse {
        // 有API响应，显示解析结果
        
        // 数据类型选择器
        Picker("数据类型", selection: $selectedDataType) {
          ForEach(DataType.allCases, id: \.self) { type in
            Text(type.rawValue).tag(type)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        
        // 根据选择的类型显示相应数据
        switch selectedDataType {
        case .knowledge:
          KnowledgeView(knowledge: response.knowledge)
        // case .information:
          // InformationView(information: response.knowledge)
        case .schedule:
          ScheduleView(schedule: response.schedule)
        }
        
      } else {
        // 没有API响应，显示原有的识别内容
        VStack(alignment: .leading, spacing: 8) {
          if !item.recognizedText.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
              Text("本地文本")
                .font(.headline)
                .padding(.leading, 5)
              
              Text(item.recognizedText)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(15)
            }
            .padding(.horizontal, 16)
            
            // 提供手动触发API分析的按钮
            manualAnalysisButton
            
          } else {
            Text("暂无识别内容")
              .font(.body)
              .foregroundColor(.secondary)
              .padding()
              .frame(maxWidth: .infinity, alignment: .center)
          }
        }
      }
    }
  }
  
  // MARK: - 手动触发API分析
  private func triggerAPIAnalysis() {
    isManuallyTriggering = true
    
    NetworkManager.shared.triggerAPIAnalysis(for: item, modelContext: modelContext) { result in
      DispatchQueue.main.async {
        isManuallyTriggering = false
        
        switch result {
        case .success:
          print("手动API分析成功")
        case .failure(let error):
          print("手动API分析失败: \(error.localizedDescription)")
        }
      }
    }
  }
  
  // 更新手动分析按钮
  private var manualAnalysisButton: some View {
    Button(action: triggerAPIAnalysis) {
      HStack {
        if isManuallyTriggering {
          ProgressView()
            .scaleEffect(0.8)
        }
        Text(isManuallyTriggering ? "AI分析中..." : "重新使用AI解析")
      }
    }
    .font(.system(size: 14, weight: .medium))
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
    .background(isManuallyTriggering ? Color.gray : Color.mainStyleBackgroundColor)
    .cornerRadius(15)
    .disabled(isManuallyTriggering || item.isAPIProcessing)
    .padding()
  }
  
  // MARK: - 获取显示标题
  private func getDisplayTitle() -> String {
    // 如果有标题，直接使用
    if !item.title.isEmpty {
      return item.title
    }
    
    // 如果没有标题但有API响应，使用最可能类别的标题
    guard let response = item.apiResponse else {
      return ""
    }
    
    switch response.mostPossibleCategory.lowercased() {
    case "knowledge":
      return response.knowledge.title
    case "information":
      return ""
    case "schedule":
      return response.schedule.title
    default:
      return ""
    }
  }
  
  // MARK: - 设置默认数据类型
  private func setDefaultDataTypeFromAPIResponse() {
    guard let response = item.apiResponse else { return }
    
    // 根据mostPossibleCategory字段设置默认选项
    switch response.mostPossibleCategory.lowercased() {
    case "knowledge":
      selectedDataType = .knowledge
//    case "information":
//      selectedDataType = .information
    case "schedule":
      selectedDataType = .schedule
    default:
      selectedDataType = .knowledge
    }
  }
}

// MARK: - Knowledge 视图
struct KnowledgeView: View {
  let knowledge: KnowledgeResponse
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // 标题
      Text(knowledge.title)
        .font(.title2)
        .fontWeight(.semibold)
        .padding(.horizontal)
      
      // 标签
      if !knowledge.tags.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack {
            ForEach(knowledge.tags, id: \.self) { tag in
              Text(tag)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
            }
          }
          .padding(.horizontal)
        }
      }
      
      LazyVStack(alignment: .leading, spacing: 8) {
        ForEach(knowledge.knowledgeItems) { item in
          VStack(alignment: .leading, spacing: 8) {
            Text(item.header)
              .font(.headline)
              .bold()
              .padding(.vertical, 5)
            
            Text(item.content)
              .font(.body)
              .foregroundColor(.secondary)
          }
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color.white)
          .cornerRadius(15)
        }
      }
      .padding(.horizontal)
      .listStyle(PlainListStyle())
    }
  }
}

// MARK: - Information 视图
//struct InformationView: View {
//  let information: InformationResponse
//  
//  private var mergedInformationItems: [(header: String, contents: [String])] {
//    var mergedItems: [String: [String]] = [:]
//    
//    for item in information.informationItems {
//      if mergedItems[item.header] != nil {
//        mergedItems[item.header]?.append(item.content)
//      } else {
//        mergedItems[item.header] = [item.content]
//      }
//    }
//    
//    var result: [(header: String, contents: [String])] = []
//    var processedHeaders: Set<String> = []
//    
//    for item in information.informationItems {
//      if !processedHeaders.contains(item.header) {
//        result.append((header: item.header, contents: mergedItems[item.header] ?? []))
//        processedHeaders.insert(item.header)
//      }
//    }
//    
//    return result
//  }
//  
//  var body: some View {
//    VStack(alignment: .leading, spacing: 12) {
//      Text(information.title)
//        .font(.title2)
//        .fontWeight(.semibold)
//        .padding(.horizontal)
//      
//      HStack {
//        Text("类型:")
//          .font(.subheadline)
//          .fontWeight(.medium)
//        Text(information.postType)
//          .font(.subheadline)
//          .fontWeight(.regular)
//        Spacer()
//      }
//      .padding(.horizontal)
//      
//      if !information.tags.isEmpty {
//        ScrollView(.horizontal, showsIndicators: false) {
//          HStack {
//            ForEach(information.tags, id: \.self) { tag in
//              Text(tag)
//                .font(.caption)
//                .padding(.horizontal, 8)
//                .padding(.vertical, 4)
//                .background(Color.blue.opacity(0.2))
//                .cornerRadius(8)
//            }
//          }
//          .padding(.horizontal)
//        }
//      }
//      
//      LazyVStack(alignment: .leading, spacing: 8) {
//        ForEach(Array(mergedInformationItems.enumerated()), id: \.offset) { index, mergedItem in
//          VStack(alignment: .leading, spacing: 8) {
//            Text(mergedItem.header)
//              .font(.headline)
//              .bold()
//              .padding(.vertical, 5)
//            
//            if mergedItem.contents.count == 1 {
//              Text(mergedItem.contents[0])
//                .font(.body)
//                .foregroundColor(.secondary)
//            } else {
//              VStack(alignment: .leading, spacing: 4) {
//                ForEach(Array(mergedItem.contents.enumerated()), id: \.offset) {
//                  contentIndex, content in
//                  HStack(alignment: .top, spacing: 8) {
//                    Text("•")
//                      .font(.body)
//                      .foregroundColor(.secondary)
//                      .padding(.top, 1)
//                    
//                    Text(content)
//                      .font(.body)
//                      .foregroundColor(.secondary)
//                      .frame(maxWidth: .infinity, alignment: .leading)
//                  }
//                }
//              }
//            }
//          }
//          .padding()
//          .frame(maxWidth: .infinity, alignment: .leading)
//          .background(Color.white)
//          .cornerRadius(15)
//        }
//      }
//      .padding(.horizontal)
//      .listStyle(PlainListStyle())
//    }
//  }
//}

// MARK: - Schedule 视图
struct ScheduleView: View {
  let schedule: ScheduleResponse
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      if schedule.tasks.isEmpty {
        VStack(spacing: 16) {
          Image(systemName: "exclamationmark.triangle")
            .font(.system(size: 40))
            .foregroundColor(Color.orange)
            .padding(.top, 20)
          
          Text("当前Memo未识别出意图")
            .font(.headline)
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
          
          Text("您可以尝试添加更多详细信息，或使用AI解析功能重新分析内容")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
      } else {
        Text(schedule.title)
          .font(.title2)
          .fontWeight(.semibold)
          .padding(.horizontal)
        
        HStack {
          Text("分类:")
            .font(.subheadline)
            .fontWeight(.medium)
          Text(schedule.category)
            .font(.subheadline)
            .fontWeight(.regular)
          Spacer()
        }
        .padding(.horizontal)
        
        LazyVStack(alignment: .leading, spacing: 8) {
          ForEach(schedule.tasks) { task in
            ScheduleTaskCard(task: task)
          }
        }
        .padding(.horizontal)
      }
    }
  }
}

// MARK: - Schedule 任务卡片
struct ScheduleTaskCard: View {
  let task: ScheduleTask
  
  @State private var showingReminderConfirmation = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(task.theme)
          .font(.headline)
          .foregroundColor(.primary)
        Spacer()
        if let startDate = task.startDate {
          Text(startDate.formatted(date: .abbreviated, time: .shortened))
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      
      if !task.coreTasks.isEmpty {
        VStack(alignment: .leading, spacing: 4) {
          Text("核心任务:")
            .font(.subheadline)
            .fontWeight(.medium)
          ForEach(task.coreTasks, id: \.self) { coreTask in
            HStack {
              Image(systemName: "checkmark.circle")
                .foregroundColor(.green)
              Text(coreTask)
                .font(.body)
              Spacer()
            }
          }
        }
      }
      
      if !task.suggestedActions.isEmpty {
        VStack(alignment: .leading, spacing: 4) {
          Text("建议行动:")
            .font(.subheadline)
            .fontWeight(.medium)
          ForEach(task.suggestedActions, id: \.self) { action in
            HStack {
              Image(systemName: "lightbulb")
                .foregroundColor(.yellow)
              Text(action)
                .font(.body)
              Spacer()
            }
          }
        }
      }
      
      if !task.tags.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack {
            ForEach(task.tags, id: \.self) { tag in
              Text(tag)
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(6)
            }
          }
        }
      }
      
      // EventKit 操作按钮
      ScheduleTaskHelper.actionButtons(
        for: task,
        showingReminderConfirmation: $showingReminderConfirmation
      )
      .padding(.top, 8)
    }
    .padding()
    .background(Color.white)
    .cornerRadius(15)
    .sheet(isPresented: $showingReminderConfirmation) {
      ReminderConfirmationView(task: task)
    }
  }
}

#Preview {
  let previewItem = MemoItemModel(
    id: UUID(),
    imageData: UIImage(systemName: "photo")?.pngData(),
    recognizedText: "这是一段示例文本，用于预览识别结果的显示效果。\n可以包含多行内容来测试布局。",
    title: "示例标题",
    tags: ["示例", "预览", "测试"],
    createdAt: Date(),
    source: "预览数据"
  )
  
  return NavigationStack {
    ListCellDetailView(item: previewItem)
  }
}
