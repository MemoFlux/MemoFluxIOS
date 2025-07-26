//
//  TagsSelectView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/25.
//

import SwiftData
import SwiftUI

struct TagsSelectView: View {
  @Binding var selectedTags: Set<String>
  let useAIParsing: Bool
  let apiResponse: APIResponse?

  // 从SwiftData查询所有MemoItemModel
  @Query private var memoItems: [MemoItemModel]

  // 获取SwiftData的ModelContext用于保存数据
  @Environment(\.modelContext) private var modelContext

  // 添加自定义标签的状态
  @State private var showingAddTagAlert = false
  @State private var newTagName = ""

  // 计算AI建议的标签
  private var aiSuggestedTags: [String] {
    guard let response = apiResponse else { return [] }

    var allAITags = Set<String>()

    // 从knowledge获取标签
    allAITags.formUnion(response.knowledge.tags)

    // 从information获取标签
    allAITags.formUnion(response.information.tags)

    // 从schedule获取标签
    for task in response.schedule.tasks {
      allAITags.formUnion(task.tags)
    }

    return Array(allAITags).sorted()
  }

  // 从SwiftData中获取所有本地标签
  private var localTags: [String] {
    var allTags = Set<String>()
    for item in memoItems {
      allTags.formUnion(item.tags)
    }
    return Array(allTags).sorted()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // 标题和添加自定义按钮
      HStack {
        Text("添加标签")
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.black)

        Spacer()

        Button("添加自定义") {
          showingAddTagAlert = true
        }
        .font(.system(size: 12))
        .foregroundColor(.mainStyleBackgroundColor)
      }
      .padding(.bottom, 8)
      .padding(.horizontal, 5)

      // 卡片容器
      VStack(alignment: .leading, spacing: 0) {

        // AI建议标签部分（仅在使用AI解析且有建议标签时显示）
        if useAIParsing && !aiSuggestedTags.isEmpty {
          VStack(alignment: .leading, spacing: 12) {
            // AI建议标签标题
            HStack(spacing: 6) {
              Image(systemName: "sparkles")
                .font(.system(size: 12))
                .foregroundColor(.blue)

              Text("AI 建议标签")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.blue)
            }

            // AI建议标签芯片 - 使用与普通标签相同的样式
            LazyVGrid(
              columns: [
                GridItem(.adaptive(minimum: 60, maximum: .infinity), spacing: 8)
              ], spacing: 10
            ) {
              ForEach(aiSuggestedTags, id: \.self) { tag in
                TagChipView(
                  tag: tag,
                  isSelected: selectedTags.contains(tag)
                ) {
                  toggleTag(tag)
                }
              }
            }
          }
          .padding(.bottom, 16)

          // 分隔线
          Divider()
            .background(Color.gray.opacity(0.3))
            .padding(.bottom, 16)
        }

