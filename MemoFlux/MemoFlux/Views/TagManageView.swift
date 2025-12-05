//
//  TagManageView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/30.
//

import SwiftUI
import SwiftData

/// 标签管理视图（可选的高级功能）
struct TagManagementView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var tagModels: [TagModel]
  @ObservedObject private var languageManager = LanguageManager.shared
  @State private var searchText = ""
  @State private var showingAddTag = false
  @State private var newTagName = ""
  
  private var filteredTags: [TagModel] {
    if searchText.isEmpty {
      return tagModels.sorted { $0.usageCount > $1.usageCount }
    } else {
      return TagManager.shared.searchTags(query: searchText, in: modelContext)
    }
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        // 搜索栏
        SearchBar(text: $searchText)
          .padding(.horizontal)
        
        if filteredTags.isEmpty {
          // 空状态
          VStack(spacing: 16) {
            Image(systemName: "tag.slash")
              .font(.system(size: 48))
              .foregroundColor(.gray)
            
            Text(AppStrings.noTags)
              .font(.title2)
              .foregroundColor(.gray)
            
            Button(AppStrings.addFirstTag) {
              showingAddTag = true
            }
            .buttonStyle(.borderedProminent)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          // 标签列表
          List {
            ForEach(filteredTags) { tag in
              TagManagementRowView(tag: tag, modelContext: modelContext)
            }
            .onDelete(perform: deleteTags)
          }
          .listStyle(PlainListStyle())
        }
      }
      .background(Color.globalStyleBackgroundColor)
      .navigationTitle(AppStrings.tagManagement)
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(AppStrings.add) {
            showingAddTag = true
          }
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
          Button(AppStrings.cleanup) {
            cleanupUnusedTags()
          }
          .foregroundColor(.red)
        }
      }
      .alert(AppStrings.addTag, isPresented: $showingAddTag) {
        TextField(AppStrings.tagName, text: $newTagName)
        Button(AppStrings.cancel, role: .cancel) {
          newTagName = ""
        }
        Button(AppStrings.add) {
          addNewTag()
        }
        .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
      }
    }
  }
  
  // MARK: - 私有方法
  
  private func deleteTags(offsets: IndexSet) {
    for index in offsets {
      let tag = filteredTags[index]
      TagManager.shared.deleteTag(tag, from: modelContext)
    }
    
    do {
      try modelContext.save()
    } catch {
      print("删除标签失败: \(error)")
    }
  }
  
  private func addNewTag() {
    let trimmedName = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedName.isEmpty else { return }
    
    TagManager.shared.createOrUpdateTag(name: trimmedName, in: modelContext)
    
    do {
      try modelContext.save()
      newTagName = ""
    } catch {
      print("添加标签失败: \(error)")
    }
  }
  
  private func cleanupUnusedTags() {
    TagManager.shared.cleanupUnusedTags(from: modelContext)
  }
}

/// 标签管理行视图
struct TagManagementRowView: View {
  let tag: TagModel
  let modelContext: ModelContext
  @State private var showingEditAlert = false
  @State private var editedName = ""
  @ObservedObject private var languageManager = LanguageManager.shared
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(tag.name)
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(.primary)
        
        HStack {
          Text(AppStrings.usedCount(tag.usageCount))
            .font(.system(size: 12))
            .foregroundColor(.gray)
          
          Spacer()
          
          Text(AppStrings.lastUsed(formatDate(tag.lastUsedAt)))
            .font(.system(size: 12))
            .foregroundColor(.gray)
        }
      }
      
      Spacer()
      
      Button(AppStrings.edit) {
        editedName = tag.name
        showingEditAlert = true
      }
      .font(.system(size: 14))
      .foregroundColor(.blue)
    }
    .padding(.vertical, 4)
    .alert(AppStrings.editTag, isPresented: $showingEditAlert) {
      TextField(AppStrings.tagName, text: $editedName)
      Button(AppStrings.cancel, role: .cancel) {}
      Button(AppStrings.save) {
        updateTagName()
      }
      .disabled(editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
  }
  
  private func updateTagName() {
    let trimmedName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedName.isEmpty, trimmedName != tag.name else { return }
    
    tag.name = trimmedName
    
    do {
      try modelContext.save()
    } catch {
      print("更新标签名称失败: \(error)")
    }
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter.string(from: date)
  }
}

/// 搜索栏组件
struct SearchBar: View {
  @Binding var text: String
  @ObservedObject private var languageManager = LanguageManager.shared
  
  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.gray)
      
      TextField(AppStrings.searchTags, text: $text)
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

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: MemoItemModel.self, TagModel.self, configurations: config)
  
  TagManagementView()
    .modelContainer(container)
}
