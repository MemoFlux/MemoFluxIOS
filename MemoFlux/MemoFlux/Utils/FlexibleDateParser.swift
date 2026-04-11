//
//  FlexibleDateParser.swift
//  MemoFlux
//
//  Created by OpenAI Codex on 2026/3/31.
//

import Foundation

enum FlexibleDateParser {
  private static let iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()
  
  private static let fallbackISO8601Formatter = ISO8601DateFormatter()
  
  private static let localDateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = .current
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter
  }()
  
  private static let localDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = .current
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()
  
  static func parse(_ rawValue: String) -> Date? {
    let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedValue.isEmpty else { return nil }
    
    if trimmedValue.caseInsensitiveCompare("today") == .orderedSame {
      return Calendar.current.startOfDay(for: Date())
    }
    
    if let date = iso8601Formatter.date(from: trimmedValue)
      ?? fallbackISO8601Formatter.date(from: trimmedValue)
      ?? localDateTimeFormatter.date(from: trimmedValue) {
      return date
    }
    
    if let dateOnly = localDateFormatter.date(from: trimmedValue) {
      return Calendar.current.startOfDay(for: dateOnly)
    }
    
    return nil
  }
}
