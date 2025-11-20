//
//  TodoRowView.swift
//  TodoList
//
//  Created on 2025-11-18.
//

import SwiftUI
import SwiftData

struct TodoRowView: View {
    let todo: TodoItem
    var onToggleCompletion: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 完成状态按钮
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    onToggleCompletion?()
                }
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(todo.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                // 标题
                Text(todo.title)
                    .font(.body)
                    .strikethrough(todo.isCompleted)
                    .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                    .animation(.easeInOut(duration: 0.2), value: todo.isCompleted)

                // 备注
                if !todo.notes.isEmpty {
                    Text(todo.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                // 底部信息行
                HStack(spacing: 8) {
                    // 分类
                    if let category = todo.category {
                        HStack(spacing: 4) {
                            Image(systemName: category.iconName)
                            Text(category.name)
                        }
                        .font(.caption)
                        .foregroundStyle(Color(hex: category.colorHex))
                    }

                    // 优先级
                    HStack(spacing: 4) {
                        Image(systemName: "flag.fill")
                        Text(todo.priority.displayName)
                    }
                    .font(.caption)
                    .foregroundStyle(todo.priority.color)

                    // 截止日期
                    if let dueDate = todo.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text(formatDate(dueDate))
                        }
                        .font(.caption)
                        .foregroundStyle(dueDateColor(dueDate))
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }

    private func dueDateColor(_ date: Date) -> Color {
        if todo.isCompleted {
            return .secondary
        } else if todo.isOverdue {
            return .red
        } else if todo.isDueSoon {
            return .orange
        } else {
            return .secondary
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    let container = PreviewContainer().container
    let context = container.mainContext
    let descriptor = FetchDescriptor<TodoItem>()
    let todos = try? context.fetch(descriptor)

    List {
        if let todo = todos?.first {
            TodoRowView(todo: todo)
        }
    }
    .modelContainer(container)
}
