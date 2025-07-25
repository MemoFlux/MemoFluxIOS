//
//  AddMemoItemView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import PhotosUI
import SwiftUI
import UIKit

struct AddMemoItemView: View {
  @Environment(\.dismiss) private var dismiss

  @State private var showingImagePicker = false
  @State private var showingCamera = false
  @State private var inputTitle = ""
  @State private var inputText = ""
  @State private var useAIParsing = true  // AI解析选项，默认开启

  @State private var selectedImage: UIImage?
  @State private var selectedPhotoItem: PhotosPickerItem?

  @FocusState private var isTextEditorFocused: Bool

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 10) {
          TextEditorView(
            inputText: $inputText,
            inputTitle: $inputTitle,
            isTextEditorFocused: _isTextEditorFocused,
            useAIParsing: $useAIParsing
          )
          .padding(.bottom, 5)

          ImageActionButtonsView(
            cameraAction: { showingCamera = true },
            photoPickerAction: { showingImagePicker = true }
          )

          HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
              HStack {
                Text("* 暂时只能拍摄/选择一张照片")
                  .font(.caption)
                  .foregroundStyle(.gray)
                  .frame(maxWidth: .infinity, alignment: .leading)

                NavigationLink(destination: AddShortcutView()) {
                  HStack(spacing: 0) {
                    Text("推荐使用快捷指令！")
                    Image(systemName: "chevron.right.circle")
                  }
                }
                .font(.caption)
                .padding(.trailing, 5)
              }

              if let image = selectedImage {
                withAnimation {
                  Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .cornerRadius(15)
                    .contextMenu {
                      Button(
                        role: .destructive,
                        action: {
                          withAnimation {
                            selectedImage = nil
                            selectedPhotoItem = nil
                          }
                        }
                      ) {
                        Label("删除照片", systemImage: "trash")
                      }
                    }
                }
              }
            }
            .padding(.leading, 5)
          }
          .padding(.horizontal, 6)

          if useAIParsing {
            WithAIParsingView()
          } else {
            WithoutAIParsingView()
          }

          // 保证内容不被键盘遮挡
          Spacer(minLength: 100)
        }
        .padding()
        .padding(.horizontal, 5)
      }
      .ignoresSafeArea(.keyboard)
      .navigationTitle("创建Memo")
      .fullScreenCover(isPresented: $showingCamera) {  // 相机调用
        CameraView(image: $selectedImage, isShown: $showingCamera)
          .ignoresSafeArea()
      }
      .photosPicker(  // 相册调用
        isPresented: $showingImagePicker,
        selection: $selectedPhotoItem,
        matching: .images,
        photoLibrary: .shared()
      )
      .onChange(of: selectedPhotoItem) { newItem in
        Task {
          if let data = try? await newItem?.loadTransferable(type: Data.self),
            let uiImage = UIImage(data: data)
          {
            withAnimation {
              selectedImage = uiImage
            }
          }
        }
      }
      .contentShape(Rectangle())  // 点击背景关闭键盘
      .onTapGesture {
        isTextEditorFocused = false
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("取消") {
            dismiss()
          }
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    AddMemoItemView()
  }
}
