//
//  AddTodoView.swift
//  TodoList
//
//  Created on 2025-11-18.
//

import SwiftUI
import SwiftData

struct AddTodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [Category]

    // 编辑模式
    var todoToEdit: TodoItem?

    // 表单字段
    @State private var title = ""
    @State private var notes = ""
    @State private var selectedPriority: Priority = .medium
    @State private var selectedCategory: Category?
    @State private var hasDueDate = false
    @State private var dueDate = Date()

    var isEditing: Bool {
        todoToEdit != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                // 标题
                Section {
                    TextField("任务标题", text: $title)
                        .font(.body)
                }

                // 备注
                Section("备注") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                        .font(.body)
                }

                // 优先级
                Section("优先级") {
                    Picker("优先级", selection: $selectedPriority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // 分类
                Section("分类") {
                    Picker("选择分类", selection: $selectedCategory) {
                        Text("无").tag(nil as Category?)
                        ForEach(categories) { category in
                            Label(category.name, systemImage: category.iconName)
                                .tag(category as Category?)
                        }
                    }
                }

                // 截止日期
                Section {
                    Toggle("设置截止日期", isOn: $hasDueDate)

                    if hasDueDate {
                        DatePicker(
                            "截止日期",
                            selection: $dueDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }
            }
            .navigationTitle(isEditing ? "编辑任务" : "新建任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "保存" : "添加") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear {
            loadTodoData()
        }
    }

    private func loadTodoData() {
        guard let todo = todoToEdit else { return }

        title = todo.title
        notes = todo.notes
        selectedPriority = todo.priority
        selectedCategory = todo.category
        if let dueDate = todo.dueDate {
            hasDueDate = true
            self.dueDate = dueDate
        }
    }

    private func saveTask() {
        let notificationManager = NotificationManager.shared

        if let todo = todoToEdit {
            // 编辑模式：更新现有任务
            todo.title = title
            todo.notes = notes
            todo.priority = selectedPriority
            todo.category = selectedCategory
            todo.dueDate = hasDueDate ? dueDate : nil

            // 更新通知
            notificationManager.updateNotification(for: todo)
        } else {
            // 新建模式：创建新任务
            let newTodo = TodoItem(
                title: title,
                notes: notes,
                priority: selectedPriority,
                dueDate: hasDueDate ? dueDate : nil,
                category: selectedCategory
            )
            modelContext.insert(newTodo)

            // 安排通知
            if hasDueDate {
                notificationManager.scheduleNotification(for: newTodo)
                notificationManager.scheduleAdvanceNotification(for: newTodo, minutesBefore: 60)
            }
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("保存任务失败: \(error)")
        }
    }
}

#Preview("添加任务") {
    AddTodoView()
        .modelContainer(PreviewContainer().container)
}

#Preview("编辑任务") {
    let container = PreviewContainer().container
    let context = container.mainContext
    let descriptor = FetchDescriptor<TodoItem>()
    let todos = try? context.fetch(descriptor)

    return AddTodoView(todoToEdit: todos?.first)
        .modelContainer(container)
}
