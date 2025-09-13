//
//  IntentDiscoveryView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/25.
//

import SwiftData
import SwiftUI

/// 发现待处理意图视图
struct IntentDiscoveryView: View {
  let memoItems: [MemoItemModel]
  
  private var todayScheduleIntents: [IntentDiscoveryViewModel] {
    let calendar = Calendar.current
    let today = Date()
    
    var intents: [IntentDiscoveryViewModel] = []
    
    for memoItem in memoItems {
      guard calendar.isDate(memoItem.createdAt, inSameDayAs: today) else { continue }
      
      guard let apiResponse = memoItem.apiResponse,
            !apiResponse.schedule.tasks.isEmpty
      else { continue }
      
      for task in apiResponse.schedule.tasks {
        let intent = IntentDiscoveryViewModel(memoItem: memoItem, scheduleTask: task)
        intents.append(intent)
      }
    }
    
    return intents
  }
  
  private var hasIntents: Bool {
    !todayScheduleIntents.isEmpty
  }
  
  var body: some View {
    if hasIntents {
      VStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            HStack(spacing: 8) {
              Image(systemName: "bell.fill")
                .font(.system(size: 14))
                .foregroundColor(.orange)
              
              Text("今日待处理意图")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            }
            
            Spacer()
          }
          .padding(.bottom, 12)
          
          ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 8) {
              ForEach(todayScheduleIntents) { intent in
                NavigationLink(destination: ListCellDetailView(item: intent.memoItem)) {
                  TodayScheduleIntentRowView(intent: intent)
                }
                .buttonStyle(PlainButtonStyle())
              }
            }
            .padding(.vertical, 1)
          }
          .frame(
            height: todayScheduleIntents.count <= 3
            ? CGFloat(todayScheduleIntents.count) * 60
            : min(CGFloat(todayScheduleIntents.count) * 60, 220)
          )
          .scrollDisabled(todayScheduleIntents.count <= 3)
        }
        .padding(16)
        .background(Color.yellowBackgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
      }
    } else {
      VStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            HStack(spacing: 8) {
              Image(systemName: "checkmark")
                .font(.system(size: 14))
                .foregroundColor(.green)
              
              Text("今日暂无未处理意图！")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            }
            
            Spacer()
          }
        }
        .padding(16)
        .background(Color.greenBackgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
      }
    }
  }
}

/// 今日日程意图行视图
struct TodayScheduleIntentRowView: View {
  let intent: IntentDiscoveryViewModel
  
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: intent.iconName)
        .font(.system(size: 16))
        .foregroundColor(intent.iconColor)
        .frame(width: 20, height: 20)
      
      VStack(alignment: .leading, spacing: 2) {
        Text(intent.title)
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.primary)
          .frame(maxWidth: .infinity, alignment: .leading)
        
        if let startDate = intent.scheduleTask.startDate {
          Text(startDate.formatted(date: .omitted, time: .shortened))
            .font(.system(size: 12))
            .foregroundColor(.secondary)
        }
      }
      
      Spacer()
      
      Image(systemName: "chevron.right")
        .font(.system(size: 12))
        .foregroundColor(.secondary)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .background(Color.white)
    .cornerRadius(8)
    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
  }
}

// MARK: - 向后兼容的空视图
extension IntentDiscoveryView {
  init() {
    self.memoItems = []
  }
}

// MARK: - 预览
#Preview {
  let testMemoItems = createTestMemoItemsWithSchedule()
  
  VStack(spacing: 16) {
    VStack(spacing: 12) {
      IntentDiscoveryView(memoItems: testMemoItems)
      
      VStack(alignment: .leading, spacing: 12) {
        Text("其他内容卡片")
          .font(.system(size: 16, weight: .bold))
        Text("这里是其他内容的示例，用来展示意图发现卡片在列表中的效果")
          .font(.system(size: 14))
          .foregroundColor(.secondary)
      }
      .padding(16)
      .background(Color.white)
      .cornerRadius(16)
      .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
  }
  .padding()
  .background(Color.globalStyleBackgroundColor)
}

// 测试数据辅助函数
private func createTestMemoItemsWithSchedule() -> [MemoItemModel] {
  let testItem = MemoItemModel(
    imageData: nil,
    recognizedText: "今日会议安排",
    title: "项目进度会议",
    tags: ["会议", "项目"],
    createdAt: Date(),
    source: "测试数据"
  )
  
  // 模拟 API 响应
  let scheduleTask = MemoItemModel.ScheduleTask(
    startTime: "2024-05-16T10:30:00+08:00",
    endTime: "2024-05-16T11:30:00+08:00",
    people: ["张三", "李四"],
    theme: "项目进度讨论",
    coreTasks: ["讨论当前进度", "制定下阶段计划"],
    position: ["会议室A"],
    tags: ["重要", "项目"],
    category: "工作会议",
    suggestedActions: ["准备进度报告", "整理问题清单"],
    id: UUID()
  )
  
  let apiResponse = MemoItemModel.APIResponse(
    mostPossibleCategory: "schedule",
    information: MemoItemModel.Information(
      title: "会议安排知识",
      informationItems: [],
      relatedItems: [],
      summary: "",
      tags: ["会议", "项目"]
    ),
    schedule: MemoItemModel.Schedule(
      title: "今日日程",
      category: "工作",
      tasks: [scheduleTask]
    )
  )
  
  // 为Preview创建临时的ModelContext
  let container = try! ModelContainer(for: MemoItemModel.self, ScheduleTaskModel.self)
  let context = ModelContext(container)
  
  testItem.setAPIResponse(apiResponse, in: context)
  
  return [testItem]
}
