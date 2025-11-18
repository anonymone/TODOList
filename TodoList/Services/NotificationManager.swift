//
//  NotificationManager.swift
//  TodoList
//
//  Created on 2025-11-18.
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    private init() {}

    // MARK: - 请求通知权限
    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            isAuthorized = granted

            if granted {
                print("通知权限已授予")
            } else {
                print("通知权限被拒绝")
            }
        } catch {
            print("请求通知权限失败: \(error)")
        }
    }

    // MARK: - 检查通知权限状态
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - 为任务安排通知
    func scheduleNotification(for todo: TodoItem) {
        guard let dueDate = todo.dueDate, !todo.isCompleted else {
            return
        }

        // 检查截止日期是否在未来
        guard dueDate > Date() else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "任务提醒"
        content.body = todo.title
        content.sound = .default

        // 添加分类信息
        if let category = todo.category {
            content.subtitle = "分类: \(category.name)"
        }

        // 添加优先级徽章
        content.badge = NSNumber(value: todo.priority.rawValue + 1)

        // 添加自定义数据
        content.userInfo = [
            "todoId": todo.id.uuidString,
            "todoTitle": todo.title
        ]

        // 设置触发器（在截止时间触发）
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: dueDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // 创建请求
        let request = UNNotificationRequest(
            identifier: todo.id.uuidString,
            content: content,
            trigger: trigger
        )

        // 添加通知
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("添加通知失败: \(error)")
            } else {
                print("通知已安排: \(todo.title)")
            }
        }
    }

    // MARK: - 提前提醒通知（提前1小时）
    func scheduleAdvanceNotification(for todo: TodoItem, minutesBefore: Int = 60) {
        guard let dueDate = todo.dueDate,
              !todo.isCompleted,
              let advanceDate = Calendar.current.date(
                byAdding: .minute,
                value: -minutesBefore,
                to: dueDate
              ),
              advanceDate > Date() else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "任务即将到期"
        content.body = "\(todo.title) 将在 \(minutesBefore) 分钟后到期"
        content.sound = .default

        if let category = todo.category {
            content.subtitle = "分类: \(category.name)"
        }

        content.userInfo = [
            "todoId": todo.id.uuidString,
            "todoTitle": todo.title,
            "isAdvanceNotification": true
        ]

        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: advanceDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: "\(todo.id.uuidString)_advance",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("添加提前通知失败: \(error)")
            } else {
                print("提前通知已安排: \(todo.title)")
            }
        }
    }

    // MARK: - 取消任务的通知
    func cancelNotification(for todo: TodoItem) {
        let identifiers = [
            todo.id.uuidString,
            "\(todo.id.uuidString)_advance"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("已取消通知: \(todo.title)")
    }

    // MARK: - 取消所有通知
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("已取消所有通知")
    }

    // MARK: - 获取待处理的通知
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }

    // MARK: - 更新任务通知
    func updateNotification(for todo: TodoItem) {
        // 先取消旧通知
        cancelNotification(for: todo)

        // 如果任务未完成且有截止日期，重新安排通知
        if !todo.isCompleted, todo.dueDate != nil {
            scheduleNotification(for: todo)
            // 可选：安排提前提醒（提前1小时）
            scheduleAdvanceNotification(for: todo, minutesBefore: 60)
        }
    }
}
