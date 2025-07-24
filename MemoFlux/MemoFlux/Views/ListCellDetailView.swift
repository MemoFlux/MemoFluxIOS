//
//  ListCellDetailView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import EventKit
import EventKitUI
import SwiftData
import SwiftUI

struct ListCellDetailView: View {
    let item: MemoItemModel
    @State private var showingCalendarAlert = false
    @State private var showingReminderAlert = false
    @State private var calendarStatus = ""
    @State private var reminderStatus = ""
    
    @State private var showingReminderConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let image = item.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: UIScreen.main.bounds.height / 2)  // 限制最大高度为屏幕高度的一半
                }
                
                if !item.title.isEmpty {
                    Text(item.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                }
                
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
                
                HStack(spacing: 16) {
                    Button(action: {
                        addToCalendar()
                    }) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("添加到日历")
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .alert("日历", isPresented: $showingCalendarAlert) {
                        Button("确定", role: .cancel) {}
                    } message: {
                        Text(calendarStatus)
                    }
                    
                    Button(action: {
                        showingReminderConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "list.bullet.clipboard")
                            Text("添加到提醒事项")
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .alert("提醒事项", isPresented: $showingReminderAlert) {
                        Button("确定", role: .cancel) {}
                    } message: {
                        Text(reminderStatus)
                    }
                    .sheet(isPresented: $showingReminderConfirmation) {
                        ReminderConfirmationView(
                            item: item, isPresented: $showingReminderConfirmation,
                            onConfirm: { title, notes, date, hasDate in
                                // 传递修改后的值给addToReminder方法
                                addToReminder(
                                    title: title, notes: notes, date: hasDate ? date : nil)
                            })
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
                
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
                
                Divider()
                    .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("识别内容")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if !item.recognizedText.isEmpty {
                        Text(item.recognizedText)
                            .font(.body)
                            .padding()
                            .background(Color.gray.opacity(0.1))
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
            .padding(.vertical)
        }
        .navigationTitle("详细信息")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 添加到日历
    private func addToCalendar() {
        EventManager.shared.requestCalendarAccess { granted, error in
            if granted && error == nil {
                let event = EventManager.shared.createCalendarEvent(
                    title: self.item.title,
                    notes: self.item.recognizedText,
                    startDate: self.item.scheduledDate ?? Date()
                )
                
                EventManager.shared.presentCalendarEventEditor(for: event)
            } else {
                self.calendarStatus = "无法访问日历: \(error?.localizedDescription ?? "未授权")"
                self.showingCalendarAlert = true
            }
        }
    }
    
    // MARK: - 添加到提醒事项
    private func addToReminder(title: String, notes: String, date: Date?) {
        EventManager.shared.addReminder(title: title, notes: notes, date: date) { success, error in
            if success {
                self.reminderStatus = "已成功添加到提醒事项"
            } else {
                self.reminderStatus = "添加到提醒事项失败: \(error?.localizedDescription ?? "未知错误")"
            }
            self.showingReminderAlert = true
        }
    }
}

// MARK: - 添加到提醒事项的二次确认视图
struct ReminderConfirmationView: View {
    let item: MemoItemModel
    @Binding var isPresented: Bool
    let onConfirm: (String, String, Date, Bool) -> Void //传递所有提醒事项字段
    
    @State private var reminderTitle: String
    @State private var reminderNotes: String
    @State private var reminderDate: Date
    @State private var hasDate: Bool
    
    init(
        item: MemoItemModel, isPresented: Binding<Bool>,
        onConfirm: @escaping (String, String, Date, Bool) -> Void
    ) {
        self.item = item
        self._isPresented = isPresented
        self.onConfirm = onConfirm
        
        // 初始化状态变量
        self.reminderTitle = item.title.isEmpty ? "备忘录" : item.title
        self.reminderNotes = item.recognizedText
        self.reminderDate = item.scheduledDate ?? Date()
        self.hasDate = item.scheduledDate != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("提醒事项详情")) {
                    TextField("标题", text: $reminderTitle)
                    
                    Toggle("设置日期", isOn: $hasDate)
                    
                    if hasDate {
                        DatePicker(
                            "日期和时间", selection: $reminderDate,
                            displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    VStack(alignment: .leading) {
                        Text("备注")
                        TextEditor(text: $reminderNotes)
                            .frame(minHeight: 100)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("添加到提醒事项")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {                        onConfirm(reminderTitle, reminderNotes, reminderDate, hasDate)
                        isPresented = false
                    }
                }
            }
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
