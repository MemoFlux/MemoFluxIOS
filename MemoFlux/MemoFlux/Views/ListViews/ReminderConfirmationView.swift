//
//  ReminderConfirmationView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import SwiftUI

///  提醒事项二次确认视图
struct ReminderConfirmationView: View {
  let task: ScheduleTask
  @Environment(\.dismiss) private var dismiss
  
  @State private var reminderTitle: String = ""
  @State private var reminderNotes: String = ""
  @State private var reminderDate: Date = Date()
  @State private var hasDate: Bool = true
  @State private var isCreating: Bool = false
  
  var body: some View {
    NavigationView {
      Form {
        Section("标题") {
          TextField("输入提醒标题", text: $reminderTitle)
            .multilineTextAlignment(.leading)
        }
        
        Section("时间设置") {
          Toggle("设置提醒时间", isOn: $hasDate)
          
          if hasDate {
            DatePicker(
              "提醒时间",
              selection: $reminderDate,
              displayedComponents: [.date, .hourAndMinute]
            )
          }
        }
        
        Section("备注") {
          TextEditor(text: $reminderNotes)
            .frame(minHeight: 100, maxHeight: 240)  // 限制最大高度约10行
            .scrollContentBackground(.hidden)  // 隐藏默认背景
        }
      }
      .navigationTitle("创建提醒事项")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("取消") {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("创建") {
            createReminder()
          }
          .disabled(reminderTitle.isEmpty || isCreating)
        }
      }
      .onAppear {
        setupInitialValues()
      }
    }
  }
  
  private func setupInitialValues() {
    reminderTitle = task.theme
    reminderNotes = createReminderNotes()
    
    if let startDate = task.startDate {
      reminderDate = startDate
      hasDate = true
    } else {
      hasDate = false
    }
  }
  
  private func createReminderNotes() -> String {
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
  
  private func createReminder() {
    isCreating = true
    
    let finalDate = hasDate ? reminderDate : nil
    
    EventManager.shared.addReminder(
      title: reminderTitle,
      notes: reminderNotes,
      date: finalDate
    ) { success, error in
      DispatchQueue.main.async {
        isCreating = false
        
        if success {
          print("提醒事项创建成功")
          dismiss()
        } else {
          print("创建失败: \(error?.localizedDescription ?? "未知错误")")
        }
      }
    }
  }
}

#Preview {
  let sampleTask = ScheduleTask(
    startTime: "2024-05-16T09:00:00+08:00",
    endTime: "2024-05-16T17:00:00+08:00",
    people: ["张三", "李四"],
    theme: "项目会议",
    coreTasks: ["讨论项目进度", "确定下一步计划", "分配任务"],
    position: ["会议室A", "线上会议"],
    tags: ["工作", "会议", "重要"],
    category: "工作",
    suggestedActions: ["准备会议材料", "发送会议纪要"]
  )
  
  ReminderConfirmationView(task: sampleTask)
}
