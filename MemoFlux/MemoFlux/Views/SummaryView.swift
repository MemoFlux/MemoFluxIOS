//
//  SummaryView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import SwiftData
import SwiftUI

struct SummaryView: View {
  @Environment(\.dismiss) private var dismiss
  
  @State private var selectedDate = Date()
  @State private var showDatePicker = false
  
  // 展开状态管理
  @State private var isNewInformationExpanded = false
  @State private var isIntentCompletionExpanded = false
  @State private var isSuggestedActionsExpanded = false
  
  // SwiftData查询所有MemoItemModel
  @Query(sort: \MemoItemModel.createdAt, order: .reverse) private var allMemoItems: [MemoItemModel]
  @Environment(\.modelContext) private var modelContext
  
  // 计算属性：获取选定日期的统计数据
  private var todayMemos: [MemoItemModel] {
    let calendar = Calendar.current
    return allMemoItems.filter { memo in
      calendar.isDate(memo.createdAt, inSameDayAs: selectedDate)
    }
  }
  
  private var todayMemoCount: Int {
    todayMemos.count
  }
  
  private var todayIntentCount: Int {
    // 统计今日产生的意图数量（从API响应中的schedule tasks）
    todayMemos.compactMap { memo in
      memo.apiResponse?.schedule.tasks.count ?? 0
    }.reduce(0, +)
  }
  
