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
    @State private var editingTodo: TodoItem?
    @State private var searchText = ""
    @State private var filterCompleted: FilterOption = .active
    @State private var pendingCompletionIds: Set<UUID> = []

    enum FilterOption: String, CaseIterable {
        case active = "未完成"
        case completed = "已完成"
        case all = "全部"
    }

    var filteredTodos: [TodoItem] {
        var result = todos

        // 按完成状态筛选
        switch filterCompleted {
        case .all:
            break
        case .active:
            // 未完成的任务 + 即将消失的已完成任务
            result = result.filter { !$0.isCompleted || pendingCompletionIds.contains($0.id) }
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
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingTodo = todo
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .top))
                            ))
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
                    .animation(.spring(response: 0.5, dampingFraction: 0.75), value: filteredTodos.map { $0.id })
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
            .sheet(item: $editingTodo) { todo in
                AddTodoView(todoToEdit: todo)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            if searchText.isEmpty {
                switch filterCompleted {
                case .active:
                    Text("太棒了！暂无待办任务")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("点击右上角 + 按钮添加新任务")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                case .completed:
                    Text("还没有已完成的任务")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("完成任务后会显示在这里")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                case .all:
                    Text("暂无任务")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("点击右上角 + 按钮添加新任务")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            } else {
                Text("未找到相关任务")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func toggleCompletion(_ todo: TodoItem) {
        let notificationManager = NotificationManager.shared
        let todoId = todo.id

        withAnimation {
            todo.isCompleted.toggle()
            todo.completedAt = todo.isCompleted ? Date() : nil

            // 如果任务已完成，取消通知；否则重新安排通知
            if todo.isCompleted {
                notificationManager.cancelNotification(for: todo)

                // 将任务加入待消失列表
                pendingCompletionIds.insert(todoId)

                // 1秒后从待消失列表移除，任务会自动消失
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        _ = pendingCompletionIds.remove(todoId)
                    }
                }
            } else {
                notificationManager.updateNotification(for: todo)

                // 取消完成时，立即从待消失列表移除
                pendingCompletionIds.remove(todoId)
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
