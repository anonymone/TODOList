//
//  TodoItem.swift
//  TodoList
//
//  Created on 2025-11-18.
//

import Foundation
import SwiftData

@Model
final class TodoItem {
    var id: UUID
    var title: String
    var notes: String
    var isCompleted: Bool
    var priority: Priority
    var dueDate: Date?
    var createdAt: Date
    var completedAt: Date?

    @Relationship(deleteRule: .nullify, inverse: \Category.todos)
    var category: Category?

    init(
        title: String,
        notes: String = "",
        isCompleted: Bool = false,
        priority: Priority = .medium,
        dueDate: Date? = nil,
        category: Category? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.createdAt = Date()
        self.category = category
    }

    // 是否已过期
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }

    // 是否即将到期（24小时内）
    var isDueSoon: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return dueDate <= tomorrow && dueDate >= Date()
    }
}

// MARK: - Priority Enum
enum Priority: Int, Codable, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2

    var displayName: String {
        switch self {
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        }
    }

    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}
