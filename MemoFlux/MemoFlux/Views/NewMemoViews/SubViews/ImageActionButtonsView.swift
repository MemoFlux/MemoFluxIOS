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
          HStack(spacing: 6) {
            Image(systemName: "camera")
            Text(AppStrings.takePhoto)
              .lineLimit(1)
              .minimumScaleFactor(0.5)
          }
          .frame(maxWidth: .infinity)
          .frame(height: 56)
        }
        .foregroundStyle(.white)
        .background(Color.mainStyleBackgroundColor)
        .cornerRadius(15)
        
        Button(action: photoPickerAction) {
          HStack(spacing: 6) {
            Image(systemName: "photo")
            Text(AppStrings.chooseFromAlbum)
              .lineLimit(1)
              .minimumScaleFactor(0.5)
          }
          .frame(maxWidth: .infinity)
          .frame(height: 56)
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
