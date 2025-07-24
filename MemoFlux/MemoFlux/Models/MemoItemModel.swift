//
//  MemoItemModel.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import Foundation
import SwiftData
import SwiftUI

/// 首页 List cell 中 item 的数据模型
@Model
final class MemoItemModel: Identifiable {
    var id: UUID
    var imageData: Data?  // 存储图片数据
    var recognizedText: String
    var title: String
    var tags: [String]
    var createdAt: Date
    var scheduledDate: Date?
    var source: String

    // 计算属性获取UIImage
    var image: UIImage? {
        if let imageData = imageData {
            return UIImage(data: imageData)
        }
        return nil
    }

    init(image: UIImage, title: String = "", tags: [String] = [], source: String = "") {
        self.id = UUID()
        self.imageData = image.pngData()  // 将UIImage转换为Data类型存储，避免swiftData无法存储UIImage的问题
        self.recognizedText = ""
        self.title = title
        self.tags = tags
        self.createdAt = Date()
        self.scheduledDate = nil
        self.source = source
    }

    // 初始化，用于swiftData
    init(
        id: UUID = UUID(), imageData: Data? = nil, recognizedText: String = "", title: String = "",
        tags: [String] = [], createdAt: Date = Date(), scheduledDate: Date? = nil,
        source: String = ""
    ) {
        self.id = id
        self.imageData = imageData
        self.recognizedText = recognizedText
        self.title = title
        self.tags = tags
        self.createdAt = createdAt
        self.scheduledDate = scheduledDate
        self.source = source
    }

    // 判断两个MemoItem是否相同
    static func areEqual(_ lhs: MemoItemModel, _ rhs: MemoItemModel) -> Bool {
        if lhs.id == rhs.id {
            return true
        }

        if let lhsData = lhs.imageData,
            let rhsData = rhs.imageData,
            lhsData == rhsData
        {
            return true
        }

        return false
    }
}
