//
//  ContentView.swift
//  TodoList
//
//  Created on 2025-11-18.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodoListView()
                .tabItem {
                    Label("任务", systemImage: "checklist")
                }
                .tag(0)

            CategoryListView()
                .tabItem {
                    Label("分类", systemImage: "folder.fill")
                }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewContainer().container)
}