  private var completedIntentCount: Int {
    // 计算已完成意图的数量
    let (completedIntents, _) = getTodayIntents()
    return completedIntents.count
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 16) {
          // 日期选择器
          dateSelectionSection
          
          // 今日概览
          todayOverviewSection
          
          // 今日新增信息
          newInformationSection
          
          // 意图完成情况
          intentCompletionSection
          
          // 待处理建议行动
          suggestedActionsSection
          
          // AI洞察与趋势
          aiInsightsSection
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 100)
      }
      .background(Color.globalStyleBackgroundColor)
      .navigationTitle("summary.title".localized)
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {
            showDatePicker.toggle()
          }) {
            Image(systemName: "calendar")
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            dismiss()
          }) {
            Text("summary.select.date.complete".localized)
          }
        }
      }
    }
    .sheet(isPresented: $showDatePicker) {
      NavigationView {
        DatePicker("summary.select.date".localized, selection: $selectedDate, displayedComponents: .date)
          .datePickerStyle(GraphicalDatePickerStyle())
          .navigationTitle("summary.select.date".localized)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              Button("完成") {
                showDatePicker = false
              }
              .font(.system(size: 16, weight: .medium))
            }
          }
      }
      .presentationDetents([.medium])
    }
  }
  
  // MARK: - 日期选择区域
  private var dateSelectionSection: some View {
    HStack {
      Button(action: {
        selectedDate =
        Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
      }) {
        Image(systemName: "chevron.left")
          .foregroundColor(.gray)
          .frame(width: 32, height: 32)
          .background(Color.white.opacity(0.9))
          .clipShape(Circle())
      }
      
      Spacer()
      
      Text(selectedDate.formatted(date: .complete, time: .omitted))
        .font(.system(size: 14, weight: .medium))
      
      Spacer()
      
      Button(action: {
        let tomorrow =
        Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        if tomorrow <= Date() {
          selectedDate = tomorrow
        }
      }) {
        Image(systemName: "chevron.right")
          .foregroundColor(canGoToNextDay ? .gray : .gray.opacity(0.5))
          .frame(width: 32, height: 32)
          .background(Color.white.opacity(canGoToNextDay ? 0.9 : 0.5))
          .clipShape(Circle())
      }
      .disabled(!canGoToNextDay)
    }
  }
  
  private var canGoToNextDay: Bool {
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    return tomorrow <= Date()
  }
  
  // MARK: - 今日概览
  private var todayOverviewSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("summary.today.overview".localized)
        .font(.system(size: 14, weight: .medium))
        .padding(.horizontal, 16)
      
      VStack(spacing: 16) {
        HStack(spacing: 0) {
          overviewItem(icon: "doc.text", title: "summary.new.information".localized, count: "\(todayMemoCount)", color: .blue)
          overviewItem(
            icon: "checkmark.circle", title: "summary.completed.intent".localized, count: "\(completedIntentCount)", color: .green
          )
          overviewItem(
            icon: "lightbulb", title: "summary.new.intent".localized, count: "\(todayIntentCount)", color: .orange)
        }
        
        // 图表占位符
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.gray.opacity(0.1))
          .frame(height: 160)
          .overlay(
            VStack {
              Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
              Text("summary.activity.trend".localized)
                .font(.caption)
                .foregroundColor(.gray)
            }
          )
      }
      .padding(16)
      .background(Color.white.opacity(0.9))
      .cornerRadius(16)
    }
  }
  
  private func overviewItem(icon: String, title: String, count: String, color: Color) -> some View {
    VStack(spacing: 8) {
      ZStack {
        Circle()
          .fill(color.opacity(0.2))
          .frame(width: 40, height: 40)
        
        Image(systemName: icon)
          .foregroundColor(color)
          .font(.system(size: 16))
      }
      
      Text(title)
        .font(.system(size: 10))
        .foregroundColor(.gray)
      
      Text(count)
        .font(.system(size: 14, weight: .medium))
    }
    .frame(maxWidth: .infinity)
  }
  
  // MARK: - 今日新增信息
  private var newInformationSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("summary.today.new.information".localized)
          .font(.system(size: 14, weight: .medium))
        
        Spacer()
        
        Button(action: {
          withAnimation(.easeInOut(duration: 0.3)) {
            isNewInformationExpanded.toggle()
          }
        }) {
          HStack(spacing: 4) {
            Text(isNewInformationExpanded ? "summary.collapse".localized : "summary.expand".localized)
              .font(.system(size: 12))
              .foregroundColor(.blue)
            
            Image(systemName: isNewInformationExpanded ? "chevron.up" : "chevron.down")
              .font(.system(size: 10))
              .foregroundColor(.blue)
          }
        }
      }
      .padding(.horizontal, 16)
      
      if todayMemos.isEmpty {
        VStack(spacing: 8) {
          Image(systemName: "doc.text")
            .foregroundColor(.gray)
            .font(.system(size: 24))
          
          Text("summary.today.no.information".localized)
            .font(.system(size: 14))
            .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
      } else {
        VStack(spacing: 12) {
          let memosToShow = isNewInformationExpanded ? todayMemos : Array(todayMemos.prefix(3))
          
          ForEach(memosToShow, id: \.id) { memo in
            memoInformationCard(memo: memo)
              .transition(
                .asymmetric(
                  insertion: .scale.combined(with: .opacity),
                  removal: .scale.combined(with: .opacity)
                ))
          }
          
          if !isNewInformationExpanded && todayMemos.count > 3 {
            Text("summary.more.information".localized(with: todayMemos.count - 3))
              .font(.system(size: 12))
              .foregroundColor(.gray)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 8)
          }
        }
      }
    }
  }
  
  private func memoInformationCard(memo: MemoItemModel) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        HStack(spacing: 8) {
          ZStack {
            Circle()
              .fill(categoryColor(for: memo).opacity(0.2))
              .frame(width: 24, height: 24)
            
            Image(systemName: categoryIcon(for: memo))
              .foregroundColor(categoryColor(for: memo))
              .font(.system(size: 12))
          }
          
          Text(getDisplayTitle(for: memo))
            .font(.system(size: 14, weight: .medium))
            .lineLimit(1)
        }
        
        Spacer()
        
        Text(formatTime(memo.createdAt))
          .font(.system(size: 10))
          .foregroundColor(.gray)
      }
      
      if let apiResponse = memo.apiResponse {
        Text(getSummaryText(from: apiResponse))
          .font(.system(size: 12))
          .foregroundColor(.primary)
          .lineLimit(3)
      } else {
        Text(memo.recognizedText.isEmpty ? memo.userInputText : memo.recognizedText)
          .font(.system(size: 12))
          .foregroundColor(.primary)
          .lineLimit(3)
      }
      
      if !memo.tags.isEmpty {
        HStack {
          ForEach(Array(memo.tags.prefix(3)), id: \.self) { tag in
            Text("\(tag)")
              .font(.system(size: 10))
              .padding(.horizontal, 8)
              .padding(.vertical, 2)
              .background(categoryColor(for: memo).opacity(0.2))
              .cornerRadius(12)
          }
          Spacer()
        }
      }
    }
    .padding(16)
    .background(Color.white.opacity(0.9))
    .cornerRadius(16)
  }
  
  // MARK: - Helper Methods for Category
  private func categoryIcon(for memo: MemoItemModel) -> String {
    guard let apiResponse = memo.apiResponse else {
      return "doc.text"
    }
    
    switch apiResponse.mostPossibleCategory.lowercased() {
    case "information":
      return "info.circle"
    case "schedule":
      return "calendar"
    default:
      return "doc.text"
    }
  }
  
  private func categoryColor(for memo: MemoItemModel) -> Color {
    guard let apiResponse = memo.apiResponse else {
      return .blue  // 默认颜色
    }
    
    switch apiResponse.mostPossibleCategory.lowercased() {
    case "information":
      return .blue
    case "schedule":
      return .green
    default:
      return .blue
    }
  }
  
  // MARK: - 获取显示标题
  private func getDisplayTitle(for memo: MemoItemModel) -> String {
    // 如果有标题，直接使用
    if !memo.title.isEmpty {
      return memo.title
    }
    
    // 如果没有标题但有API响应，使用最可能类别的标题
    guard let response = memo.apiResponse else {
      return "category.no.title".localized
    }
    
    switch response.mostPossibleCategory.lowercased() {
    case "information":
      return response.information.title.isEmpty ? "无标题" : response.information.title
    case "schedule":
      return response.schedule.title.isEmpty ? "无标题" : response.schedule.title
    default:
      return "category.no.title".localized
    }
  }
  
  private func getSummaryText(from apiResponse: APIResponse) -> String {
    switch apiResponse.mostPossibleCategory.lowercased() {
    case "information":
      return apiResponse.information.title
    case "schedule":
      return apiResponse.schedule.title
    default:
      return apiResponse.information.summary.isEmpty
      ? apiResponse.information.title : apiResponse.information.summary
    }
  }
  
  private func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
  }
  
  private func taskItem(title: String, time: String) -> some View {
    HStack {
      Text(title)
        .font(.system(size: 14, weight: .medium))
      
      Spacer()
      
      Text(time)
        .font(.system(size: 10))
        .foregroundColor(.gray)
    }
    .padding(12)
    .background(Color.blue.opacity(0.05))
    .cornerRadius(12)
  }
  
  // MARK: - 意图完成情况
  private var intentCompletionSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("summary.intent.processing".localized)
          .font(.system(size: 14, weight: .medium))
        
        Spacer()
        
        Button(action: {
          withAnimation(.easeInOut(duration: 0.3)) {
            isIntentCompletionExpanded.toggle()
          }
        }) {
          HStack(spacing: 4) {
            Text(isIntentCompletionExpanded ? "summary.collapse".localized : "summary.expand".localized)
              .font(.system(size: 12))
              .foregroundColor(.blue)
            
            Image(systemName: isIntentCompletionExpanded ? "chevron.up" : "chevron.down")
              .font(.system(size: 10))
              .foregroundColor(.blue)
          }
        }
      }
      .padding(.horizontal, 16)
      
      let (completedIntents, pendingIntents) = getTodayIntents()
      
      if completedIntents.isEmpty && pendingIntents.isEmpty {
        VStack(spacing: 8) {
          Image(systemName: "calendar.badge.clock")
            .foregroundColor(.gray)
            .font(.system(size: 24))
          
          Text("summary.today.no.intent".localized)
            .font(.system(size: 14))
            .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
      } else {
        VStack(alignment: .leading, spacing: 16) {
          // 已完成意图部分
          if !completedIntents.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
              HStack(spacing: 8) {
                ZStack {
                  Circle()
                    .fill(Color.green)
                    .frame(width: 24, height: 24)
                  
                  Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .font(.system(size: 12, weight: .bold))
                }
                
                Text("summary.processed.intent".localized(with: completedIntents.count))
                  .font(.system(size: 14, weight: .medium))
              }
              
              VStack(spacing: 8) {
                let completedToShow =
                isIntentCompletionExpanded ? completedIntents : Array(completedIntents.prefix(3))
                
                ForEach(completedToShow, id: \.id) { intent in
                  intentItem(intent: intent, isCompleted: true, modelContext: modelContext)
                    .transition(
                      .asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                      ))
                }
                
                if !isIntentCompletionExpanded && completedIntents.count > 3 {
                  Text("summary.more.processed.intent".localized(with: completedIntents.count - 3))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
              }
            }
          }
          
          // 未完成意图部分
          if !pendingIntents.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
              HStack(spacing: 8) {
                ZStack {
                  Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 24, height: 24)
                  
                  Image(systemName: "clock")
                    .foregroundColor(.orange)
                    .font(.system(size: 12, weight: .bold))
                }
                
                Text("summary.pending.intent".localized(with: pendingIntents.count))
                  .font(.system(size: 14, weight: .medium))
              }
              
              VStack(spacing: 8) {
                let pendingToShow =
                isIntentCompletionExpanded ? pendingIntents : Array(pendingIntents.prefix(3))
                
                ForEach(pendingToShow, id: \.id) { intent in
                  intentItem(intent: intent, isCompleted: false, modelContext: modelContext)
                    .transition(
                      .asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                      ))
                }
                
                if !isIntentCompletionExpanded && pendingIntents.count > 3 {
                  Text("summary.more.pending.intent".localized(with: pendingIntents.count - 3))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
              }
            }
          }
        }
        .padding(16)
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
      }
    }
  }
  
  // MARK: - 意图项目视图
  private func intentItem(
    intent: IntentDiscoveryViewModel, isCompleted: Bool, modelContext: ModelContext
  ) -> some View {
    HStack(spacing: 12) {
      Image(systemName: intent.iconName)
        .font(.system(size: 14))
        .foregroundColor(intent.iconColor)
        .frame(width: 20, height: 20)
      
      VStack(alignment: .leading, spacing: 2) {
        Text(intent.title)
          .font(.system(size: 14, weight: .medium))
          .lineLimit(1)
        
        if let startDate = intent.scheduleTask.startDate {
          Text(formatIntentTime(startDate))
            .font(.system(size: 12))
            .foregroundColor(.secondary)
        }
      }
      
      Spacer()
      
      Button(action: {
        let newStatus: ScheduleTaskModel.TaskStatus = isCompleted ? .pending : .completed
        intent.memoItem.updateTaskStatus(
          taskId: intent.scheduleTask.id, status: newStatus, in: modelContext)
      }) {
        if isCompleted {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.green)
            .font(.system(size: 16))
        } else {
          Image(systemName: "circle")
            .foregroundColor(.orange)
            .font(.system(size: 16))
        }
      }
      .buttonStyle(PlainButtonStyle())
    }
    .padding(12)
    .background(isCompleted ? Color.green.opacity(0.05) : Color.orange.opacity(0.05))
    .cornerRadius(12)
  }
  
  // MARK: - 获取今日意图数据
  private func getTodayIntents() -> (
    completed: [IntentDiscoveryViewModel], pending: [IntentDiscoveryViewModel]
  ) {
    var completedIntents: [IntentDiscoveryViewModel] = []
    var pendingIntents: [IntentDiscoveryViewModel] = []
    
    print("🔍 调试：今日Memo数量: \(todayMemos.count)")
    
    for memoItem in todayMemos {
      guard let apiResponse = memoItem.apiResponse else {
        print("⚠️ Memo \(memoItem.id) 没有API响应")
        continue
      }
      
      print(
        "📋 Memo类别: \(apiResponse.mostPossibleCategory), 任务数量: \(apiResponse.schedule.tasks.count)")
      
      // 处理所有有任务的意图，不仅限于schedule类型
      if !apiResponse.schedule.tasks.isEmpty {
        for task in apiResponse.schedule.tasks {
          let intent = IntentDiscoveryViewModel(memoItem: memoItem, scheduleTask: task)
          print("📝 任务: \(task.theme), 状态: \(task.taskStatus)")
          
          // 直接使用ScheduleTask的taskStatus判断是否已处理
          if task.taskStatus == .completed {
            var completedIntent = intent
            completedIntent.isCompleted = true
            completedIntents.append(completedIntent)
          } else {
            pendingIntents.append(intent)
          }
        }
      }
    }
    
    print("✅ 已完成意图: \(completedIntents.count), 待处理意图: \(pendingIntents.count)")
    return (completedIntents, pendingIntents)
  }
  
  // MARK: - 格式化意图时间
  private func formatIntentTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
  }
  
  // MARK: - 待处理建议行动
  private var suggestedActionsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("summary.suggested.actions".localized)
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.white)
        
        Spacer()
        
        Image(systemName: "lightbulb.fill")
          .foregroundColor(.yellow)
      }
      
      VStack(spacing: 8) {
        let suggestedActions = getSuggestedActions()
        let actionsToShow =
        isSuggestedActionsExpanded ? suggestedActions : Array(suggestedActions.prefix(2))
        
        ForEach(Array(actionsToShow.enumerated()), id: \.offset) { index, action in
          actionItem(
            icon: action.icon,
            title: action.title,
            deadline: action.deadline,
            description: action.description,
            isUrgent: action.isUrgent
          )
          .transition(
            .asymmetric(
              insertion: .scale.combined(with: .opacity),
              removal: .scale.combined(with: .opacity)
            ))
        }
        
        if !isSuggestedActionsExpanded && suggestedActions.count > 2 {
          Text("还有 \(suggestedActions.count - 2) 个建议行动")  // TODO: 添加本地化key
            .font(.system(size: 12))
            .foregroundColor(.white.opacity(0.8))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
      }
    }
    .padding(16)
    .background(
      LinearGradient(
        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    )
    .cornerRadius(16)
  }
}

