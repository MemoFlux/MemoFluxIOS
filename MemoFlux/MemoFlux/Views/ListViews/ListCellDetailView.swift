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
  case knowledge = "知识"
  case information = "信息"
  case schedule = "日程"
}

struct ListCellDetailView: View {
  let item: MemoItemModel
  
  @Environment(\.modelContext) private var modelContext
  
  // API 响应数据相关状态
  @State private var selectedDataType: DataType = .knowledge
  @State private var isManuallyTriggering = false
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        // 原有的图片和基本信息展示
        if let image = item.image {
          Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .cornerRadius(10)
            .shadow(radius: 3)
            .frame(maxWidth: .infinity)
            .frame(maxHeight: UIScreen.main.bounds.height / 2)
        }
        
        if !item.title.isEmpty {
          Text(item.title)
            .font(.title)
            .fontWeight(.bold)
            .padding(.horizontal)
        }
        
        // 基本信息
        basicInfoSection
        
        // 标签展示
        tagsSection
        
        Divider()
          .padding(.vertical, 8)
        
        // API 数据展示部分
        apiDataSection
      }
      .padding(.vertical)
    }
    .navigationTitle("详细信息")
    .navigationBarTitleDisplayMode(.inline)
    .background(Color(.globalStyleBackgroundColor))
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
      // 显示摘要（如果有API响应）
      if let response = item.apiResponse, !response.information.summary.isEmpty {
        VStack(alignment: .leading, spacing: 10) {
          Text("AI 摘要")
            .font(.headline)
            .padding(.leading, 5)
          
          Text(response.information.summary)
            .font(.body)
            .foregroundColor(.secondary)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(15)
          
          Text("AI 解析内容")
            .font(.headline)
            .padding(.leading, 5)
        }
        .padding(.horizontal, 16)
      }
      
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
        case .information:
          InformationView(information: response.information)
        case .schedule:
          ScheduleView(schedule: response.schedule)
        }
        
      } else {
        // 没有API响应，显示原有的识别内容
        VStack(alignment: .leading, spacing: 8) {
          if !item.recognizedText.isEmpty {
            Text("本地识别结果")
              .font(.headline)
              .padding(.leading, 5)
            
            Text(item.recognizedText)
              .font(.body)
              .padding()
              .background(Color.gray.opacity(0.1))
              .cornerRadius(8)
              .padding(.horizontal)
            
            // 提供手动触发API分析的按钮
            Button("使用AI分析内容") {
              triggerAPIAnalysis()
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(8)
            .padding(.horizontal)
            
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
        Text(isManuallyTriggering ? "AI分析中..." : "使用AI分析内容")
      }
    }
    .font(.system(size: 14, weight: .medium))
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
    .background(isManuallyTriggering ? Color.gray : Color.blue)
    .cornerRadius(8)
    .disabled(isManuallyTriggering || item.isAPIProcessing)
    .padding(.horizontal)
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
struct InformationView: View {
  let information: InformationResponse
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // 标题
      Text(information.title)
        .font(.title2)
        .fontWeight(.semibold)
        .padding(.horizontal)
      
      // 类型
      HStack {
        Text("类型:")
          .font(.subheadline)
          .fontWeight(.medium)
        Text(information.postType)
          .font(.subheadline)
          .fontWeight(.regular)
        Spacer()
      }
      .padding(.horizontal)
      
      // 标签
      if !information.tags.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack {
            ForEach(information.tags, id: \.self) { tag in
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
      
      // 信息项目
      LazyVStack(alignment: .leading, spacing: 8) {
        ForEach(information.informationItems) { item in
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

// MARK: - Schedule 视图
struct ScheduleView: View {
  let schedule: ScheduleResponse
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
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

// MARK: - Schedule 任务卡片
struct ScheduleTaskCard: View {
  let task: ScheduleTask
  
  // 提醒确认视图状态
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
      
      // 核心任务
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
      HStack(spacing: 12) {
        Button {
          addToCalendar()
        } label: {
          HStack(spacing: 6) {
            Image(systemName: "calendar")
              .font(.system(size: 12))
            
            Text("添加到日历")
              .font(.system(size: 12))
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .foregroundStyle(.white)
          .background(.blue)
          .cornerRadius(12)
        }
        
        Button {
          showingReminderConfirmation = true
        } label: {
          HStack(spacing: 6) {
            Image(systemName: "list.bullet")
              .font(.system(size: 12))
            
            Text("添加到提醒事项")
              .font(.system(size: 12))
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .foregroundStyle(.white)
          .background(.yellow)
          .cornerRadius(12)
        }
        
        Spacer()
        
      }
      .padding(.top, 8)
    }
    .padding()
    .background(Color.white)
    .cornerRadius(15)
    .sheet(isPresented: $showingReminderConfirmation) {
      ReminderConfirmationView(task: task)
    }
  }
  
  // MARK: - EventKit 创建
  private func addToCalendar() {
    let eventTitle = task.theme
    let eventNotes = createEventNotes()
    let eventStartDate = task.startDate ?? Date()
    
    EventManager.shared.requestCalendarAccess { granted, error in
      if granted && error == nil {
        let event = EventManager.shared.createCalendarEvent(
          title: eventTitle,
          notes: eventNotes,
          startDate: eventStartDate
        )
        EventManager.shared.presentCalendarEventEditor(for: event)
      } else {
        print("日历访问权限被拒绝或出现错误: \(error?.localizedDescription ?? "未知错误")")
      }
    }
  }
  
  private func addToReminders() {
    let reminderTitle = task.theme
    let reminderNotes = createReminderNotes()
    let reminderDate = task.startDate
    
    EventManager.shared.addReminder(
      title: reminderTitle,
      notes: reminderNotes,
      date: reminderDate
    ) { success, error in
      if success {
        print("提醒事项创建成功: \(reminderTitle)")
      } else {
        print("提醒事项创建失败: \(error?.localizedDescription ?? "未知错误")")
      }
    }
  }
  
  // MARK: - 创建事件备注
  private func createEventNotes() -> String {
    var notes = ""
    
    if !task.coreTasks.isEmpty {
      notes += "核心任务:\n"
      for coreTask in task.coreTasks {
        notes += "• \(coreTask)\n"
      }
      notes += "\n"
    }
    
    if !task.suggestedActions.isEmpty {
      notes += "建议行动:\n"
      for action in task.suggestedActions {
        notes += "• \(action)\n"
      }
      notes += "\n"
    }
    
    if !task.people.isEmpty {
      notes += "参与人员: \(task.people.joined(separator: ", "))\n"
    }
    
    if !task.position.isEmpty {
      notes += "地点: \(task.position.joined(separator: ", "))\n"
    }
    
    if !task.tags.isEmpty {
      notes += "标签: \(task.tags.joined(separator: ", "))"
    }
    
    return notes.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  private func createReminderNotes() -> String {
    return createEventNotes()
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
