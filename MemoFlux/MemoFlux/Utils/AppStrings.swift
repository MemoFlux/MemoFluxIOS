//
//  AppStrings.swift
//  MemoFlux
//
//  Created by AI Assistant on 2025/12/05.
//

import Foundation

struct AppStrings {
  // MARK: - Tab Bar
  static var tabHome: String { LanguageManager.shared.localized(zh: "主页", en: "Home") }
  static var tabIntent: String { LanguageManager.shared.localized(zh: "意图", en: "Intents") }
  static var tabCategory: String { LanguageManager.shared.localized(zh: "分类", en: "Categories") }
  static var tabSettings: String { LanguageManager.shared.localized(zh: "设置", en: "Settings") }
  
  // MARK: - Settings View
  static var settingsTitle: String { LanguageManager.shared.localized(zh: "设置", en: "Settings") }
  static var language: String { LanguageManager.shared.localized(zh: "语言", en: "Language") }
  static var languageSelection: String { LanguageManager.shared.localized(zh: "选择语言", en: "Select Language") }
  
  // MARK: - Common
  static var cancel: String { LanguageManager.shared.localized(zh: "取消", en: "Cancel") }
  static var done: String { LanguageManager.shared.localized(zh: "完成", en: "Done") }
  static var create: String { LanguageManager.shared.localized(zh: "创建", en: "Create") }
  static var save: String { LanguageManager.shared.localized(zh: "保存", en: "Save") }
  static var noTitle: String { LanguageManager.shared.localized(zh: "无标题", en: "No Title") }
  static var title: String { LanguageManager.shared.localized(zh: "标题", en: "Title") }
  static var add: String { LanguageManager.shared.localized(zh: "添加", en: "Add") }
  static var edit: String { LanguageManager.shared.localized(zh: "编辑", en: "Edit") }
  static var clear: String { LanguageManager.shared.localized(zh: "清除", en: "Clear") }
  
  // MARK: - Summary View
  static var summaryTitle: String { LanguageManager.shared.localized(zh: "每日总结", en: "Daily Summary") }
  static var todayOverview: String { LanguageManager.shared.localized(zh: "今日概览", en: "Today's Overview") }
  static var newInfo: String { LanguageManager.shared.localized(zh: "新增信息", en: "New Info") }
  static var completedIntents: String { LanguageManager.shared.localized(zh: "完成意图", en: "Completed Intents") }
  static var newIntents: String { LanguageManager.shared.localized(zh: "新意图", en: "New Intents") }
  static var activityChart: String { LanguageManager.shared.localized(zh: "活动趋势图表（开发中）", en: "Activity Chart (In Dev)") }
  static var todayNewInfo: String { LanguageManager.shared.localized(zh: "今日新增信息", en: "Today's New Info") }
  static var viewAll: String { LanguageManager.shared.localized(zh: "查看全部", en: "View All") }
  static var collapse: String { LanguageManager.shared.localized(zh: "收起", en: "Collapse") }
  static var noNewInfoToday: String { LanguageManager.shared.localized(zh: "今日暂无新增信息", en: "No new info today") }
  static func remainingInfoCount(_ count: Int) -> String { LanguageManager.shared.localized(zh: "还有 \(count) 条信息", en: "\(count) more items") }
  static var intentStatus: String { LanguageManager.shared.localized(zh: "意图处理情况", en: "Intent Status") }
  static var noIntentsToday: String { LanguageManager.shared.localized(zh: "今日暂无意图", en: "No intents today") }
  static func processedIntentsCount(_ count: Int) -> String { LanguageManager.shared.localized(zh: "已处理意图 (\(count))", en: "Processed Intents (\(count))") }
  static func remainingProcessedIntentsCount(_ count: Int) -> String { LanguageManager.shared.localized(zh: "还有 \(count) 个已处理意图", en: "\(count) more processed intents") }
  static func pendingIntentsCount(_ count: Int) -> String { LanguageManager.shared.localized(zh: "未处理意图 (\(count))", en: "Pending Intents (\(count))") }
  static func remainingPendingIntentsCount(_ count: Int) -> String { LanguageManager.shared.localized(zh: "还有 \(count) 个未处理意图", en: "\(count) more pending intents") }
  static var suggestedActionsDev: String { LanguageManager.shared.localized(zh: "待处理建议行动（开发中）", en: "Suggested Actions (In Dev)") }
  static func remainingActionsCount(_ count: Int) -> String { LanguageManager.shared.localized(zh: "还有 \(count) 个建议行动", en: "\(count) more actions") }
  static var aiInsightsDev: String { LanguageManager.shared.localized(zh: "AI洞察与趋势（开发中）", en: "AI Insights (In Dev)") }
  static var personalizedInsights: String { LanguageManager.shared.localized(zh: "个性化洞察", en: "Personalized Insights") }
  static var efficiencyChart: String { LanguageManager.shared.localized(zh: "效率分析图表", en: "Efficiency Chart") }
  static var efficiencyBoost: String { LanguageManager.shared.localized(zh: "效率提升", en: "Efficiency Boost") }
  static var workHabits: String { LanguageManager.shared.localized(zh: "工作习惯", en: "Work Habits") }
  static var insightsDemoText1: String { LanguageManager.shared.localized(zh: "根据您的活动模式分析，您在上午时段（9:00-11:00）记录信息效率最高，建议安排重要思考和创意工作在此时段。", en: "Analysis shows you are most productive between 9:00-11:00 AM. Schedule important tasks then.") }
  static var insightsDemoText2: String { LanguageManager.shared.localized(zh: "您本周关注的主要主题是\"用户体验\"和\"数据分析\"，相比上周有明显提升。", en: "Your main topics this week are \"User Experience\" and \"Data Analysis\", showing an increase from last week.") }
  
