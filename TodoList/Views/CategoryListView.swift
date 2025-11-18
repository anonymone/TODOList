//
//  CategoryListView.swift
//  TodoList
//
//  Created on 2025-11-18.
//

import SwiftUI
import SwiftData

struct CategoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.createdAt) private var categories: [Category]
    @State private var showingAddCategory = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryDetailView(category: category)) {
                        CategoryRowView(category: category)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteCategory(category)
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("分类")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
            }
            .overlay {
                if categories.isEmpty {
                    emptyStateView
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("暂无分类")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("点击右上角 + 按钮添加新分类")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
    }

    private func deleteCategory(_ category: Category) {
        withAnimation {
            modelContext.delete(category)
            try? modelContext.save()
        }
    }
}

struct CategoryRowView: View {
    let category: Category

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.iconName)
                .font(.title2)
                .foregroundStyle(Color(hex: category.colorHex))
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.body)

                Text("\(category.incompleteTodoCount) 个未完成 · 共 \(category.totalTodoCount) 个任务")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CategoryListView()
        .modelContainer(PreviewContainer().container)
}
