//
//  ImageActionButtonsView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftUI

struct ImageActionButtonsView: View {
  var cameraAction: () -> Void
  var photoPickerAction: () -> Void
  
  var body: some View {
    VStack(spacing: 10) {
      HStack(spacing: 10) {
        Button(action: cameraAction) {
          HStack {
            Image(systemName: "camera")
            Text("拍照")
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
        }
        .foregroundStyle(.white)
        .background(Color.mainStyleBackgroundColor)
        .cornerRadius(15)
        
        Button(action: photoPickerAction) {
          HStack {
            Image(systemName: "photo")
            Text("从相册选择")
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
        }
        .foregroundStyle(.white)
        .background(Color.mainStyleBackgroundColor)
        .cornerRadius(15)
      }
    }
  }
}

#Preview {
  ImageActionButtonsView(
    cameraAction: {},
    photoPickerAction: {}
  )
}
