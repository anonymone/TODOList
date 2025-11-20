//
//  PreviewContainer.swift
//  TodoList
//
//  Created on 2025-11-18.
//

import SwiftUI
import SwiftData

@MainActor
struct PreviewContainer {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([TodoItem.self, Category.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            container = try ModelContainer(for: schema, configurations: [configuration])

            // 添加示例数据
            addSampleData()
        } catch {
            fatalError("创建预览容器失败: \(error)")
        }
    }

    private func addSampleData() {
        let context = container.mainContext

        // 创建分类
        let workCategory = Category(name: "工作", colorHex: "#007AFF", iconName: "briefcase.fill")
        let personalCategory = Category(name: "个人", colorHex: "#34C759", iconName: "person.fill")
        let shoppingCategory = Category(name: "购物", colorHex: "#FF9500", iconName: "cart.fill")

        context.insert(workCategory)
        context.insert(personalCategory)
        context.insert(shoppingCategory)

        // 创建任务
        let todo1 = TodoItem(
            title: "完成项目报告",
            notes: "需要包含本季度的销售数据",
            priority: .high,
            dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
            reminderMinutes: 60,
            category: workCategory
        )

        let todo2 = TodoItem(
            title: "购买生活用品",
            notes: "牙膏、洗发水、纸巾",
            isCompleted: true,
            priority: .medium,
            category: shoppingCategory
        )

        let todo3 = TodoItem(
            title: "健身",
            notes: "跑步30分钟",
            priority: .low,
            dueDate: Date(),
            reminderMinutes: 30,
            category: personalCategory
        )

        let todo4 = TodoItem(
            title: "阅读新书",
            notes: "《Swift编程指南》第3章",
            priority: .medium,
            category: personalCategory
        )

        context.insert(todo1)
        context.insert(todo2)
        context.insert(todo3)
        context.insert(todo4)

        do {
            try context.save()
        } catch {
            print("保存示例数据失败: \(error)")
        }
    }
}
