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
    @State private var hasReminder = false
    @State private var reminderOption: ReminderOption = .minutes30

    // 键盘焦点管理
    @FocusState private var focusedField: Field?

    enum Field {
        case title
        case notes
    }

    enum ReminderOption: Int, CaseIterable {
        case minutes5 = 5
        case minutes10 = 10
        case minutes15 = 15
        case minutes30 = 30
        case hour1 = 60
        case hours2 = 120
        case hours3 = 180
        case day1 = 1440

        var displayName: String {
            switch self {
            case .minutes5: return "5 分钟前"
            case .minutes10: return "10 分钟前"
            case .minutes15: return "15 分钟前"
            case .minutes30: return "30 分钟前"
            case .hour1: return "1 小时前"
            case .hours2: return "2 小时前"
            case .hours3: return "3 小时前"
            case .day1: return "1 天前"
            }
        }
    }

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
                        .focused($focusedField, equals: .title)
                }

                // 备注
                Section("备注") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                        .font(.body)
                        .focused($focusedField, equals: .notes)
                }

                // 优先级
                Section("优先级") {
                    Picker("优先级", selection: $selectedPriority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedPriority) { _, _ in
                        focusedField = nil  // 收起键盘
                    }
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
                    .onChange(of: selectedCategory) { _, _ in
                        focusedField = nil  // 收起键盘
                    }
                }

                // 截止日期
                Section {
                    Toggle("设置截止日期", isOn: $hasDueDate)
                        .onChange(of: hasDueDate) { _, _ in
                            focusedField = nil  // 收起键盘
                        }

                    if hasDueDate {
                        DatePicker(
                            "截止日期",
                            selection: $dueDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .onChange(of: dueDate) { _, _ in
                            focusedField = nil  // 收起键盘
                        }
                    }
                }

                // 提前提醒
                if hasDueDate {
                    Section {
                        Toggle("设置提前提醒", isOn: $hasReminder)
                            .onChange(of: hasReminder) { _, _ in
                                focusedField = nil  // 收起键盘
                            }

                        if hasReminder {
                            Picker("提醒时间", selection: $reminderOption) {
                                ForEach(ReminderOption.allCases, id: \.self) { option in
                                    Text(option.displayName).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                            .onChange(of: reminderOption) { _, _ in
                                focusedField = nil  // 收起键盘
                            }
                        }
                    } header: {
                        Text("提醒设置")
                    } footer: {
                        if hasReminder {
                            Text("将在任务到期前 \(reminderOption.displayName) 发送通知提醒")
                                .font(.caption)
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
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
        .task {
            // 只在查看已有任务详情时，清除该任务相关的通知和badge
            if isEditing, let todo = todoToEdit {
                await NotificationManager.shared.clearBadgeForTodo(todo.id.uuidString)
            }
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
        if let reminderMinutes = todo.reminderMinutes {
            hasReminder = true
            // 找到匹配的 ReminderOption
            if let option = ReminderOption.allCases.first(where: { $0.rawValue == reminderMinutes }) {
                reminderOption = option
            }
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
            todo.reminderMinutes = (hasDueDate && hasReminder) ? reminderOption.rawValue : nil

            // 更新通知
            notificationManager.cancelNotification(for: todo)
            if hasDueDate && !todo.isCompleted {
                notificationManager.scheduleNotification(for: todo)
                if hasReminder {
                    notificationManager.scheduleAdvanceNotification(for: todo, minutesBefore: reminderOption.rawValue)
                }
            }
        } else {
            // 新建模式：创建新任务
            let newTodo = TodoItem(
                title: title,
                notes: notes,
                priority: selectedPriority,
                dueDate: hasDueDate ? dueDate : nil,
                reminderMinutes: (hasDueDate && hasReminder) ? reminderOption.rawValue : nil,
                category: selectedCategory
            )
            modelContext.insert(newTodo)

            // 安排通知
            if hasDueDate {
                notificationManager.scheduleNotification(for: newTodo)
                if hasReminder {
                    notificationManager.scheduleAdvanceNotification(for: newTodo, minutesBefore: reminderOption.rawValue)
                }
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
