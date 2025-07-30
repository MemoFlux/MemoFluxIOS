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
            
            Text("暂无标签")
              .font(.title2)
              .foregroundColor(.gray)
            
            Button("添加第一个标签") {
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
      .navigationTitle("标签管理")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("添加") {
            showingAddTag = true
          }
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
          Button("清理") {
            cleanupUnusedTags()
          }
          .foregroundColor(.red)
        }
      }
      .alert("添加标签", isPresented: $showingAddTag) {
        TextField("标签名称", text: $newTagName)
        Button("取消", role: .cancel) {
          newTagName = ""
        }
        Button("添加") {
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
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(tag.name)
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(.primary)
        
        HStack {
          Text("使用 \(tag.usageCount) 次")
            .font(.system(size: 12))
            .foregroundColor(.gray)
          
          Spacer()
          
          Text("最后使用: \(formatDate(tag.lastUsedAt))")
            .font(.system(size: 12))
            .foregroundColor(.gray)
        }
      }
      
      Spacer()
      
      Button("编辑") {
        editedName = tag.name
        showingEditAlert = true
      }
      .font(.system(size: 14))
      .foregroundColor(.blue)
    }
    .padding(.vertical, 4)
    .alert("编辑标签", isPresented: $showingEditAlert) {
      TextField("标签名称", text: $editedName)
      Button("取消", role: .cancel) {}
      Button("保存") {
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
  
  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.gray)
      
      TextField("搜索标签", text: $text)
        .textFieldStyle(RoundedBorderTextFieldStyle())
      
      if !text.isEmpty {
        Button("清除") {
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
