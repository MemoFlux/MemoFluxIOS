//
//  LocalizedString.swift
//  MemoFlux
//
//  Created for localization support
//

import Foundation
import SwiftUI

extension String {
    /// 本地化字符串
    var localized: String {
        return LocalizedStringHelper.shared.localizedString(for: self)
    }
    
    /// 带参数的本地化字符串
    func localized(with arguments: CVarArg...) -> String {
        return LocalizedStringHelper.shared.localizedString(for: self, arguments: arguments)
    }
}

class LocalizedStringHelper {
    static let shared = LocalizedStringHelper()
    
    private var localizedStrings: [String: [String: String]] = [:]
    
    private init() {
        loadLocalizedStrings()
    }
    
    private func loadLocalizedStrings() {
        // 中文字符串
        let chineseStrings: [String: String] = [
            // Tab Bar
            "tab.home": "主页",
            "tab.category": "分类",
            
            // Home Page
            "home.title": "主页",
            "home.no.memos": "暂无备忘录",
            
            // Category
            "category.title": "标签分类",
            "category.no.tags": "暂无标签",
            "category.no.tags.description": "创建 Memo 时添加标签后，这里会显示所有标签",
            "category.tag.memos": "标签 - %@",
            "category.no.related.memos": "暂无相关 Memo",
            "category.no.related.memos.description": "还没有包含「%@」标签的 Memo",
            "category.no.title": "无标题",
            
            // OnBoarding
            "onboarding.welcome": "欢迎使用",
            "onboarding.subtitle": "智能备忘录助手",
            "onboarding.start.button": "开始使用 MemoFlux",
            "onboarding.feature.image.recognition.title": "智能图片识别",
            "onboarding.feature.image.recognition.content": "快捷指令或上传图片，自动识别文字内容并进行AI分析，快速创建备忘录。",
            "onboarding.feature.ai.analysis.title": "AI智能解析",
            "onboarding.feature.ai.analysis.content": "利用人工智能，自动分析内容并提取关键信息、生成标签和任务。",
            "onboarding.feature.tag.management.title": "智能标签管理",
            "onboarding.feature.tag.management.content": "自动生成相关标签，帮助您更好地组织和查找备忘录内容。",
            "onboarding.feature.schedule.extraction.title": "日程任务提取",
            "onboarding.feature.schedule.extraction.content": "从备忘录中智能提取时间和任务信息，自动生成日程安排。",
            
            // Add Memo
            "memo.add.title": "添加 Memo",
            "memo.input.title.placeholder": "输入标题",
            "memo.input.text.placeholder": "在这里输入文字\n或点击下方按钮，上传图片",
            "memo.input.button": "输入/粘贴文本内容",
            "memo.use.ai.parsing": "使用AI解析",
            "memo.create": "创建 Memo",
            "memo.creating": "创建中...",
            "memo.camera": "拍照",
            "memo.photo.library": "从相册选择",
            "memo.source.manual": "手动创建",
            "memo.source.shortcut": "快捷指令",
            
            // Tags
            "tags.add": "添加标签",
            "tags.add.custom": "添加自定义",
            "tags.ai.suggested": "AI 建议标签",
            "tags.local": "本地标签",
            "tags.no.local": "暂无本地标签",
            "tags.add.custom.alert.title": "添加自定义标签",
            "tags.add.custom.alert.placeholder": "输入标签名称",
            "tags.add.custom.alert.cancel": "取消",
            "tags.add.custom.alert.confirm": "确认",
            "tags.add.custom.alert.empty": "请输入新标签的名称",
            
            // Intent Detection
            "intent.detection.title": "意图识别",
            "intent.detection.processing": "正在检测意图...",
            "intent.detection.schedule.found": "检测到日程安排",
            "intent.detection.schedule": "日程：%@",
            "intent.detection.time": "时间：%@",
            "intent.detection.tasks": "任务：%@",
            "intent.detection.no.schedule": "未检测到日程安排",
            "intent.detection.waiting": "等待检测意图",
            "intent.detection.description": "当AI检测到日程安排、任务提醒等意图时，会在这里提供快捷操作选项。",
            "intent.detection.add.calendar": "添加到日历",
            "intent.detection.add.reminder": "添加到提醒事项",
            
            // Summary
            "summary.title": "每日总结",
            "summary.select.date": "选择日期",
            "summary.select.date.complete": "完成",
            "summary.today.overview": "今日概览",
            "summary.new.information": "新增信息",
            "summary.completed.intent": "完成意图",
            "summary.new.intent": "新意图",
            "summary.today.new.information": "今日新增信息",
            "summary.today.no.information": "今日暂无新增信息",
            "summary.more.information": "还有 %d 条信息",
            "summary.intent.processing": "意图处理情况",
            "summary.today.no.intent": "今日暂无意图",
            "summary.processed.intent": "已处理意图 (%d)",
            "summary.more.processed.intent": "还有 %d 个已处理意图",
            "summary.pending.intent": "未处理意图 (%d)",
            "summary.more.pending.intent": "还有 %d 个未处理意图",
            "summary.suggested.actions": "待处理建议行动（开发中）",
            "summary.ai.insights": "AI洞察与趋势（开发中）",
            "summary.personalized.insights": "个性化洞察",
            "summary.efficiency.analysis": "效率分析图表",
            "summary.efficiency.improvement": "效率提升",
            "summary.work.habits": "工作习惯",
            "summary.expand": "查看全部",
            "summary.collapse": "收起",
            "summary.activity.trend": "活动趋势图表（开发中）",
            
            // Tag Management
            "tag.management.title": "标签管理",
            "tag.management.add": "添加",
            "tag.management.clean": "清理",
            "tag.management.edit": "编辑",
            "tag.management.edit.alert.title": "编辑标签",
            "tag.management.edit.alert.placeholder": "标签名称",
            "tag.management.edit.alert.cancel": "取消",
            "tag.management.edit.alert.save": "保存",
            "tag.management.search.placeholder": "搜索标签",
            "tag.management.search.clear": "清除",
            "tag.management.usage.count": "使用 %d 次",
            "tag.management.last.used": "最后使用: %@",
            "tag.management.add.first": "添加第一个标签",
            
            // Settings
            "settings.title": "设置",
            "settings.language": "语言",
            "settings.language.description": "选择应用显示语言",
            
            // Common
            "common.cancel": "取消",
            "common.confirm": "确认",
            "common.save": "保存",
            "common.delete": "删除",
            "common.edit": "编辑",
            "common.add": "添加",
            "common.search": "搜索",
        ]
        
        // 英文字符串
        let englishStrings: [String: String] = [
            // Tab Bar
            "tab.home": "Home",
            "tab.category": "Category",
            
            // Home Page
            "home.title": "Home",
            "home.no.memos": "No memos",
            
            // Category
            "category.title": "Tags",
            "category.no.tags": "No tags",
            "category.no.tags.description": "Tags will appear here after you add them when creating a Memo",
            "category.tag.memos": "Tag - %@",
            "category.no.related.memos": "No related memos",
            "category.no.related.memos.description": "No memos with tag \"%@\" yet",
            "category.no.title": "No title",
            
            // OnBoarding
            "onboarding.welcome": "Welcome",
            "onboarding.subtitle": "Smart Memo Assistant",
            "onboarding.start.button": "Get Started with MemoFlux",
            "onboarding.feature.image.recognition.title": "Smart Image Recognition",
            "onboarding.feature.image.recognition.content": "Take photos or select images, automatically recognize text content and perform AI analysis to quickly create memos.",
            "onboarding.feature.ai.analysis.title": "AI Smart Analysis",
            "onboarding.feature.ai.analysis.content": "Use artificial intelligence to automatically analyze content and extract key information, generate tags and tasks.",
            "onboarding.feature.tag.management.title": "Smart Tag Management",
            "onboarding.feature.tag.management.content": "Automatically generate relevant tags to help you better organize and find memo content.",
            "onboarding.feature.schedule.extraction.title": "Schedule Task Extraction",
            "onboarding.feature.schedule.extraction.content": "Intelligently extract time and task information from memos and automatically generate schedule arrangements.",
            
            // Add Memo
            "memo.add.title": "Add Memo",
            "memo.input.title.placeholder": "Enter title",
            "memo.input.text.placeholder": "Enter text here\nor click the button below to upload an image",
            "memo.input.button": "Input/Paste text content",
            "memo.use.ai.parsing": "Use AI parsing",
            "memo.create": "Create Memo",
            "memo.creating": "Creating...",
            "memo.camera": "Take Photo",
            "memo.photo.library": "Choose from Library",
            "memo.source.manual": "Manual Creation",
            "memo.source.shortcut": "Shortcut",
            
            // Tags
            "tags.add": "Add Tags",
            "tags.add.custom": "Add Custom",
            "tags.ai.suggested": "AI Suggested Tags",
            "tags.local": "Local Tags",
            "tags.no.local": "No local tags",
            "tags.add.custom.alert.title": "Add Custom Tag",
            "tags.add.custom.alert.placeholder": "Enter tag name",
            "tags.add.custom.alert.cancel": "Cancel",
            "tags.add.custom.alert.confirm": "Confirm",
            "tags.add.custom.alert.empty": "Please enter a name for the new tag",
            
            // Intent Detection
            "intent.detection.title": "Intent Detection",
            "intent.detection.processing": "Detecting intent...",
            "intent.detection.schedule.found": "Schedule detected",
            "intent.detection.schedule": "Schedule: %@",
            "intent.detection.time": "Time: %@",
            "intent.detection.tasks": "Tasks: %@",
            "intent.detection.no.schedule": "No schedule detected",
            "intent.detection.waiting": "Waiting for intent detection",
            "intent.detection.description": "When AI detects schedules, task reminders and other intents, quick action options will be provided here.",
            "intent.detection.add.calendar": "Add to Calendar",
            "intent.detection.add.reminder": "Add to Reminders",
            
            // Summary
            "summary.title": "Daily Summary",
            "summary.select.date": "Select Date",
            "summary.select.date.complete": "Done",
            "summary.today.overview": "Today's Overview",
            "summary.new.information": "New Information",
            "summary.completed.intent": "Completed Intent",
            "summary.new.intent": "New Intent",
            "summary.today.new.information": "Today's New Information",
            "summary.today.no.information": "No new information today",
            "summary.more.information": "%d more items",
            "summary.intent.processing": "Intent Processing",
            "summary.today.no.intent": "No intents today",
            "summary.processed.intent": "Processed Intents (%d)",
            "summary.more.processed.intent": "%d more processed intents",
            "summary.pending.intent": "Pending Intents (%d)",
            "summary.more.pending.intent": "%d more pending intents",
            "summary.suggested.actions": "Suggested Actions (In Development)",
            "summary.ai.insights": "AI Insights & Trends (In Development)",
            "summary.personalized.insights": "Personalized Insights",
            "summary.efficiency.analysis": "Efficiency Analysis Chart",
            "summary.efficiency.improvement": "Efficiency Improvement",
            "summary.work.habits": "Work Habits",
            "summary.expand": "View All",
            "summary.collapse": "Collapse",
            "summary.activity.trend": "Activity Trend Chart (In Development)",
            
            // Tag Management
            "tag.management.title": "Tag Management",
            "tag.management.add": "Add",
            "tag.management.clean": "Clean",
            "tag.management.edit": "Edit",
            "tag.management.edit.alert.title": "Edit Tag",
            "tag.management.edit.alert.placeholder": "Tag name",
            "tag.management.edit.alert.cancel": "Cancel",
            "tag.management.edit.alert.save": "Save",
            "tag.management.search.placeholder": "Search tags",
            "tag.management.search.clear": "Clear",
            "tag.management.usage.count": "Used %d times",
            "tag.management.last.used": "Last used: %@",
            "tag.management.add.first": "Add First Tag",
            
            // Settings
            "settings.title": "Settings",
            "settings.language": "Language",
            "settings.language.description": "Choose app display language",
            
            // Common
            "common.cancel": "Cancel",
            "common.confirm": "Confirm",
            "common.save": "Save",
            "common.delete": "Delete",
            "common.edit": "Edit",
            "common.add": "Add",
            "common.search": "Search",
        ]
        
        localizedStrings["zh-Hans"] = chineseStrings
        localizedStrings["en"] = englishStrings
    }
    
    func localizedString(for key: String, arguments: [CVarArg] = []) -> String {
        let language = LanguageManager.shared.currentLanguage.rawValue
        let strings = localizedStrings[language] ?? localizedStrings["en"]!
        
        if let localizedString = strings[key] {
            if arguments.isEmpty {
                return localizedString
            } else {
                return String(format: localizedString, arguments: arguments)
            }
        }
        
        // 如果找不到本地化字符串，返回key本身
        return key
    }
}

