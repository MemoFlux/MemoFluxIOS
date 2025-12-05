//
//  IntentListView.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/9/28.
//

import SwiftData
import SwiftUI

enum IntentViewMode { case list, calendar }

struct IntentListView: View {
  @ObservedObject private var languageManager = LanguageManager.shared
  @State private var viewMode: IntentViewMode = .calendar
  @State private var selectedDate = Date()
  @State private var months: [Date] = []
  @State private var showDayIntentPanel = false
  @Query(sort: \MemoItemModel.createdAt, order: .reverse) private var memoItems: [MemoItemModel]

  private let calendar = Calendar.current
  private var monthFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = LanguageManager.shared.currentLanguage == .chinese ? "yyyy年M月" : "MMMM yyyy"
    formatter.locale = Locale(identifier: LanguageManager.shared.currentLanguage == .chinese ? "zh_CN" : "en_US")
    return formatter
  }

  var body: some View {
    NavigationView {
      Group {
        if viewMode == .calendar {
          calendarContent
        } else {
          listContent
        }
      }
      .navigationTitle(viewMode == .calendar ? AppStrings.calendarView : AppStrings.intentList)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem {
          Picker(AppStrings.viewMode, selection: $viewMode) {
            Image(systemName: "list.bullet").tag(IntentViewMode.list)
            Image(systemName:  "calendar").tag(IntentViewMode.calendar)
          }
        }
      }
    }
  }

  private var calendarContent: some View {
    ScrollViewReader { proxy in
      ScrollView {
        LazyVStack(spacing: 0) {
          ForEach(months, id: \.self) { month in
            MonthView(
              month: month,
              selectedDate: $selectedDate,
              calendar: calendar,
              onDayTapped: { date in
                handleDayTap(date)
              }
            )
            .id(month)
          }
        }
      }
      .onAppear {
        generateMonths()
        scrollToCurrentMonth(proxy: proxy)
      }
    }
    .safeAreaInset(edge: .bottom) {
      if showDayIntentPanel {
        DayIntentPanel(
          date: selectedDate,
          intents: dayIntents(for: selectedDate)
        )
      }
    }
  }

  private var listContent: some View {
    List {
      ForEach(groupedIntents, id: \.0) { section in
        Section(header: Text(section.0)) {
          ForEach(section.1) { intent in
            NavigationLink(destination: ListCellDetailView(item: intent.memoItem)) {
              TodayScheduleIntentRowView(intent: intent)
            }
            .buttonStyle(PlainButtonStyle())
          }
        }
      }
    }
    .listStyle(PlainListStyle())
  }

  private func handleDayTap(_ date: Date) {
    if calendar.isDate(date, inSameDayAs: selectedDate) && showDayIntentPanel {
      withAnimation(.easeInOut(duration: 0.25)) {
        showDayIntentPanel = false
      }
    } else {
      selectedDate = date
      withAnimation(.easeInOut(duration: 0.25)) {
        showDayIntentPanel = true
      }
    }
  }

  private func generateMonths() {
    let currentDate = Date()
    let currentYear = calendar.component(.year, from: currentDate)
    var monthsArray: [Date] = []

    // 从2000年1月到当前年份+100年12月
    let startYear = 2000
    let endYear = currentYear + 100

    for year in startYear...endYear {
      for month in 1...12 {
        if let date = calendar.date(from: DateComponents(year: year, month: month, day: 1)) {
          monthsArray.append(date)
        }
      }
    }

    months = monthsArray
  }

  private func scrollToCurrentMonth(proxy: ScrollViewProxy) {
    let currentDate = Date()
    let currentYear = calendar.component(.year, from: currentDate)
    let currentMonth = calendar.component(.month, from: currentDate)

    if let targetMonth = calendar.date(
      from: DateComponents(year: currentYear, month: currentMonth, day: 1))
    {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        withAnimation(.easeInOut(duration: 0.5)) {
          proxy.scrollTo(targetMonth)
        }
      }
    }
  }

  private func dayIntents(for date: Date) -> [IntentDiscoveryViewModel] {
    var intents: [IntentDiscoveryViewModel] = []
    let cal = calendar
    for memo in memoItems {
      guard let apiResponse = memo.apiResponse else { continue }
      for task in apiResponse.schedule.tasks {
        let taskDate = task.startDate ?? memo.createdAt
        if cal.isDate(taskDate, inSameDayAs: date) {
          intents.append(IntentDiscoveryViewModel(memoItem: memo, scheduleTask: task))
        }
      }
    }
    return intents.sorted { a, b in
      let ad = a.scheduleTask.startDate ?? a.memoItem.createdAt
      let bd = b.scheduleTask.startDate ?? b.memoItem.createdAt
      return ad < bd
    }
  }

  private var groupedIntents: [(String, [IntentDiscoveryViewModel])] {
    var groups: [String: [IntentDiscoveryViewModel]] = [:]
    let formatter = DateFormatter()
    formatter.dateFormat = LanguageManager.shared.currentLanguage == .chinese ? "yyyy年M月d日" : "MMMM d, yyyy"
    for memo in memoItems {
      guard let apiResponse = memo.apiResponse else { continue }
      for task in apiResponse.schedule.tasks {
        let date = task.startDate ?? memo.createdAt
        let key: String
        if calendar.isDateInToday(date) {
          key = AppStrings.today
        } else if calendar.isDateInYesterday(date) {
          key = AppStrings.yesterday
        } else {
          key = formatter.string(from: date)
        }
        let intent = IntentDiscoveryViewModel(memoItem: memo, scheduleTask: task)
        groups[key, default: []].append(intent)
      }
    }
    let sorted = groups.sorted { lhs, rhs in
      if lhs.key == AppStrings.today { return true }
      if rhs.key == AppStrings.today { return false }
      if lhs.key == AppStrings.yesterday { return true }
      if rhs.key == AppStrings.yesterday { return false }
      return lhs.key > rhs.key
    }
    return sorted.map { ($0.key, $0.value) }
  }
}