  static var selectDate: String { LanguageManager.shared.localized(zh: "选择日期", en: "Select Date") }
  static var datePickerTitle: String { LanguageManager.shared.localized(zh: "选择日期", en: "Select Date") }
  
  // MARK: - Intent List View
  static var calendarView: String { LanguageManager.shared.localized(zh: "日历", en: "Calendar") }
  static var intentList: String { LanguageManager.shared.localized(zh: "意图列表", en: "Intent List") }
  static var viewMode: String { LanguageManager.shared.localized(zh: "视图", en: "View") }
  static var today: String { LanguageManager.shared.localized(zh: "今天", en: "Today") }
  static var yesterday: String { LanguageManager.shared.localized(zh: "昨天", en: "Yesterday") }
  static func intentsFor(_ date: String) -> String {
    LanguageManager.shared.localized(zh: "\(date) 的意图", en: "Intents for \(date)")
  }
  static var todaysIntents: String { LanguageManager.shared.localized(zh: "今天的意图", en: "Today's Intents") }
  static var yesterdaysIntents: String { LanguageManager.shared.localized(zh: "昨天的意图", en: "Yesterday's Intents") }
  
  // MARK: - Category View
  static var noTags: String { LanguageManager.shared.localized(zh: "暂无标签", en: "No Tags") }
  static var tagsDescription: String { LanguageManager.shared.localized(zh: "创建 Memo 时添加标签后，这里会显示所有标签", en: "Tags added when creating Memos will appear here") }
  static var tagCategories: String { LanguageManager.shared.localized(zh: "标签分类", en: "Tag Categories") }
  static var sortBy: String { LanguageManager.shared.localized(zh: "排序", en: "Sort") }
  static var sortByName: String { LanguageManager.shared.localized(zh: "名称", en: "Name") }
  static var sortByCount: String { LanguageManager.shared.localized(zh: "数量", en: "Count") }
  static var noRelatedMemos: String { LanguageManager.shared.localized(zh: "暂无相关 Memo", en: "No Related Memos") }
  static func noMemosWithTag(_ tag: String) -> String {
    LanguageManager.shared.localized(zh: "还没有包含「\(tag)」标签的 Memo", en: "No Memos with tag \"\(tag)\" yet")
  }
  static func tagTitle(_ tag: String) -> String {
    LanguageManager.shared.localized(zh: "标签 - \(tag)", en: "Tag - \(tag)")
  }
  
