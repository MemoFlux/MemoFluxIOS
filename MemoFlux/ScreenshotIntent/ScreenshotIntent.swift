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
      if #available(iOS 18.0, *) {
        throw AppIntentError.Unrecoverable.featureCurrentlyRestricted
      } else {
        throw $screenshot.needsValueError("无法解析图片数据")
      }
    }

    let directory = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: "group.com.shuoma.memofluxapp")

    guard let directory = directory else {
      if #available(iOS 18.0, *) {
        throw AppIntentError.Unrecoverable.featureCurrentlyRestricted
      } else {
        struct DirectoryError: Error, LocalizedError {
          var errorDescription: String? { "无法访问共享容器目录" }
        }
        throw DirectoryError()
      }
    }

    let targetFileURL = directory.appendingPathComponent("imageFromShortcut.png")

    guard let pngImage = image.pngData() else {
      if #available(iOS 18.0, *) {
        throw AppIntentError.Unrecoverable.featureCurrentlyRestricted
      } else {
        struct ImageConversionError: Error, LocalizedError {
          var errorDescription: String? { "无法将图片转换为PNG格式" }
        }
        throw ImageConversionError()
      }
    }

    try pngImage.write(to: targetFileURL)

    return .result()
  }
}
