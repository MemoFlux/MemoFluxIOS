//
//  IntentDetectView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/25.
//

import SwiftUI

struct IntentDetectView: View {
  let apiResponse: APIResponse?
  let isLoading: Bool

  // 提醒事项确认视图 state
  @State private var showingReminderConfirmation = false

  init(apiResponse: APIResponse? = nil, isLoading: Bool = false) {
    self.apiResponse = apiResponse
    self.isLoading = isLoading
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text(AppStrings.intentRecognition)
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(.black)
        Spacer()
      }
      .padding(.bottom, 8)
      .padding(.leading, 5)

      VStack(alignment: .leading, spacing: 0) {
        if isLoading {
          HStack(alignment: .center, spacing: 8) {
            ProgressView()
              .scaleEffect(0.8)

            Text(AppStrings.detectingIntents)
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(.black)

            Spacer()
          }
          .padding(.bottom, 12)

        } else if let response = apiResponse, !response.schedule.tasks.isEmpty {
          HStack(alignment: .center, spacing: 8) {
            Image(systemName: "brain.head.profile")
              .font(.system(size: 14))
              .foregroundColor(.green)

            Text(AppStrings.scheduleDetected)
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(.black)

            Spacer()
          }
          .padding(.bottom, 12)

          if let firstTask = response.schedule.tasks.first {
            VStack(alignment: .leading, spacing: 8) {
              Text(AppStrings.schedulePrefix(firstTask.theme))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)

              if let startDate = firstTask.startDate {
                Text(AppStrings.timePrefix(startDate.formatted(date: .abbreviated, time: .shortened)))
                  .font(.system(size: 12))
                  .foregroundColor(.secondary)
              }

              if !firstTask.coreTasks.isEmpty {
                Text(AppStrings.taskPrefix(firstTask.coreTasks.joined(separator: "、")))
                  .font(.system(size: 12))
                  .foregroundColor(.secondary)
                  .lineLimit(2)
              }
            }
            .padding(.bottom, 12)
          }

          // MARK: - 操作按钮 激活状态
          if let firstTask = response.schedule.tasks.first {
            ScheduleTaskHelper.actionButtons(
              for: firstTask,
              showingReminderConfirmation: $showingReminderConfirmation
            )
          }
        } else {
          HStack(alignment: .center, spacing: 8) {
            Image(systemName: "brain.head.profile")
              .font(.system(size: 14))
              .foregroundColor(.orange)

            Text(apiResponse != nil ? AppStrings.noScheduleDetected : AppStrings.waitingForIntentDetection)
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(.black)

            Spacer()
          }
          .padding(.bottom, 12)

          // MARK: - 描述文本
          Text(AppStrings.intentDetectionDesc)
            .font(.system(size: 12))
            .foregroundColor(.grayTextColor)
            .lineLimit(nil)
            .padding(.bottom, 12)

          // MARK: - 操作按钮 未激活状态
          HStack(spacing: 8) {
            HStack(spacing: 6) {
              Image(systemName: "calendar")
                .font(.system(size: 12))
                .foregroundColor(Color.buttonUnavailableTextColor)

              Text(AppStrings.addToCalendar)
                .font(.system(size: 12))
                .foregroundColor(Color.buttonUnavailableTextColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.buttonUnavailableBackgroundColor)
            .cornerRadius(12)

            HStack(spacing: 6) {
              Image(systemName: "list.bullet")
                .font(.system(size: 12))
                .foregroundColor(Color.buttonUnavailableTextColor)

              Text(AppStrings.addToReminders)
                .font(.system(size: 12))
                .foregroundColor(Color.buttonUnavailableTextColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.buttonUnavailableBackgroundColor)
            .cornerRadius(12)

            Spacer()
          }
        }
      }
      .padding(16)
      .background(Color.yellowBackgroundColor)
      .cornerRadius(16)
    }
    .sheet(isPresented: $showingReminderConfirmation) {
      if let firstTask = apiResponse?.schedule.tasks.first {
        ReminderConfirmationView(task: firstTask)
      }
    }
  }
}

#Preview {
  VStack(spacing: 20) {
    IntentDetectView()
    IntentDetectView(isLoading: true)
  }
  .padding()
}
