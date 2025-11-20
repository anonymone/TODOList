//
//  NotificationManager.swift
//  TodoList
//
//  Created on 2025-11-18.
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    private override init() {
        super.init()
        // 设置通知中心的代理
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - 请求通知权限
    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge, .provisional]
            )
            isAuthorized = granted

            if granted {
                print("✅ 通知权限已授予")
            } else {
                print("❌ 通知权限被拒绝")
            }
        } catch {
            print("❌ 请求通知权限失败: \(error)")
        }
    }

    // MARK: - 检查通知设置详情
    func checkNotificationSettings() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()

        if settings.authorizationStatus == .authorized {
            print("✅ 通知权限正常")
        } else if settings.authorizationStatus == .provisional {
            print("⚠️ 使用临时授权")
        } else if settings.authorizationStatus == .denied {
            print("❌ 通知权限被拒绝")
        }

        if settings.alertSetting == .disabled {
            print("⚠️ 横幅通知已被禁用")
        }
    }

    // MARK: - 检查通知权限状态
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - 为任务安排通知
    func scheduleNotification(for todo: TodoItem) {
        guard let dueDate = todo.dueDate, !todo.isCompleted else { return }
        guard dueDate > Date() else { return }

        Task {
            // 获取当前已投递和待投递的TODO通知数量
            let deliveredNotifications = await UNUserNotificationCenter.current().deliveredNotifications()
            let pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()

            let deliveredCount = deliveredNotifications.filter { notification in
                notification.request.content.userInfo["todoId"] != nil
            }.count

            let pendingCount = pendingRequests.filter { request in
                request.content.userInfo["todoId"] != nil
            }.count

            let content = UNMutableNotificationContent()
            content.title = "⏰ 任务到期提醒"
            content.body = todo.title
            content.sound = .default
            // badge = 已投递 + 待投递 + 1（这条新通知）
            content.badge = NSNumber(value: deliveredCount + pendingCount + 1)
            content.interruptionLevel = .timeSensitive
            content.relevanceScore = 1.0

            if let category = todo.category {
                content.subtitle = "📁 \(category.name)"
            }

            content.userInfo = [
                "todoId": todo.id.uuidString,
                "todoTitle": todo.title
            ]

            let dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dueDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            let request = UNNotificationRequest(
                identifier: todo.id.uuidString,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ 添加通知失败: \(error)")
                } else {
                    print("✅ 通知已安排: \(todo.title), badge预设为: \(deliveredCount + pendingCount + 1)")
                }
            }
        }
    }

    // MARK: - 提前提醒通知
    func scheduleAdvanceNotification(for todo: TodoItem, minutesBefore: Int = 60) {
        guard let dueDate = todo.dueDate,
              !todo.isCompleted,
              minutesBefore > 0,
              let advanceDate = Calendar.current.date(
                byAdding: .minute,
                value: -minutesBefore,
                to: dueDate
              ),
              advanceDate > Date() else {
            return
        }

        Task {
            // 获取当前已投递和待投递的TODO通知数量
            let deliveredNotifications = await UNUserNotificationCenter.current().deliveredNotifications()
            let pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()

            let deliveredCount = deliveredNotifications.filter { notification in
                notification.request.content.userInfo["todoId"] != nil
            }.count

            let pendingCount = pendingRequests.filter { request in
                request.content.userInfo["todoId"] != nil
            }.count

            let content = UNMutableNotificationContent()
            content.title = "⏱️ 任务即将到期"

            let timeText = minutesBefore >= 60
                ? "\(minutesBefore / 60) 小时"
                : "\(minutesBefore) 分钟"
            content.body = "\(todo.title) 将在 \(timeText)后到期"
            content.sound = .default
            // badge = 已投递 + 待投递 + 1（这条新通知）
            content.badge = NSNumber(value: deliveredCount + pendingCount + 1)
            content.interruptionLevel = .timeSensitive
            content.relevanceScore = 0.8

            if let category = todo.category {
                content.subtitle = "📁 \(category.name)"
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
                    print("❌ 添加提前通知失败: \(error)")
                } else {
                    print("✅ 提前通知已安排: \(todo.title) (提前\(minutesBefore)分钟), badge预设为: \(deliveredCount + pendingCount + 1)")
                }
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
        print("🗑️ 已取消通知: \(todo.title)")
    }

    // MARK: - 取消所有通知
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ 已取消所有通知")
    }

    // MARK: - 获取待处理的通知
    func getPendingNotifications() async -> [UNNotificationRequest] {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        print("📋 当前待处理通知数量: \(requests.count)")
        return requests
    }

    // MARK: - 更新任务通知
    func updateNotification(for todo: TodoItem) {
        // 先取消旧通知
        cancelNotification(for: todo)

        // 如果任务未完成且有截止日期，重新安排通知
        if !todo.isCompleted, todo.dueDate != nil {
            scheduleNotification(for: todo)
            // 如果设置了提醒时间，安排提前提醒
            if let reminderMinutes = todo.reminderMinutes, reminderMinutes > 0 {
                scheduleAdvanceNotification(for: todo, minutesBefore: reminderMinutes)
            }
        }
    }

    // MARK: - 清除Badge
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("清除Badge失败: \(error)")
            } else {
                print("Badge已清除")
            }
        }
    }

    // MARK: - 同步Badge数量
    func syncBadgeCount() async {
        let deliveredNotifications = await UNUserNotificationCenter.current().deliveredNotifications()

        // 只计算属于TODO app的通知
        let todoNotificationCount = deliveredNotifications.filter { notification in
            notification.request.content.userInfo["todoId"] != nil
        }.count

        UNUserNotificationCenter.current().setBadgeCount(todoNotificationCount) { error in
            if let error = error {
                print("❌ 同步Badge失败: \(error)")
            } else {
                print("✅ Badge已同步为: \(todoNotificationCount)")
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate Methods

    // 当应用在前台时收到通知的处理
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 动态更新badge：每次通知投递时重新计算
        Task {
            // 获取当前已投递的TODO通知数量
            let deliveredNotifications = await center.deliveredNotifications()
            let currentBadgeCount = deliveredNotifications.filter { notification in
                notification.request.content.userInfo["todoId"] != nil
            }.count

            // badge = 当前已投递的TODO通知 + 1（这条新通知）
            let newBadgeCount = currentBadgeCount + 1

            center.setBadgeCount(newBadgeCount) { error in
                if let error = error {
                    print("❌ 更新badge失败: \(error)")
                } else {
                    print("✅ 通知投递时badge已更新为: \(newBadgeCount)")
                }
            }
        }

        // 在前台显示通知横幅、列表、声音
        // 不包含.badge因为我们手动设置了
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }

    // 当用户点击通知时的处理
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // 用户点击了通知，不在这里清除badge
        // 等用户真正查看了对应任务详情页再清除
        completionHandler()
    }

    // 清除特定任务的已投递通知和badge
    func clearBadgeForTodo(_ todoId: String) async {
        // 获取所有已投递的通知
        let deliveredNotifications = await UNUserNotificationCenter.current().deliveredNotifications()

        // 查找与该任务相关的通知标识符
        var notificationIdsToRemove: [String] = []
        var todoAppNotificationCount = 0  // 统计属于本app的TODO通知数量

        for notification in deliveredNotifications {
            // 检查是否是TODO app的通知（有todoId字段）
            if let notificationTodoId = notification.request.content.userInfo["todoId"] as? String {
                if notificationTodoId == todoId {
                    // 是当前任务的通知，需要移除
                    notificationIdsToRemove.append(notification.request.identifier)
                } else {
                    // 是其他任务的通知，计数
                    todoAppNotificationCount += 1
                }
            }
        }

        // 移除该任务相关的通知
        if !notificationIdsToRemove.isEmpty {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: notificationIdsToRemove)
            print("🗑️ 已移除 \(notificationIdsToRemove.count) 个通知")
        }

        // 使用短暂延迟确保通知已被系统移除
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒

        // 更新badge为剩余TODO通知的数量
        UNUserNotificationCenter.current().setBadgeCount(todoAppNotificationCount) { error in
            if let error = error {
                print("❌ 更新badge失败: \(error)")
            } else {
                print("✅ Badge已更新为: \(todoAppNotificationCount)")
            }
        }
    }
}