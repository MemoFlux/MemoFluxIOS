//
//  ImageProcessor.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import Foundation
import UIKit

/// 图片处理工具类
/// 提供图片压缩和Base64编码功能
class ImageProcessor {
  
  /// 单例实例
  static let shared = ImageProcessor()
  
  private init() {}
  
  // MARK: - 图片压缩配置
  
  /// 压缩质量配置
  struct CompressionConfig {
    let maxWidth: CGFloat
    let maxHeight: CGFloat
    let compressionQuality: CGFloat
    
    /// 默认配置：最大尺寸800x800，压缩质量0.7
    static let `default` = CompressionConfig(
      maxWidth: 800,
      maxHeight: 800,
      compressionQuality: 0.7
    )
    
    /// 高质量配置：最大尺寸1200x1200，压缩质量0.8
    static let highQuality = CompressionConfig(
      maxWidth: 1200,
      maxHeight: 1200,
      compressionQuality: 0.8
    )
    
    /// 低质量配置：最大尺寸600x600，压缩质量0.5
    static let lowQuality = CompressionConfig(
      maxWidth: 600,
      maxHeight: 600,
      compressionQuality: 0.5
    )
  }
  
  // MARK: - 主要功能方法
  
  /// 压缩图片并转换为Base64编码
  /// - Parameters:
  ///   - image: 原始图片
  ///   - config: 压缩配置，默认使用标准配置
  /// - Returns: Base64编码的字符串，如果处理失败返回nil
  func compressAndEncodeToBase64(
    image: UIImage,
    config: CompressionConfig = .default
  ) -> String? {
    // 压缩图片
    guard let compressedImage = compressImage(image, config: config) else {
      print("图片压缩失败")
      return nil
    }
    
    // 转换为JPEG数据
    guard let imageData = compressedImage.jpegData(compressionQuality: config.compressionQuality) else {
      print("图片转换为JPEG数据失败")
      return nil
    }
    
    // 3. 转换为Base64
    let base64String = imageData.base64EncodedString()
    
    print("图片处理完成 - 原始尺寸: \(image.size), 压缩后尺寸: \(compressedImage.size), 数据大小: \(imageData.count) bytes")
    
    return base64String
  }
  
  /// 异步压缩图片并转换为Base64编码
  /// - Parameters:
  ///   - image: 原始图片
  ///   - config: 压缩配置
  ///   - completion: 完成回调，返回Base64字符串或nil
  func compressAndEncodeToBase64Async(
    image: UIImage,
    config: CompressionConfig = .default,
    completion: @escaping (String?) -> Void
  ) {
    DispatchQueue.global(qos: .userInitiated).async {
      let base64String = self.compressAndEncodeToBase64(image: image, config: config)
      DispatchQueue.main.async {
        completion(base64String)
      }
    }
  }
  
  // MARK: - Private Methods
  
  /// 压缩图片尺寸
  /// - Parameters:
  ///   - image: 原始图片
  ///   - config: 压缩配置
  /// - Returns: 压缩后的图片
  private func compressImage(_ image: UIImage, config: CompressionConfig) -> UIImage? {
    let originalSize = image.size
    
    if originalSize.width <= config.maxWidth && originalSize.height <= config.maxHeight {
      return image
    }
    
    // 保持宽高比
    let newSize = calculateNewSize(originalSize: originalSize, maxSize: CGSize(width: config.maxWidth, height: config.maxHeight))
    
    // 创建新的图片上下文
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    defer { UIGraphicsEndImageContext() }
    
    // 压缩后的图片
    image.draw(in: CGRect(origin: .zero, size: newSize))
    
    return UIGraphicsGetImageFromCurrentImageContext()
  }
  
  /// 计算新的图片尺寸，保持宽高比
  /// - Parameters:
  ///   - originalSize: 原始尺寸
  ///   - maxSize: 最大允许尺寸
  /// - Returns: 新的尺寸
  private func calculateNewSize(originalSize: CGSize, maxSize: CGSize) -> CGSize {
    let widthRatio = maxSize.width / originalSize.width
    let heightRatio = maxSize.height / originalSize.height
    let ratio = min(widthRatio, heightRatio)
    
    return CGSize(
      width: originalSize.width * ratio,
      height: originalSize.height * ratio
    )
  }
  
  // MARK: - 工具方法
  
  /// 从Base64字符串解码为UIImage
  /// - Parameter base64String: Base64编码的字符串
  /// - Returns: 解码后的图片，如果解码失败返回nil
  func decodeFromBase64(_ base64String: String) -> UIImage? {
    guard let imageData = Data(base64Encoded: base64String) else {
      print("Base64解码失败")
      return nil
    }
    
    return UIImage(data: imageData)
  }
  
  /// 获取图片的估算文件大小
  /// - Parameters:
  ///   - image: 图片
  ///   - compressionQuality: 压缩质量
  /// - Returns: 估算的文件大小（字节）
  func getEstimatedFileSize(image: UIImage, compressionQuality: CGFloat = 0.7) -> Int? {
    guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
      return nil
    }
    return imageData.count
  }
}

// MARK: - 扩展方法

extension ImageProcessor {
  
  /// 批量处理图片
  /// - Parameters:
  ///   - images: 图片数组
  ///   - config: 压缩配置
  ///   - completion: 完成回调，返回Base64字符串数组
  func batchCompressAndEncode(
    images: [UIImage],
    config: CompressionConfig = .default,
    completion: @escaping ([String]) -> Void
  ) {
    DispatchQueue.global(qos: .userInitiated).async {
      let base64Strings = images.compactMap { image in
        return self.compressAndEncodeToBase64(image: image, config: config)
      }
      
      DispatchQueue.main.async {
        completion(base64Strings)
      }
    }
  }
}
