//
//  ColorUtils.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import Foundation
import SwiftUI

extension Color {
  // 全局背景色
  static let globalStyleBackgroundColor = Color(red: 240 / 255, green: 249 / 255, blue: 255 / 255)
  
  // 全局主题色
  // static let mainStyleBackgroundColor = Color(red: 45 / 255, green: 212 / 255, blue: 191 / 255)
  static let mainStyleBackgroundColor = Color.blue.opacity(0.6)
  
  static let yellowBackgroundColor = Color(red: 254 / 255, green: 243 / 255, blue: 199 / 255)
  static let greenBackgroundColor = Color(red: 199 / 255, green: 243 / 255, blue: 208 / 255)
  static let grayBackgroundColor = Color(.systemGray5).opacity(0.5)
  
  static let grayTextColor = Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255)
  
  static let buttonUnavailableBackgroundColor = Color(Color(red: 248 / 255, green: 250 / 255, blue: 252 / 255))
  static let buttonUnavailableTextColor = Color(red: 148 / 255, green: 163 / 255, blue: 184 / 255)
}

extension UIColor {
  static let globalStyleBackgroundColor = UIColor(red: 240 / 255, green: 249 / 255, blue: 255 / 255, alpha: 1.0)
  
  static let mainStyleBackgroundColor = UIColor(Color.mainStyleBackgroundColor)
}