        // 本地标签部分
        VStack(alignment: .leading, spacing: 12) {
          if useAIParsing && !aiSuggestedTags.isEmpty {
            // 如果有AI建议标签，显示"本地标签"标题
            Text("本地标签")
              .font(.system(size: 12, weight: .medium))
              .foregroundColor(.secondary)
          }

          // 本地标签内容
          if localTags.isEmpty {
            // 没有本地标签时显示提示文字
            Text("暂无本地标签")
              .font(.system(size: 14))
              .foregroundColor(.secondary)
              .frame(maxWidth: .infinity, alignment: .center)
              .padding(.vertical, 20)
          } else {
            // 本地标签芯片布局
            LazyVGrid(
              columns: [
                GridItem(.adaptive(minimum: 60, maximum: .infinity), spacing: 8)
              ], spacing: 10
            ) {
              ForEach(localTags, id: \.self) { tag in
                TagChipView(
                  tag: tag,
                  isSelected: selectedTags.contains(tag)
                ) {
                  toggleTag(tag)
                }
              }
            }
          }
        }
      }
      .padding(16)
      .background(Color.grayBackgroundColor)
      .cornerRadius(16)
    }
    .onAppear {
      // 当有AI建议标签时，自动选中它们
      if useAIParsing && !aiSuggestedTags.isEmpty {
        for tag in aiSuggestedTags {
          selectedTags.insert(tag)
        }
      }
    }
    .onChange(of: apiResponse) { newResponse in
      // 当API响应更新时，自动选中新的AI建议标签
      if useAIParsing, newResponse != nil {
        for tag in aiSuggestedTags {
          selectedTags.insert(tag)
        }
      }
    }
    .alert("添加自定义标签", isPresented: $showingAddTagAlert) {
      TextField("输入标签名称", text: $newTagName)
        .textInputAutocapitalization(.never)

      Button("取消", role: .cancel) {
        newTagName = ""
      }

      Button("确认") {
        addCustomTag()
      }
      .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    } message: {
      Text("请输入新标签的名称")
    }
  }

  private func toggleTag(_ tag: String) {
    if selectedTags.contains(tag) {
      selectedTags.remove(tag)
    } else {
      selectedTags.insert(tag)
    }
  }

  private func addCustomTag() {
    let trimmedTagName = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)

    // 检查标签名称是否为空
    guard !trimmedTagName.isEmpty else {
      newTagName = ""
      return
    }

    // 检查标签是否已存在
    guard !localTags.contains(trimmedTagName) && !aiSuggestedTags.contains(trimmedTagName) else {
      newTagName = ""
      return
    }

    // 创建一个临时的MemoItem来保存新标签
    // 这样可以确保标签被保存到SwiftData中，并在下次查询时显示
    let tempMemo = MemoItemModel(
      imageData: Data(),
      recognizedText: "",
      title: "临时标签存储",
      tags: [trimmedTagName],
      source: "custom_tag"
    )

    modelContext.insert(tempMemo)

    do {
      try modelContext.save()

      selectedTags.insert(trimmedTagName)

      newTagName = ""
    } catch {
      print("保存自定义标签失败: \(error)")
      newTagName = ""
    }
  }
}

struct TagChipView: View {
  let tag: String
  let isSelected: Bool
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 4) {
        Text(tag)
          .font(.system(size: 14))
          .foregroundColor(isSelected ? .white : .grayTextColor)
          .lineLimit(1)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .frame(minWidth: 60)  // Tag最小宽度
      .background(
        isSelected
          ? Color.mainStyleBackgroundColor
          : Color.buttonUnavailableBackgroundColor
      )
      .clipShape(.capsule)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

#Preview {
  struct PreviewWrapper: View {
    @State private var selectedTags = Set<String>()

    var body: some View {
      VStack(spacing: 20) {
        // 普通状态
        TagsSelectView(
          selectedTags: $selectedTags,
          useAIParsing: false,
          apiResponse: nil
        )

        // 带AI建议的状态
        TagsSelectView(
          selectedTags: $selectedTags,
          useAIParsing: true,
          apiResponse: createSampleAPIResponse()
        )
      }
      .padding()
      .background(Color.globalStyleBackgroundColor)
    }

    // 示例 API 相应
    private func createSampleAPIResponse() -> APIResponse {
      let knowledgeResponse = KnowledgeResponse(
        title: "示例知识",
        knowledgeItems: [
          KnowledgeItem(
            id: 1,
            header: "示例知识点",
            content: "这是一个示例知识内容",
            node: nil
          )
        ],
        relatedItems: [],
        tags: ["AI", "技术"],
        category: "技术"
      )

      let informationResponse = InformationResponse(
        title: "示例信息",
        informationItems: [
          InformationItem(
            header: "示例信息点",
            content: "这是一个示例信息内容"
          )
        ],
        postType: "笔记",
        summary: "示例摘要",
        tags: ["学习", "笔记"],
        category: "学习"
      )

      let scheduleResponse = ScheduleResponse(
        title: "示例日程",
        category: "工作",
        tasks: [
          ScheduleTask(
            startTime: "2024-05-16T09:00:00+08:00",
            endTime: "2024-05-16T17:00:00+08:00",
            people: ["张三", "李四"],
            theme: "项目会议",
            coreTasks: ["讨论项目进度", "制定下一步计划"],
            position: ["会议室A"],
            tags: ["会议", "项目"],
            category: "工作",
            suggestedActions: ["准备会议材料", "发送会议纪要"],
            id: 1
          )
        ],
        id: "sample-schedule-id",
        text: "示例日程文本"
      )

      return APIResponse(
        knowledge: knowledgeResponse,
        information: informationResponse,
        schedule: scheduleResponse,
        mostPossibleCategory: "INFORMATION"
      )
    }
  }

  return PreviewWrapper()
}
