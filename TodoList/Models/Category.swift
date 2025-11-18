//
//  Category.swift
//  TodoList
//
//  Created on 2025-11-18.
//

import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID
    var name: String
    var colorHex: String
    var iconName: String
    var createdAt: Date

    @Relationship(deleteRule: .nullify)
    var todos: [TodoItem]?

    init(
        name: String,
        colorHex: String = "#007AFF",
        iconName: String = "folder.fill"
    ) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.createdAt = Date()
    }

    // 未完成的任务数量
    var incompleteTodoCount: Int {
        todos?.filter { !$0.isCompleted }.count ?? 0
    }

    // 总任务数量
    var totalTodoCount: Int {
        todos?.count ?? 0
    }
}

// MARK: - 预定义分类
extension Category {
    static var defaultCategories: [Category] {
        [
            Category(name: "工作", colorHex: "#007AFF", iconName: "briefcase.fill"),
            Category(name: "个人", colorHex: "#34C759", iconName: "person.fill"),
            Category(name: "购物", colorHex: "#FF9500", iconName: "cart.fill"),
            Category(name: "学习", colorHex: "#AF52DE", iconName: "book.fill")
        ]
    }
}