  // MARK: - Add Memo View
  static var onePhotoLimit: String { LanguageManager.shared.localized(zh: "* 暂时只能拍摄/选择一张照片", en: "* Only one photo can be selected/taken") }
  static var recommendShortcut: String { LanguageManager.shared.localized(zh: "推荐使用快捷指令！", en: "Recommended: Use Shortcuts!") }
  static var deletePhoto: String { LanguageManager.shared.localized(zh: "删除照片", en: "Delete Photo") }
  static var processingImage: String { LanguageManager.shared.localized(zh: "正在处理图片...", en: "Processing image...") }
  static var imageProcessed: String { LanguageManager.shared.localized(zh: "图片已处理完成", en: "Image processing complete") }
  static var createMemo: String { LanguageManager.shared.localized(zh: "创建Memo", en: "Create Memo") }
  static var parse: String { LanguageManager.shared.localized(zh: "解析", en: "Parse") }
  static var parsing: String { LanguageManager.shared.localized(zh: "解析中...", en: "Parsing...") }
  static var parseAgain: String { LanguageManager.shared.localized(zh: "再次解析", en: "Parse Again") }
  static var noContent: String { LanguageManager.shared.localized(zh: "没有内容", en: "No Content") }
  static var importPrompt: String { LanguageManager.shared.localized(zh: "请从快捷指令或其他来源导入内容。", en: "Please import content from Shortcuts or other sources.") }
  static var noSearchResults: String { LanguageManager.shared.localized(zh: "没有找到相关内容", en: "No results found") }
  static var tryOtherKeywords: String { LanguageManager.shared.localized(zh: "尝试使用其他关键词搜索", en: "Try searching with different keywords") }
  static var searchPrompt: String { LanguageManager.shared.localized(zh: "搜索Memo...", en: "Search Memo...") }
  static var delete: String { LanguageManager.shared.localized(zh: "删除", en: "Delete") }
  static var processing: String { LanguageManager.shared.localized(zh: "加载中...", en: "Loading...") }
  static var recognizingText: String { LanguageManager.shared.localized(zh: "正在识别文字...", en: "Recognizing text...") }
  static var deletedMemo: String { LanguageManager.shared.localized(zh: "成功删除 Memo", en: "Memo deleted successfully") }
  static var deleteFailed: String { LanguageManager.shared.localized(zh: "删除 Memo 失败", en: "Failed to delete Memo") }
  
  // MARK: - Intent Discovery View
  static var todayPendingIntents: String { LanguageManager.shared.localized(zh: "今日待处理意图", en: "Today's Pending Intents") }
  static var noPendingIntentsToday: String { LanguageManager.shared.localized(zh: "今日暂无未处理意图！", en: "No pending intents today!") }
  
