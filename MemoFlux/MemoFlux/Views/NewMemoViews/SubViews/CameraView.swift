//
//  CameraView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
  @Binding var image: UIImage?
  @Binding var isShown: Bool
  
  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    
    // 相机可用性检查
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      picker.sourceType = .camera
    } else {
      // 若相机不可用，使用照片库
      picker.sourceType = .photoLibrary
    }
    
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let parent: CameraView
    
    init(_ parent: CameraView) {
      self.parent = parent
    }
    
    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      if let image = info[.originalImage] as? UIImage {
        DispatchQueue.main.async {
          withAnimation {
            self.parent.image = image
          }
        }
      }
      parent.isShown = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.isShown = false
    }
  }
}