// MARK: - 月份视图组件
struct MonthView: View {
  let month: Date
  @Binding var selectedDate: Date
  let calendar: Calendar
  let onDayTapped: (Date) -> Void
  @ObservedObject private var languageManager = LanguageManager.shared

  private var monthFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = LanguageManager.shared.currentLanguage == .chinese ? "yyyy年M月" : "MMMM yyyy"
    formatter.locale = Locale(identifier: LanguageManager.shared.currentLanguage == .chinese ? "zh_CN" : "en_US")
    return formatter
  }

  var body: some View {
    VStack(spacing: 0) {
      // 月份标题
      HStack {
        Text(monthFormatter.string(from: month))
          .font(.title3)
          .fontWeight(.semibold)
          .foregroundColor(.primary)
        Spacer()
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)

      // 星期标题
      HStack(spacing: 0) {
        ForEach(weekdaySymbols, id: \.self) { weekday in
          Text(weekday)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
        }
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 4)

      // 日历网格
      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 2) {
        ForEach(daysInMonth, id: \.self) { date in
          if let date = date {
            DayCell(
              date: date,
              isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
              isToday: calendar.isDateInToday(date),
              isCurrentMonth: calendar.isDate(date, equalTo: month, toGranularity: .month)
            ) {
              onDayTapped(date)
            }
          } else {
            Color.clear
              .frame(height: 36)
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 16)
    }
  }

  // MARK: - 计算属性
  private var weekdaySymbols: [String] {
    let symbols = calendar.shortWeekdaySymbols
    // 重新排列，让周一作为第一天
    return Array(symbols[1...]) + [symbols[0]]
  }

  private var daysInMonth: [Date?] {
    guard let monthInterval = calendar.dateInterval(of: .month, for: month),
      let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
      let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end - 1)
    else {
      return []
    }

    let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)

    return calendar.generateDates(
      inside: dateInterval,
      matching: DateComponents(hour: 0, minute: 0, second: 0)
    )
  }
}

// MARK: - 日期单元格
struct DayCell: View {
  let date: Date
  let isSelected: Bool
  let isToday: Bool
  let isCurrentMonth: Bool
  let action: () -> Void

  private let dayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter
  }()

  var body: some View {
    Button(action: action) {
      Text(dayFormatter.string(from: date))
        .font(.system(size: 15, weight: isToday ? .semibold : .regular))
        .foregroundColor(textColor)
        .frame(width: 36, height: 36)
        .background(backgroundColor)
        .clipShape(Circle())
        .overlay(
          Circle()
            .stroke(isToday ? Color.blue : Color.clear, lineWidth: 1)
        )
    }
    .buttonStyle(PlainButtonStyle())
  }

  private var textColor: Color {
    if isSelected {
      return .white
    } else if isToday {
      return .blue
    } else if isCurrentMonth {
      return .primary
    } else {
      return .secondary
    }
  }

  private var backgroundColor: Color {
    if isSelected {
      return .blue
    } else {
      return .clear
    }
  }
}

// MARK: - Calendar Extension
extension Calendar {
  func generateDates(
    inside interval: DateInterval,
    matching components: DateComponents
  ) -> [Date?] {
    var dates: [Date?] = []

    enumerateDates(
      startingAfter: interval.start,
      matching: components,
      matchingPolicy: .nextTime
    ) { date, _, stop in
      if let date = date {
        if date < interval.end {
          dates.append(date)
        } else {
          stop = true
        }
      }
    }

    // 确保有42个位置（6周 x 7天）
    let totalCells = 42
    let currentCount = dates.count

    if currentCount < totalCells {
      dates.append(contentsOf: Array(repeating: nil, count: totalCells - currentCount))
    }

    return dates
  }
}

#Preview {
  IntentListView()
}

// MARK: - 底部当日意图面板
struct DayIntentPanel: View {
  @ObservedObject private var languageManager = LanguageManager.shared
  let date: Date
  let intents: [IntentDiscoveryViewModel]

  private var headerText: String {
    let formatter = DateFormatter()
    formatter.dateFormat = LanguageManager.shared.currentLanguage == .chinese ? "yyyy年M月d日" : "MMMM d, yyyy"
    
    let countSuffix = " (\(intents.count))"
    
    if Calendar.current.isDateInToday(date) { 
      return AppStrings.todaysIntents + countSuffix
    }
    if Calendar.current.isDateInYesterday(date) { 
      return AppStrings.yesterdaysIntents + countSuffix
    }
    return AppStrings.intentsFor(formatter.string(from: date)) + countSuffix
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text(headerText)
          .font(.system(size: 14, weight: .medium))
        Spacer()
        Image(systemName: "chevron.down")
          .font(.system(size: 12))
          .foregroundColor(.secondary)
      }

      ScrollView(.vertical, showsIndicators: false) {
        LazyVStack(spacing: 8) {
          ForEach(intents) { intent in
            NavigationLink(destination: ListCellDetailView(item: intent.memoItem)) {
              TodayScheduleIntentRowView(intent: intent)
            }
            .buttonStyle(PlainButtonStyle())
          }
        }
        .padding(.vertical, 1)
      }
    }
    .padding(16)
    .background(Color.white)
    .cornerRadius(16)
    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    .frame(maxHeight: 360)
  }
}
