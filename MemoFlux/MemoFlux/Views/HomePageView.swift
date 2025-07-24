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
        ListView(images: $images)
            .onAppear {
                loadImage()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                loadImage()
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
