//
//  AddCategoryView.swift
//  TodoList
//
//  Created on 2025-11-18.
//

import SwiftUI
import SwiftData

struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedColor = "#007AFF"
    @State private var selectedIcon = "folder.fill"

    // 预定义颜色
    let colors = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#AF52DE", "#5856D6", "#FF2D55", "#5AC8FA",
        "#FFCC00", "#FF6482", "#00C7BE", "#30D158"
    ]

    // 预定义图标
    let icons = [
        "folder.fill", "briefcase.fill", "person.fill", "cart.fill",
        "book.fill", "star.fill", "heart.fill", "house.fill",
        "bell.fill", "flag.fill", "tag.fill", "paperplane.fill"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("分类名称") {
                    TextField("输入分类名称", text: $name)
                }

                Section("颜色") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 40, height: 40)
                                .overlay {
                                    if selectedColor == color {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                    }
                                }
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("图标") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            ZStack {
                                Circle()
                                    .fill(selectedIcon == icon ? Color(hex: selectedColor).opacity(0.2) : Color.gray.opacity(0.1))
                                    .frame(width: 40, height: 40)

                                Image(systemName: icon)
                                    .foregroundStyle(selectedIcon == icon ? Color(hex: selectedColor) : .secondary)
                                    .font(.title3)
                            }
                            .onTapGesture {
                                selectedIcon = icon
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("预览") {
                    HStack(spacing: 12) {
                        Image(systemName: selectedIcon)
                            .font(.title)
                            .foregroundStyle(Color(hex: selectedColor))
                            .frame(width: 50)

                        Text(name.isEmpty ? "分类名称" : name)
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("新建分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        saveCategory()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveCategory() {
        let newCategory = Category(
            name: name,
            colorHex: selectedColor,
            iconName: selectedIcon
        )
        modelContext.insert(newCategory)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("保存分类失败: \(error)")
        }
    }
}

#Preview {
    AddCategoryView()
        .modelContainer(PreviewContainer().container)
}