private func actionItem(
  icon: String, title: String, deadline: String, description: String, isUrgent: Bool
) -> some View {
  VStack(alignment: .leading, spacing: 8) {
    HStack {
      HStack(spacing: 8) {
        ZStack {
          Circle()
            .fill(Color.yellow.opacity(0.8))
            .frame(width: 24, height: 24)
          
          Image(systemName: icon)
            .foregroundColor(.blue)
            .font(.system(size: 12))
        }
        
        Text(title)
          .font(.system(size: 14, weight: .medium))
      }
      
      Spacer()
      
      Text(deadline)
        .font(.system(size: 10))
        .foregroundColor(isUrgent ? .orange : .gray)
    }
    
    Text(description)
      .font(.system(size: 12))
      .foregroundColor(.gray)
  }
  .padding(12)
  .background(Color.white.opacity(0.9))
  .cornerRadius(16)
}

// MARK: - AI洞察与趋势
private var aiInsightsSection: some View {
  VStack(alignment: .leading, spacing: 12) {
    Text("summary.ai.insights".localized)
      .font(.system(size: 14, weight: .medium))
      .padding(.horizontal, 16)
    
    VStack(alignment: .leading, spacing: 16) {
      HStack(spacing: 8) {
        ZStack {
          Circle()
            .fill(
              LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(width: 24, height: 24)
          
          Image(systemName: "brain")
            .foregroundColor(.white)
            .font(.system(size: 12))
        }
        
        Text("summary.personalized.insights".localized)
          .font(.system(size: 14, weight: .medium))
      }
      
      Text("根据您的活动模式分析，您在上午时段（9:00-11:00）记录信息效率最高，建议安排重要思考和创意工作在此时段。")
        .font(.system(size: 12))
        .foregroundColor(.primary)
      
      // 效率图表占位符
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.gray.opacity(0.1))
        .frame(height: 120)
        .overlay(
          VStack {
            Image(systemName: "chart.bar")
              .font(.system(size: 30))
              .foregroundColor(.gray.opacity(0.5))
            Text("summary.efficiency.analysis".localized)
              .font(.caption)
              .foregroundColor(.gray)
          }
        )
      
      Text("您本周关注的主要主题是\"用户体验\"和\"数据分析\"，相比上周有明显提升。")
        .font(.system(size: 12))
        .foregroundColor(.primary)
      
      HStack {
        Text("summary.efficiency.improvement".localized)
          .font(.system(size: 12))
          .padding(.horizontal, 8)
          .padding(.vertical, 2)
          .background(Color.yellow.opacity(0.3))
          .cornerRadius(8)
        
        Text("summary.work.habits".localized)
          .font(.system(size: 12))
          .padding(.horizontal, 8)
          .padding(.vertical, 2)
          .background(Color.blue.opacity(0.2))
          .cornerRadius(8)
        
        Spacer()
      }
    }
    .padding(16)
    .background(Color.blue.opacity(0.05))
    .cornerRadius(16)
  }
}

#Preview {
  SummaryView()
}

// MARK: - 建议行动数据模型
struct SuggestedAction {
  let icon: String
  let title: String
  let deadline: String
  let description: String
  let isUrgent: Bool
}

// MARK: - 临时实现函数
private func getSuggestedActions() -> [SuggestedAction] {
  return [
    SuggestedAction(
      icon: "clock.fill",
      title: "回复重要邮件",
      deadline: "今天 18:00",
      description: "处理来自客户的紧急询问邮件",
      isUrgent: true
    )
  ]
}
