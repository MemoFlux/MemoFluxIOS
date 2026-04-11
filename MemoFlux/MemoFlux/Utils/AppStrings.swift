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
  static var byTag: String { LanguageManager.shared.localized(zh: "按标签", en: "By Tag") }
  static var byTopic: String { LanguageManager.shared.localized(zh: "按主题", en: "By Topic") }
  static var noTopics: String { LanguageManager.shared.localized(zh: "暂无主题", en: "No Topics") }
  static var topicsDescription: String { LanguageManager.shared.localized(zh: "AI 解析出的主题将显示在这里", en: "Topics parsed by AI will appear here") }
  static func topicTitle(_ topic: String) -> String {
    LanguageManager.shared.localized(zh: "主题 - \(topic)", en: "Topic - \(topic)")
  }
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
  static var inputTitlePrompt: String { LanguageManager.shared.localized(zh: "输入标题", en: "Enter Title") }
  static var inputTextPlaceholder: String { LanguageManager.shared.localized(zh: "在这里输入文字或点击下方按钮", en: "Enter text here or click buttons below") }
  static var uploadImage: String { LanguageManager.shared.localized(zh: "上传图片", en: "Upload Image") }
  static var useAIParsing: String { LanguageManager.shared.localized(zh: "使用AI解析", en: "Use AI Parsing") }
  static var modelSelection: String { LanguageManager.shared.localized(zh: "模型选择", en: "Model Selection") }
  static var currentModel: String { LanguageManager.shared.localized(zh: "当前模型", en: "Current Model") }
  static var builtInModels: String { LanguageManager.shared.localized(zh: "内置模型", en: "Built-in Models") }
  static var customModels: String { LanguageManager.shared.localized(zh: "自定义模型", en: "Custom Models") }
  static var createCustomModel: String { LanguageManager.shared.localized(zh: "创建自定义模型", en: "Create Custom Model") }
  static var customModelHint: String { LanguageManager.shared.localized(zh: "可从不同模型供应商创建自定义模型，API Key 会安全保存在本机。", en: "Create custom models from different providers. API keys are stored locally on device.") }
  static var modelBasicInfo: String { LanguageManager.shared.localized(zh: "模型信息", en: "Model Info") }
  static var modelName: String { LanguageManager.shared.localized(zh: "模型名称", en: "Model Name") }
  static var modelID: String { LanguageManager.shared.localized(zh: "模型 ID", en: "Model ID") }
  static var providerSelection: String { LanguageManager.shared.localized(zh: "模型供应商", en: "Provider") }
  static var provider: String { LanguageManager.shared.localized(zh: "供应商", en: "Provider") }
  static var connectionConfig: String { LanguageManager.shared.localized(zh: "连接配置", en: "Connection") }
  static var baseURL: String { LanguageManager.shared.localized(zh: "Base URL", en: "Base URL") }
  static var apiKey: String { LanguageManager.shared.localized(zh: "API Key", en: "API Key") }
  static var providerInterfaceHint: String { LanguageManager.shared.localized(zh: "当前支持 OpenAI 兼容的 Chat Completions 接口，不同供应商会自动适配默认 Base URL。", en: "Currently supports OpenAI-compatible Chat Completions. Different providers automatically adapt their default base URLs.") }
  static var takePhoto: String { LanguageManager.shared.localized(zh: "拍照", en: "Take Photo") }
  static var chooseFromAlbum: String { LanguageManager.shared.localized(zh: "从相册选择", en: "Choose from Album") }
  static var smartAnalysisResults: String { LanguageManager.shared.localized(zh: "智能解析结果", en: "Smart Analysis Results") }
  static var analysisComplete: String { LanguageManager.shared.localized(zh: "AI分析完成", en: "AI Analysis Complete") }
  static var analysisFinishedDesc: String { LanguageManager.shared.localized(zh: "AI分析已完成", en: "AI Analysis Finished") }
  static var analysisFinishedWithDetail: String { LanguageManager.shared.localized(zh: "AI分析已完成，可查看详细解析结果", en: "AI Analysis finished, check details below") }
  static var viewDetailedResults: String { LanguageManager.shared.localized(zh: "可查看详细解析结果", en: "Detailed results available") }
  static var scheduleDetected: String { LanguageManager.shared.localized(zh: "检测到日程安排", en: "Schedule Detected") }
  static var schedule: String { LanguageManager.shared.localized(zh: "日程", en: "Schedule") }
  static func schedulePrefix(_ theme: String) -> String { LanguageManager.shared.localized(zh: "日程：\(theme)", en: "Schedule: \(theme)") }
  static var time: String { LanguageManager.shared.localized(zh: "时间", en: "Time") }
  static func timePrefix(_ time: String) -> String { LanguageManager.shared.localized(zh: "时间：\(time)", en: "Time: \(time)") }
  static var task: String { LanguageManager.shared.localized(zh: "任务", en: "Task") }
  static func taskPrefix(_ tasks: String) -> String { LanguageManager.shared.localized(zh: "任务：\(tasks)", en: "Tasks: \(tasks)") }
  static var intentRecognition: String { LanguageManager.shared.localized(zh: "意图识别", en: "Intent Recognition") }
  static var addToCalendar: String { LanguageManager.shared.localized(zh: "添加到日历", en: "Add to Calendar") }
  static var addToReminders: String { LanguageManager.shared.localized(zh: "添加到提醒事项", en: "Add to Reminders") }
  static var aiSuggestedTags: String { LanguageManager.shared.localized(zh: "AI建议标签", en: "AI Suggested Tags") }
  static var addCustom: String { LanguageManager.shared.localized(zh: "添加自定义", en: "Add Custom") }
  static var addTags: String { LanguageManager.shared.localized(zh: "添加标签", en: "Add Tags") }
  static var aiSuggestedTagsTitle: String { LanguageManager.shared.localized(zh: "AI 建议标签", en: "AI Suggested Tags") }
  static var localTags: String { LanguageManager.shared.localized(zh: "本地标签", en: "Local Tags") }
  
  static func aiAnalysisSummaryPrefix(_ summary: String) -> String {
    LanguageManager.shared.localized(zh: "AI 分析：\(summary)", en: "AI Analysis: \(summary)")
  }
  static var aiAnalysisFinishedPrefix: String { LanguageManager.shared.localized(zh: "AI 分析：已完成内容分析", en: "AI Analysis: Content analysis complete") }
  static var waitingForAnalysis: String { LanguageManager.shared.localized(zh: "等待解析信息", en: "Waiting for analysis") }
  static var aiAnalysisNoContent: String { LanguageManager.shared.localized(zh: "AI 分析：未识别到有效内容，请输入或上传信息", en: "AI Analysis: No content identified, please enter or upload info") }
  static var addMoreForBetterResults: String { LanguageManager.shared.localized(zh: "添加更多内容可获得更精准的解析结果", en: "Add more content for better analysis results") }
  static var detectingIntents: String { LanguageManager.shared.localized(zh: "正在检测意图...", en: "Detecting intents...") }
  static var noScheduleDetected: String { LanguageManager.shared.localized(zh: "未检测到日程安排", en: "No schedule detected") }
  static var waitingForIntentDetection: String { LanguageManager.shared.localized(zh: "等待检测意图", en: "Waiting for intent detection") }
  static var intentDetectionDesc: String { LanguageManager.shared.localized(zh: "当AI检测到日程安排、任务提醒等意图时，会在这里提供快捷操作选项。", en: "Quick actions will appear here when AI detects schedules or tasks.") }
  static var noLocalTags: String { LanguageManager.shared.localized(zh: "暂无本地标签", en: "No local tags") }
  static var inputTagNamePrompt: String { LanguageManager.shared.localized(zh: "请输入新标签的名称", en: "Please enter a name for the new tag") }
  static var confirm: String { LanguageManager.shared.localized(zh: "确认", en: "Confirm") }
  
  static var onePhotoLimit: String { LanguageManager.shared.localized(zh: "* 暂时只能拍摄/选择一张照片", en: "* Only one photo can be selected/taken") }
  static var recommendShortcut: String { LanguageManager.shared.localized(zh: "推荐使用快捷指令！", en: "Recommended: Use Shortcuts!") }
  static var deletePhoto: String { LanguageManager.shared.localized(zh: "删除照片", en: "Delete Photo") }
  static var processingImage: String { LanguageManager.shared.localized(zh: "正在处理图片...", en: "Processing image...") }
  static var imageProcessed: String { LanguageManager.shared.localized(zh: "图片已处理完成", en: "Image processing complete") }
  static var createMemo: String { LanguageManager.shared.localized(zh: "创建 Memo", en: "Create Memo") }
  static var creating: String { LanguageManager.shared.localized(zh: "创建中...", en: "Creating...") }
  static var translating: String { LanguageManager.shared.localized(zh: "正在翻译...", en: "Translating...") }
  static var parse: String { LanguageManager.shared.localized(zh: "解析", en: "Parse") }
  static var parsing: String { LanguageManager.shared.localized(zh: "解析中...", en: "Parsing...") }
  static var parseAgain: String { LanguageManager.shared.localized(zh: "再次解析", en: "Parse Again") }
  static var noContent: String { LanguageManager.shared.localized(zh: "没有内容", en: "No Content") }
  static var importPrompt: String { LanguageManager.shared.localized(zh: "请从快捷指令或其他来源导入内容。", en: "Please import content from Shortcuts or other sources.") }
  static var noSearchResults: String { LanguageManager.shared.localized(zh: "没有找到相关内容", en: "No results found") }
  static var tryOtherKeywords: String { LanguageManager.shared.localized(zh: "尝试使用其他关键词搜索", en: "Try searching with different keywords") }
  static var searchPrompt: String { LanguageManager.shared.localized(zh: "搜索Memo...", en: "Search Memo...") }
  static var delete: String { LanguageManager.shared.localized(zh: "删除", en: "Delete") }
  static var manualCreation: String { LanguageManager.shared.localized(zh: "手动创建", en: "Manual Creation") }
  static var processing: String { LanguageManager.shared.localized(zh: "加载中...", en: "Loading...") }
  static var recognizingText: String { LanguageManager.shared.localized(zh: "正在识别文字...", en: "Recognizing text...") }
  static var deletedMemo: String { LanguageManager.shared.localized(zh: "成功删除 Memo", en: "Memo deleted successfully") }
  static var deleteFailed: String { LanguageManager.shared.localized(zh: "删除 Memo 失败", en: "Failed to delete Memo") }
  
  // MARK: - Shortcut View
  static var shortcutTitle: String { LanguageManager.shared.localized(zh: "MemoFlux 快捷指令", en: "MemoFlux Shortcuts") }
  static var fastCapture: String { LanguageManager.shared.localized(zh: "快速捕捉", en: "Fast Capture") }
  static var fastCaptureDesc: String { LanguageManager.shared.localized(zh: "随时随地一键启动，快速捕捉灵感和信息", en: "One-tap start anywhere to capture inspiration.") }
  static var directImport: String { LanguageManager.shared.localized(zh: "直接导入", en: "Direct Import") }
  static var directImportDesc: String { LanguageManager.shared.localized(zh: "拍照或选择图片后自动导入到 MemoFlux 应用", en: "Import photos directly into MemoFlux.") }
  static var smartRecognition: String { LanguageManager.shared.localized(zh: "智能识别", en: "Smart Recognition") }
  static var smartRecognitionDesc: String { LanguageManager.shared.localized(zh: "自动识别图片中的文字，无需手动输入", en: "Automatically recognize text in images.") }
  static var aiAnalysisFeature: String { LanguageManager.shared.localized(zh: "AI 分析", en: "AI Analysis") }
  static var aiAnalysisFeatureDesc: String { LanguageManager.shared.localized(zh: "使用 AI 自动分析内容，提取关键信息", en: "Use AI to analyze content and extract info.") }
  static var installSteps: String { LanguageManager.shared.localized(zh: "安装步骤", en: "Installation Steps") }
  static var clickBelow: String { LanguageManager.shared.localized(zh: "点击下方按钮", en: "Click the button below") }
  static var jumpToShortcuts: String { LanguageManager.shared.localized(zh: "将跳转到快捷指令应用", en: "Will jump to the Shortcuts app") }
  static var addShortcutAction: String { LanguageManager.shared.localized(zh: "添加快捷指令", en: "Add Shortcut") }
  static var inShortcutsApp: String { LanguageManager.shared.localized(zh: "在快捷指令应用中点击\"添加快捷指令\"", en: "Tap \"Add Shortcut\" in the app.") }
  static var installShortcutButton: String { LanguageManager.shared.localized(zh: "安装快捷指令", en: "Install Shortcut") }
  static var actionButtonHint: String { LanguageManager.shared.localized(zh: "可添加到Action Button或通过辅助触控快速启动", en: "Add to Action Button or AssistiveTouch.") }
  static var addShortcutNavTitle: String { LanguageManager.shared.localized(zh: "添加快捷指令", en: "Add Shortcut") }
  
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
  static var addCustomTag: String { LanguageManager.shared.localized(zh: "添加自定义标签", en: "Add Custom Tag") }
  static var inputTagName: String { LanguageManager.shared.localized(zh: "输入标签名称", en: "Enter tag name") }
  
  // MARK: - Topic Management
  static var topicManagement: String { LanguageManager.shared.localized(zh: "主题管理", en: "Topic Management") }
  static var topicName: String { LanguageManager.shared.localized(zh: "主题名称", en: "Topic Name") }
  static var editTopic: String { LanguageManager.shared.localized(zh: "编辑主题", en: "Edit Topic") }
  static var searchTopics: String { LanguageManager.shared.localized(zh: "搜索主题", en: "Search Topics") }
  static var noTopicsFound: String { LanguageManager.shared.localized(zh: "未找到主题", en: "No topics found") }
  static var deleteTopic: String { LanguageManager.shared.localized(zh: "删除主题", en: "Delete Topic") }
  static var deleteTopicMessage: String { LanguageManager.shared.localized(zh: "确定要删除此主题吗？该主题下的Memo将变为无主题。", en: "Delete this topic? Memos will become uncategorized.") }
}
