//
//  EventManager.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import EventKit
import EventKitUI
import Foundation
import SwiftUI
import UIKit

/// 管理 EventKit 相关的工具类
class EventManager {
  static let shared = EventManager()
  private let eventStore = EKEventStore()
  
  private init() {}
  
  // MARK: - 权限请求
  func requestCalendarAccess(completion: @escaping (Bool, Error?) -> Void) {
    eventStore.requestAccess(to: .event) { granted, error in
      DispatchQueue.main.async {
        completion(granted, error)
      }
    }
  }
  
  func requestReminderAccess(completion: @escaping (Bool, Error?) -> Void) {
    eventStore.requestAccess(to: .reminder) { granted, error in
      DispatchQueue.main.async {
        completion(granted, error)
      }
    }
  }
  
  // MARK: - 日历 Event
  func createCalendarEvent(title: String, notes: String, startDate: Date = Date()) -> EKEvent {
    let event = EKEvent(eventStore: eventStore)
    event.title = title.isEmpty ? "备忘录" : title
    event.notes = notes
    
    event.startDate = startDate
    event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate) ?? startDate
    
    event.calendar = eventStore.defaultCalendarForNewEvents
    
    return event
  }
  
  func presentCalendarEventEditor(for event: EKEvent) {
    let eventEditViewController = EKEventEditViewController()
    eventEditViewController.event = event
    eventEditViewController.eventStore = eventStore
    eventEditViewController.editViewDelegate = EventEditViewDelegate.shared
    
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootViewController = windowScene.windows.first?.rootViewController
    {
      rootViewController.present(eventEditViewController, animated: true)
    }
  }
  
  // MARK: - 提醒事项 Event
  func addReminder(
    title: String, notes: String, date: Date?, completion: @escaping (Bool, Error?) -> Void
  ) {
    requestReminderAccess { granted, error in
      if granted && error == nil {
        let reminder = EKReminder(eventStore: self.eventStore)
        reminder.title = title
        reminder.notes = notes
        
        if let dueDate = date {
          reminder.dueDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: dueDate)
        }
        
        reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
        
        do {
          try self.eventStore.save(reminder, commit: true)
          completion(true, nil)
        } catch {
          completion(false, error)
        }
      } else {
        completion(false, error)
      }
    }
  }
}

/// 日历编辑器 Delegate
class EventEditViewDelegate: NSObject, EKEventEditViewDelegate {
  static let shared = EventEditViewDelegate()
  
  private override init() {}
  
  func eventEditViewController(
    _ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction
  ) {
    controller.dismiss(animated: true)
  }
}
