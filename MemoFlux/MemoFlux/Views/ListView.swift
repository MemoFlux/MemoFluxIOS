//
//  ListView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftData
import SwiftUI
import Vision
import VisionKit

struct ListView: View {
    let memoItems: [MemoItemModel]
    let modelContext: ModelContext

    var body: some View {
        if memoItems.isEmpty {
            ContentUnavailableView(
                "没有内容", systemImage: "photo", description: Text("请从快捷指令或其他来源导入内容。"))
        } else {
            NavigationStack {
                List(memoItems) { item in
                    NavigationLink(destination: ListCellDetailView(item: item)) {
                        AdaptiveListCellLayout(item: item)
                            .onAppear {
                                if item.recognizedText.isEmpty, let image = item.image {
                                    recognizeText(for: item, image: image)
                                }
                            }
                    }
                }
                .navigationTitle("Today")
            }
        }
    }

    /// 对传入文字进行本地 OCR 识别操作
    private func recognizeText(for item: MemoItemModel, image: UIImage) {
        let request = VNRecognizeTextRequest { (request, error) in
            guard error == nil else {
                print("文字识别错误: \(error!.localizedDescription)")
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }

            // 识别文本提取
            let recognizedStrings = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }

            let text = recognizedStrings.joined(separator: "\n")
            
            DispatchQueue.main.async {
                // 更新对应的MemoItem并保存到swiftData
                item.recognizedText = text
                try? modelContext.save()
            }
        }

        request.recognitionLanguages = ["zh-CN", "en-US"]
        request.recognitionLevel = .accurate  // 精确模式

        // 图像处理请求处理器
        guard let cgImage = image.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try requestHandler.perform([request])
        } catch {
            print("无法执行文字识别请求: \(error.localizedDescription)")
        }
    }
}

/// 自适应的列表 cell 布局组件，根据图片长宽比自动选择横向/竖向布局方式
struct AdaptiveListCellLayout: View {
    let item: MemoItemModel

    @State private var textHeight: CGFloat = 0
    @State private var imageHeight: CGFloat = 0

    private var isPortrait: Bool {
        guard let image = item.image else { return false }
        let aspectRatio = image.size.width / image.size.height
        return aspectRatio < 0.85  // 当宽高比小于0.85时，为竖向图片
    }

    var body: some View {
        if isPortrait {
            // 横向
            HStack(alignment: .top, spacing: 20) {
                imageView
                    .frame(width: 120)
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onAppear {
                                imageHeight = geometry.size.height
                            }
                        })
                textView
            }
            .padding(.vertical, 8)
        } else {
            // 纵向
            VStack(alignment: .leading, spacing: 8) {
                imageView
                textView
            }
            .padding(.vertical, 8)
        }
    }

    private var imageView: some View {
        Group {
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
            }
        }
    }

    private var textView: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !item.recognizedText.isEmpty {
                Text(item.recognizedText)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: isPortrait ? imageHeight : nil)
            } else {
                Text("正在识别文字...")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(height: isPortrait ? imageHeight : nil)
            }
        }
    }
}
