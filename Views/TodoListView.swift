//
//  TodoListView.swift
//  TodoList
//
//  Created on 2025-11-18.
//

import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TodoItem.createdAt, order: .reverse) private var todos: [TodoItem]
    @State private var showingAddTodo = false
    @State private var searchText = ""
    @State private var filterCompleted: FilterOption = .all

    enum FilterOption: String, CaseIterable {
        case all = "全部"
        case active = "未完成"
        case completed = "已完成"
    }

    var filteredTodos: [TodoItem] {
        var result = todos

        // 按完成状态筛选
        switch filterCompleted {
        case .all:
            break
        case .active:
            result = result.filter { !$0.isCompleted }
        case .completed:
            result = result.filter { $0.isCompleted }
        }

        // 搜索过滤
        if !searchText.isEmpty {
            result = result.filter { todo in
                todo.title.localizedCaseInsensitiveContains(searchText) ||
                todo.notes.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 筛选器
                Picker("筛选", selection: $filterCompleted) {
                    ForEach(FilterOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // 任务列表
                if filteredTodos.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(filteredTodos) { todo in
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
                    .listStyle(.plain)
                }
            }
            .navigationTitle("我的任务")
            .searchable(text: $searchText, prompt: "搜索任务")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTodo = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTodo) {
                AddTodoView()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text(searchText.isEmpty ? "暂无任务" : "未找到相关任务")
                .font(.title3)
                .foregroundStyle(.secondary)

            if searchText.isEmpty {
                Text("点击右上角 + 按钮添加新任务")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    TodoListView()
        .modelContainer(PreviewContainer().container)
}
