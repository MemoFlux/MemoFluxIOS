//
//  HomePageView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftData
import SwiftUI

struct HomePageView: View {
  // SwiftData查询所有MemoItemModel，创建时间降序排列
  @Query(sort: \MemoItemModel.createdAt, order: .reverse) private var memoItems: [MemoItemModel]
  
  @Environment(\.modelContext) private var modelContext
  
  @State private var showingAddMemoView = false
  @State private var isSearchActive = false
  
  var body: some View {
    NavigationStack {
      MemoListView(
        memoItems: memoItems,
        modelContext: modelContext,
        isSearchActive: $isSearchActive
      )
      .background(Color.globalStyleBackgroundColor)
      .onAppear {
        loadImage()
      }
      .onReceive(
        NotificationCenter.default.publisher(
          for: UIApplication.willEnterForegroundNotification)
      ) { _ in
        loadImage()
      }
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          // 搜索按钮
          Button {
            isSearchActive = true
          } label: {
            Image(systemName: "magnifyingglass")
              .font(.system(size: 18, weight: .medium))
          }
          
          // 添加按钮
          Button {
            showingAddMemoView = true
          } label: {
            Image(systemName: "plus")
              .font(.system(size: 18, weight: .bold))
          }
        }
      }
    }
    .fullScreenCover(isPresented: $showingAddMemoView) {
      AddMemoItemView()
    }
  }
  
  // MARK: - 图片加载
  func loadImage() {
    let fileManager = FileManager.default
    if let directory = fileManager.containerURL(
      forSecurityApplicationGroupIdentifier: "group.com.shuoma.memoflux")
    {
      let fileURL = directory.appendingPathComponent("imageFromShortcut.png")
      if let imageData = try? Data(contentsOf: fileURL),
         let newImage = UIImage(data: imageData)
      {
        let newItem = MemoItemModel(image: newImage, source: "快捷指令")
        
        // 检查是否存在相同item
        let exists = memoItems.contains { item in
          MemoItemModel.areEqual(item, newItem)
        }
        
        if !exists {
          modelContext.insert(newItem)
          
          do {
            try modelContext.save()
            print("新MemoItem添加成功并保存到swiftData，UUID: \(newItem.id)")
            
            // 自动发送API请求处理快捷指令传入的图片
            processShortcutImage(newItem)
            
          } catch {
            print("保存MemoItem失败: \(error)")
          }
        }
      }
    }
  }
  
  // MARK: - 处理快捷指令图片
  private func processShortcutImage(_ memoItem: MemoItemModel) {
    // 标记开始API处理
    memoItem.startAPIProcessing()
    
    // 保存状态更新
    do {
      try modelContext.save()
    } catch {
      print("更新API处理状态失败: \(error)")
    }
    
    // 获取所有现有标签
    let allTags = NetworkManager.shared.getAllTags(from: modelContext)
    
    // 发送API请求
    NetworkManager.shared.generateAIResponse(
      from: memoItem,
      allTags: allTags
    ) { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let response):
          print("快捷指令图片API请求成功")
          // 保存API响应到MemoItem
          memoItem.setAPIResponse(response)
          
          // 更新标签（合并API返回的标签）
          let newTags = Set(memoItem.tags)
            .union(response.knowledge.tags)
            .union(response.information.tags)
            .union(response.schedule.tasks.flatMap { $0.tags })
          memoItem.tags = Array(newTags)
          
          // 如果有标题，更新标题
          if !response.information.title.isEmpty {
            memoItem.title = response.information.title
          }
          
        case .failure(let error):
          print("快捷指令图片API请求失败: \(error.localizedDescription)")
          memoItem.apiProcessingFailed()
        }
        
        // 保存更新
        do {
          try modelContext.save()
          print("快捷指令图片API响应保存成功")
        } catch {
          print("保存快捷指令图片API响应失败: \(error)")
        }
      }
    }
  }
}

#Preview {
  HomePageView()
}
