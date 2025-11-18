//
//  CategoryDetailView.swift
//  TodoList
//
//  Created on 2025-11-18.
//

import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    let category: Category
    @Environment(\.modelContext) private var modelContext

    var todos: [TodoItem] {
        category.todos?.sorted(by: { $0.createdAt > $1.createdAt }) ?? []
    }

    var body: some View {
        List {
            if todos.isEmpty {
                emptyStateView
            } else {
                ForEach(todos) { todo in
                    TodoRowView(todo: todo, onToggleCompletion: {
                        toggleCompletion(todo)
                    })
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteTodo(todo)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                toggleCompletion(todo)
                            } label: {
                                Label(
                                    todo.isCompleted ? "取消完成" : "完成",
                                    systemImage: todo.isCompleted ? "arrow.uturn.backward" : "checkmark"
                                )
                            }
                            .tint(todo.isCompleted ? .orange : .green)
                        }
                }
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: category.iconName)
                .font(.system(size: 60))
                .foregroundStyle(Color(hex: category.colorHex))

            Text("该分类下暂无任务")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private func toggleCompletion(_ todo: TodoItem) {
        let notificationManager = NotificationManager.shared

        withAnimation {
            todo.isCompleted.toggle()
            todo.completedAt = todo.isCompleted ? Date() : nil

            // 如果任务已完成，取消通知；否则重新安排通知
            if todo.isCompleted {
                notificationManager.cancelNotification(for: todo)
            } else {
                notificationManager.updateNotification(for: todo)
            }

            try? modelContext.save()
        }
    }

    private func deleteTodo(_ todo: TodoItem) {
        let notificationManager = NotificationManager.shared

        withAnimation {
            // 删除任务前取消通知
            notificationManager.cancelNotification(for: todo)
            modelContext.delete(todo)
            try? modelContext.save()
        }
    }
}

#Preview {
    let container = PreviewContainer().container
    let context = container.mainContext
    let descriptor = FetchDescriptor<Category>()
    let categories = try? context.fetch(descriptor)

    NavigationStack {
        if let category = categories?.first {
            CategoryDetailView(category: category)
        }
    }
    .modelContainer(container)
}
