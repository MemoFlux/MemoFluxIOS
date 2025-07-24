//
//  ListView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftUI
import Vision
import VisionKit

struct ListView: View {
    @Binding var images: [UIImage]
    @State private var recognizedTexts: [String] = []
    
    var body: some View {
        if images.isEmpty { 
            ContentUnavailableView("没有内容", systemImage: "photo", description: Text("请从快捷指令或其他方式导入内容。"))
        } else {
            List(images.indices, id: \.self) { index in
                VStack {
                    Image(uiImage: images[index])
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .onAppear {
                            recognizeText(from: images[index], at: index)
                        }
                    
                    if index < recognizedTexts.count && !recognizedTexts[index].isEmpty {
                        Text("识别结果：")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        Text(recognizedTexts[index])
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    /// 对传入文字进行本地 OCR 识别操作
    private func recognizeText(from image: UIImage, at index: Int) {
        // 确保recognizedTexts数组有足够的元素
        while recognizedTexts.count <= index {
            recognizedTexts.append("")
        }
        
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
                self.recognizedTexts[index] = text
                print("识别到的文字: \(text)")
            }
        }
        
        request.recognitionLanguages = ["zh-CN", "en-US"]
        request.recognitionLevel = .accurate // 精确模式
        
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
