//
//  TodoListApp.swift
//  TodoList
//
//  Created on 2025-11-18.
//

import SwiftUI
import SwiftData

@main
struct TodoListApp: App {
    let modelContainer: ModelContainer
    @StateObject private var notificationManager = NotificationManager.shared

    init() {
        do {
            // 配置SwiftData容器
            let schema = Schema([TodoItem.self, Category.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // 首次启动时创建默认分类
            initializeDefaultCategories()
        } catch {
            fatalError("无法初始化ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // 请求通知权限
                    await notificationManager.requestAuthorization()
                }
        }
        .modelContainer(modelContainer)
    }

    // 初始化默认分类
    private func initializeDefaultCategories() {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<Category>()

        do {
            let existingCategories = try context.fetch(descriptor)
            // 如果没有分类，则创建默认分类
            if existingCategories.isEmpty {
                for category in Category.defaultCategories {
                    context.insert(category)
                }
                try context.save()
            }
        } catch {
            print("初始化默认分类失败: \(error)")
        }
    }
}
