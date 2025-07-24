//
//  ScreenshotIntent.swift
//  ScreenshotIntent
//
//  Created by 马硕 on 2025/7/24.
//

import AppIntents
import UIKit


/// 获取截图 + 跳转app 的快捷指令实现
struct ScreenshotIntent: AppIntent {
    static var title: LocalizedStringResource = "接收截图"

    /// 快捷指令模块接收的指定参数
    @Parameter(title: "截图")
    var screenshot: IntentFile

    func perform() async throws -> some IntentResult {
        let imageData = screenshot.data

        guard let image = UIImage(data: imageData) else {
            throw AppIntentError.Unrecoverable.featureCurrentlyRestricted
        }

        let directory = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.shuoma.memoflux")
        guard let directory = directory else {
            throw AppIntentError.Unrecoverable.featureCurrentlyRestricted
        }
        let targetFileURL = directory.appendingPathComponent("imageFromShortcut.png")
        guard let pngImage = image.jpegData(compressionQuality: 1.0) else {
            throw AppIntentError.Unrecoverable.featureCurrentlyRestricted
        }
        try pngImage.write(to: targetFileURL)
        return .result()
    }
}
