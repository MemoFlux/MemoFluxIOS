//
//  SummaryView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import SwiftUI

struct SummaryView: View {
  @State private var selectedDate = Date()
  @State private var showDatePicker = false
  
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
          
          // 今日完成的任务
          completedTasksSection
          
          // 待处理建议行动
          suggestedActionsSection
          
          // AI洞察与趋势
          aiInsightsSection
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 100) // 为底部导航栏留出空间
      }
      .background(Color.globalStyleBackgroundColor)
      .navigationTitle("每日总结")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            showDatePicker.toggle()
          }) {
            Image(systemName: "calendar")
              .foregroundColor(.gray)
              .frame(width: 32, height: 32)
              .background(Color.white.opacity(0.9))
              .clipShape(Circle())
          }
        }
      }
    }
    .sheet(isPresented: $showDatePicker) {
      DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
        .datePickerStyle(GraphicalDatePickerStyle())
        .presentationDetents([.medium])
    }
  }
  
  // MARK: - 日期选择区域
  private var dateSelectionSection: some View {
    HStack {
      Button(action: {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
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
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
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
      Text("今日概览")
        .font(.system(size: 14, weight: .medium))
        .padding(.horizontal, 16)
      
      VStack(spacing: 16) {
        HStack(spacing: 0) {
          overviewItem(icon: "doc.text", title: "新增信息", count: "5", color: .blue)
          overviewItem(icon: "checkmark.circle", title: "完成任务", count: "3", color: .blue)
          overviewItem(icon: "lightbulb", title: "新建议", count: "2", color: .blue)
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
              Text("活动趋势图表")
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
        Text("今日新增信息")
          .font(.system(size: 14, weight: .medium))
        
        Spacer()
        
        Button("查看全部") {
          // 查看全部操作
        }
        .font(.system(size: 12))
        .foregroundColor(.blue)
      }
      .padding(.horizontal, 16)
      
      VStack(spacing: 12) {
        informationCard(
          icon: "note.text",
          title: "项目会议记录",
          time: "10:35",
          content: "讨论了新版本的用户反馈功能，确定下周开始开发。重点关注数据安全和隐私保护。",
          tags: ["#会议", "#项目"]
        )
        
        informationCard(
          icon: "link",
          title: "产品研究资料",
          time: "14:22",
          content: "收集了竞品分析报告和用户调研数据，对比了不同平台的功能差异和用户体验。",
          tags: ["#研究", "#竞品"]
        )
      }
    }
  }
  
  private func informationCard(icon: String, title: String, time: String, content: String, tags: [String]) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        HStack(spacing: 8) {
          ZStack {
            Circle()
              .fill(Color.blue.opacity(0.2))
              .frame(width: 24, height: 24)
            
            Image(systemName: icon)
              .foregroundColor(.blue)
              .font(.system(size: 12))
          }
          
          Text(title)
            .font(.system(size: 14, weight: .medium))
        }
        
        Spacer()
        
        Text(time)
          .font(.system(size: 10))
          .foregroundColor(.gray)
      }
      
      Text(content)
        .font(.system(size: 12))
        .foregroundColor(.primary)
        .lineLimit(nil)
      
      HStack {
        ForEach(tags, id: \.self) { tag in
          Text(tag)
            .font(.system(size: 10))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(tag.contains("会议") || tag.contains("研究") ? Color.yellow.opacity(0.3) : Color.blue.opacity(0.2))
            .cornerRadius(12)
        }
        Spacer()
      }
    }
    .padding(16)
    .background(Color.white.opacity(0.9))
    .cornerRadius(16)
  }
  
  // MARK: - 今日完成的任务
  private var completedTasksSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("今日完成的任务")
          .font(.system(size: 14, weight: .medium))
        
        Spacer()
        
        Button("查看全部") {
          // 查看全部操作
        }
        .font(.system(size: 12))
        .foregroundColor(.blue)
      }
      .padding(.horizontal, 16)
      
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
          
          Text("已完成任务 (3/5)")
            .font(.system(size: 14, weight: .medium))
        }
        
        VStack(spacing: 8) {
          taskItem(title: "提交产品需求文档", time: "11:20")
          taskItem(title: "用户研究报告审核", time: "15:45")
          taskItem(title: "与设计团队沟通界面反馈", time: "16:30")
        }
      }
      .padding(16)
      .background(Color.white.opacity(0.9))
      .cornerRadius(16)
    }
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
  
  // MARK: - 待处理建议行动
  private var suggestedActionsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("待处理建议行动")
        .font(.system(size: 14, weight: .medium))
        .padding(.horizontal, 16)
      
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Text("AI智能助手提醒")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
          
          Spacer()
          
          Image(systemName: "lightbulb.fill")
            .foregroundColor(.yellow)
        }
        
        VStack(spacing: 8) {
          actionItem(
            icon: "doc.text",
            title: "准备周报",
            deadline: "明天截止",
            description: "根据本周收集的数据和完成的任务，整理周工作报告",
            isUrgent: true
          )
          
          actionItem(
            icon: "bubble.left.and.bubble.right",
            title: "团队沟通",
            deadline: "推荐今日完成",
            description: "就产品新功能向开发团队进行详细说明，确保理解一致",
            isUrgent: false
          )
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
  
  private func actionItem(icon: String, title: String, deadline: String, description: String, isUrgent: Bool) -> some View {
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
      Text("AI洞察与趋势")
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
          
          Text("个性化洞察")
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
              Text("效率分析图表")
                .font(.caption)
                .foregroundColor(.gray)
            }
          )
        
        Text("您本周关注的主要主题是\"用户体验\"和\"数据分析\"，相比上周有明显提升。")
          .font(.system(size: 12))
          .foregroundColor(.primary)
        
        HStack {
          Text("#效率提升")
            .font(.system(size: 12))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.yellow.opacity(0.3))
            .cornerRadius(12)
          
          Text("#工作习惯")
            .font(.system(size: 12))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(12)
          
          Spacer()
        }
      }
      .padding(16)
      .background(Color.blue.opacity(0.05))
      .cornerRadius(16)
    }
  }
}

#Preview {
  SummaryView()
}
