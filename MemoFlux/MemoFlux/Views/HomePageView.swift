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
  @State private var showingAddMemoDirectlyView = false
  
  var body: some View {
    NavigationStack {
      ListView(memoItems: memoItems, modelContext: modelContext)
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
          ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
              Section(header: Text("新建Memo")) {
                Button {
                  showingAddMemoView = true
                } label: {
                  Label("AI解析Memo", systemImage: "brain")
                }
                
                Button {
                  showingAddMemoDirectlyView = true
                } label: {
                  Label("直接添加Memo", systemImage: "square.and.pencil")
                }
              }
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
    .fullScreenCover(isPresented: $showingAddMemoDirectlyView) {
      AddMemoItemDirectlyView()
    }
  }
  
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
          try? modelContext.save()
          print("新MemoItem添加成功并保存到swiftData，UUID: \(newItem.id)")
        }
      }
    }
  }
}

#Preview {
  HomePageView()
}
