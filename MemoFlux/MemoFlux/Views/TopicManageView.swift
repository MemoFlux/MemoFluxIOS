//
//  TopicManagementView.swift
//  MemoFlux
//
//  Created by AI Assistant on 2025/12/05.
//

import SwiftUI
import SwiftData

/// 主题管理视图
struct TopicManagementView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var memos: [MemoItemModel]
  @ObservedObject private var languageManager = LanguageManager.shared
  @State private var searchText = ""
  
  // 提取所有主题并封装为 TopicItem 模型以便在 List 中显示
  private var allTopics: [TopicItem] {
    let topics = Set(memos.compactMap { memo -> String? in
      guard let response = memo.apiResponse, !response.mostPossibleCategory.isEmpty else { return nil }
      return response.mostPossibleCategory
    })
    
    return topics.map { topic in
      let count = memos.filter { $0.apiResponse?.mostPossibleCategory == topic }.count
      // 简单的最后使用时间逻辑：取该主题下最近创建的Memo的时间
      let lastUsed = memos
        .filter { $0.apiResponse?.mostPossibleCategory == topic }
        .map { $0.createdAt }
        .max() ?? Date()
      return TopicItem(name: topic, usageCount: count, lastUsedAt: lastUsed)
    }
    .sorted { $0.usageCount > $1.usageCount }
  }
  
  private var filteredTopics: [TopicItem] {
    if searchText.isEmpty {
      return allTopics
    } else {
      return allTopics.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        // 搜索栏
        TopicSearchBar(text: $searchText)
          .padding(.horizontal)
        
        if filteredTopics.isEmpty {
          // 空状态
          VStack(spacing: 16) {
            Image(systemName: "folder.badge.questionmark")
              .font(.system(size: 48))
              .foregroundColor(.gray)
            
            Text(AppStrings.noTopicsFound)
              .font(.title2)
              .foregroundColor(.gray)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          // 主题列表
          List {
            ForEach(filteredTopics) { topic in
              TopicManagementRowView(topic: topic, memos: memos, modelContext: modelContext)
            }
            .onDelete(perform: deleteTopics)
          }
          .listStyle(PlainListStyle())
        }
      }
      .background(Color.globalStyleBackgroundColor)
      .navigationTitle(AppStrings.topicManagement)
      .navigationBarTitleDisplayMode(.large)
    }
  }
  
  // MARK: - 私有方法
  
  private func deleteTopics(offsets: IndexSet) {
    for index in offsets {
      let topic = filteredTopics[index]
      deleteTopic(topic.name)
    }
  }
  
  private func deleteTopic(_ topicName: String) {
    // 找到所有该主题的Memo，清空其 category
    let targetMemos = memos.filter { $0.apiResponse?.mostPossibleCategory == topicName }
    
    for memo in targetMemos {
      guard var apiResponse = memo.apiResponse else { continue }
      
      // 更新 APIResponse 中的 category 为空或默认值
      // 由于 APIResponse 是 struct，需要重新创建或修改
      // 这里需要一种方式更新 MemoItemModel 中的 apiResponseData
      // 我们需要手动修改 apiResponseData JSON
      
      // 简单起见，我们可以尝试解码-修改-编码
      updateMemoCategory(memo, newCategory: "")
    }
    
    do {
      try modelContext.save()
    } catch {
      print("删除主题失败: \(error)")
    }
  }
  
  private func updateMemoCategory(_ memo: MemoItemModel, newCategory: String) {
    guard var apiResponse = memo.apiResponse else { return }
    
    // 创建一个新的 APIResponse (由于属性是 let，可能需要重新构建整个对象或者如果 Model 支持修改)
    // 查看 MemoItemModel 定义，mostPossibleCategory 是 let。
    // 我们需要创建一个新的 APIResponse 实例。
    
    let newResponse = MemoItemModel.APIResponse(
      mostPossibleCategory: newCategory,
      information: apiResponse.information,
      schedule: apiResponse.schedule
    )
    
    memo.setAPIResponse(newResponse, in: modelContext)
  }
}

/// 临时主题模型
struct TopicItem: Identifiable {
  let id = UUID()
  var name: String
  var usageCount: Int
  var lastUsedAt: Date
}

/// 主题管理行视图
struct TopicManagementRowView: View {
  let topic: TopicItem
  let memos: [MemoItemModel]
  let modelContext: ModelContext
  @State private var showingEditAlert = false
  @State private var editedName = ""
  @ObservedObject private var languageManager = LanguageManager.shared
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(topic.name)
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(.primary)
        
        HStack {
          Text(AppStrings.usedCount(topic.usageCount))
            .font(.system(size: 12))
            .foregroundColor(.gray)
          
          Spacer()
          
          Text(AppStrings.lastUsed(formatDate(topic.lastUsedAt)))
            .font(.system(size: 12))
            .foregroundColor(.gray)
        }
      }
      
      Spacer()
      
      Button(AppStrings.edit) {
        editedName = topic.name
        showingEditAlert = true
      }
      .font(.system(size: 14))
      .foregroundColor(.blue)
    }
    .padding(.vertical, 4)
    .alert(AppStrings.editTopic, isPresented: $showingEditAlert) {
      TextField(AppStrings.topicName, text: $editedName)
      Button(AppStrings.cancel, role: .cancel) {}
      Button(AppStrings.save) {
        renameTopic(from: topic.name, to: editedName)
      }
      .disabled(editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
  }
  
  private func renameTopic(from oldName: String, to newName: String) {
    let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedName.isEmpty, trimmedName != oldName else { return }
    
    let targetMemos = memos.filter { $0.apiResponse?.mostPossibleCategory == oldName }
    
    for memo in targetMemos {
      guard var apiResponse = memo.apiResponse else { continue }
      
      let newResponse = MemoItemModel.APIResponse(
        mostPossibleCategory: trimmedName,
        information: apiResponse.information,
        schedule: apiResponse.schedule
      )
      
      memo.setAPIResponse(newResponse, in: modelContext)
    }
    
    do {
      try modelContext.save()
    } catch {
      print("重命名主题失败: \(error)")
    }
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter.string(from: date)
  }
}

/// 主题搜索栏组件
struct TopicSearchBar: View {
  @Binding var text: String
  @ObservedObject private var languageManager = LanguageManager.shared
  
  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.gray)
      
      TextField(AppStrings.searchTopics, text: $text)
        .textFieldStyle(RoundedBorderTextFieldStyle())
      
      if !text.isEmpty {
        Button(AppStrings.clear) {
          text = ""
        }
        .foregroundColor(.gray)
      }
    }
  }
}