  // MARK: - Detail View
  static var detailTitle: String { LanguageManager.shared.localized(zh: "详细信息", en: "Detail") }
  static var typeInformation: String { LanguageManager.shared.localized(zh: "信息", en: "Information") }
  static var typeSchedule: String { LanguageManager.shared.localized(zh: "日程", en: "Schedule") }
  static var createdPrefix: String { LanguageManager.shared.localized(zh: "创建时间: ", en: "Created: ") }
  static var sourcePrefix: String { LanguageManager.shared.localized(zh: "来源: ", en: "Source: ") }
  static var aiAnalyzing: String { LanguageManager.shared.localized(zh: "AI正在分析中...", en: "AI is analyzing...") }
  static var aiAnalysisCompletePrefix: String { LanguageManager.shared.localized(zh: "AI分析完成: ", en: "AI Analysis Complete: ") }
  static var originalText: String { LanguageManager.shared.localized(zh: "输入原文", en: "Original Text") }
  static var aiSummary: String { LanguageManager.shared.localized(zh: "AI 摘要", en: "AI Summary") }
  static var aiParsedContent: String { LanguageManager.shared.localized(zh: "AI 解析内容", en: "AI Parsed Content") }
  static var aiAnalyzingContent: String { LanguageManager.shared.localized(zh: "AI正在分析内容...", en: "AI Analyzing Content...") }
  static var aiAnalyzingDesc: String { LanguageManager.shared.localized(zh: "请稍候，AI正在为您分析内容并生成智能解析结果", en: "Please wait, AI is analyzing content and generating smart results.") }
  static var dataType: String { LanguageManager.shared.localized(zh: "数据类型", en: "Data Type") }
  static var localText: String { LanguageManager.shared.localized(zh: "本地文本", en: "Local Text") }
  static var noRecognizedContent: String { LanguageManager.shared.localized(zh: "暂无识别内容", en: "No recognized content") }
  static var reparseAI: String { LanguageManager.shared.localized(zh: "重新使用AI解析", en: "Reparse with AI") }
  static var noIntentRecognized: String { LanguageManager.shared.localized(zh: "当前Memo未识别出意图", en: "No intent recognized") }
  static var noIntentDesc: String { LanguageManager.shared.localized(zh: "您可以尝试添加更多详细信息，或使用AI解析功能重新分析内容", en: "Try adding more details or use AI parsing again.") }
  static var categoryPrefix: String { LanguageManager.shared.localized(zh: "分类:", en: "Category:") }
  static var showIgnoredSchedules: String { LanguageManager.shared.localized(zh: "显示已忽略日程", en: "Show ignored schedules") }
  static var noValidSchedule: String { LanguageManager.shared.localized(zh: "暂无有效日程信息", en: "No valid schedule info") }
  static var allSchedulesIgnored: String { LanguageManager.shared.localized(zh: "所有生成的日程均已忽略，可点击“显示已忽略日程”查看。", en: "All generated schedules are ignored. Click \"Show ignored schedules\" to view.") }
  static var coreTasksPrefix: String { LanguageManager.shared.localized(zh: "核心任务:", en: "Core Tasks:") }
  static var suggestedActionsPrefix: String { LanguageManager.shared.localized(zh: "建议行动:", en: "Suggested Actions:") }
  
  // MARK: - Reminder Confirmation
  static var reminderTitleInput: String { LanguageManager.shared.localized(zh: "输入提醒标题", en: "Enter reminder title") }
  static var timeSettings: String { LanguageManager.shared.localized(zh: "时间设置", en: "Time Settings") }
  static var setReminderTime: String { LanguageManager.shared.localized(zh: "设置提醒时间", en: "Set reminder time") }
  static var reminderTime: String { LanguageManager.shared.localized(zh: "提醒时间", en: "Reminder Time") }
  static var notes: String { LanguageManager.shared.localized(zh: "备注", en: "Notes") }
  static var createReminder: String { LanguageManager.shared.localized(zh: "创建提醒事项", en: "Create Reminder") }
  static var participantsPrefix: String { LanguageManager.shared.localized(zh: "参与人员: ", en: "Participants: ") }
  static var locationPrefix: String { LanguageManager.shared.localized(zh: "地点: ", en: "Location: ") }
  static var tagsPrefix: String { LanguageManager.shared.localized(zh: "标签: ", en: "Tags: ") }
  
  // MARK: - Tag Management
  static var addFirstTag: String { LanguageManager.shared.localized(zh: "添加第一个标签", en: "Add first tag") }
  static var tagManagement: String { LanguageManager.shared.localized(zh: "标签管理", en: "Tag Management") }
  static var cleanup: String { LanguageManager.shared.localized(zh: "清理", en: "Cleanup") }
  static var addTag: String { LanguageManager.shared.localized(zh: "添加标签", en: "Add Tag") }
  static var tagName: String { LanguageManager.shared.localized(zh: "标签名称", en: "Tag Name") }
  static func usedCount(_ count: Int) -> String { LanguageManager.shared.localized(zh: "使用 \(count) 次", en: "Used \(count) times") }
  static func lastUsed(_ date: String) -> String { LanguageManager.shared.localized(zh: "最后使用: \(date)", en: "Last used: \(date)") }
  static var editTag: String { LanguageManager.shared.localized(zh: "编辑标签", en: "Edit Tag") }
  static var searchTags: String { LanguageManager.shared.localized(zh: "搜索标签", en: "Search Tags") }
}
