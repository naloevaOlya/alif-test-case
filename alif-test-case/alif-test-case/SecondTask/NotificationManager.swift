//
//  NotificationManager.swift
//  alif-test-case
//
//  Created by Оля Налоева on 02.02.2025.
//

import Foundation
import UserNotifications

protocol NotificationManager: AnyObject {
    func scheduleReminder(for task: Task)
    func notifyAssigner(task: Task, message: String)
}

class NotificationManagerImp: NotificationManager {

    func scheduleReminder(for task: Task) {
        let content = UNMutableNotificationContent()
        content.title = "Напоминание о задаче"
        content.body = "Задача \(task.title) должна быть выполнена к \(task.deadline)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func notifyAssigner(task: Task, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Статус задачи"
        content.body = message
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
