//
//  KeyboardToolbarFactory.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/26.
//

import Foundation
import UIKit

/// 键盘工具栏 Factory
struct KeyboardToolbarFactory {
  static func createToolbar(coordinator: TextInputCoordinator) -> UIToolbar {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    let pasteButton = createPasteButton(coordinator: coordinator)
    let doneButton = createDoneButton(coordinator: coordinator)
    let flexSpace = UIBarButtonItem(
      barButtonSystemItem: .flexibleSpace,
      target: nil,
      action: nil
    )
    
    toolbar.items = [pasteButton, flexSpace, doneButton]
    return toolbar
  }
  
  private static func createPasteButton(coordinator: TextInputCoordinator) -> UIBarButtonItem {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.spacing = 4
    
    let imageView = UIImageView(image: UIImage(systemName: "doc.on.clipboard"))
    imageView.tintColor = UIColor.mainStyleBackgroundColor
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
    imageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
    
    let label = UILabel()
    label.text = "粘贴自剪切板"
    label.textColor = UIColor.mainStyleBackgroundColor
    label.font = UIFont.systemFont(ofSize: 14)
    
    stackView.addArrangedSubview(imageView)
    stackView.addArrangedSubview(label)
    
    let tapGesture = UITapGestureRecognizer(
      target: coordinator,
      action: #selector(TextInputCoordinator.pasteButtonTapped)
    )
    stackView.addGestureRecognizer(tapGesture)
    stackView.isUserInteractionEnabled = true
    
    return UIBarButtonItem(customView: stackView)
  }
  
  private static func createDoneButton(coordinator: TextInputCoordinator) -> UIBarButtonItem {
    let button = UIBarButtonItem(
      title: "完成",
      style: .done,
      target: coordinator,
      action: #selector(TextInputCoordinator.doneButtonTapped)
    )
    button.tintColor = UIColor.mainStyleBackgroundColor
    return button
  }
}
