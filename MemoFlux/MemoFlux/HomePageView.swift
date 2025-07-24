//
//  HomePageView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftUI

struct HomePageView: View {
    @State private var images: [UIImage] = []

    var body: some View {
        if images.isEmpty {
            ContentUnavailableView("没有内容", systemImage: "photo", description: Text("请从快捷指令或其他方式导入内容。"))
                
        } else {
            List(images.indices, id: \.self) { index in
                Image(uiImage: images[index])
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
            .onAppear {
                loadImage()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                loadImage()
            }
        }
    }

    func loadImage() {
        let fileManager = FileManager.default
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.shuoma.memoflux") {
            let fileURL = directory.appendingPathComponent("imageFromShortcut.png")
            if let imageData = try? Data(contentsOf: fileURL),
               let newImage = UIImage(data: imageData) {
                images.append(newImage)
            }
        }
    }
}

#Preview {
    HomePageView()
}
