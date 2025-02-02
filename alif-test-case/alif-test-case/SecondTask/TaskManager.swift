//
//  TaskManager.swift
//  alif-test-case
//
//  Created by Оля Налоева on 02.02.2025.
//

import RealmSwift
import Foundation

protocol TaskManager: AnyObject {
    func addTask(title: String, deadline: Date, assignee: String?)
    func updateTask(task: Task, newTitle: String?, newDeadline: Date?, newStatus: String?)
    func addComment(task: Task, comment: Comment)
    func markTaskAsCompleted(task: Task)
    func deleteTask(task: Task)
}

// MARK: - Models

@objc(Comment)
class Comment: Object {
    @Persisted var text: String
    @Persisted var author: String
}

@objc(Task)
class Task: Object {

    @Persisted var title: String
    @Persisted var deadline: Date
    @Persisted var status: String
    @Persisted var comments = List<Comment>()
    @Persisted var assignee: String?
    @Persisted var history = List<String>()
}

class TaskManagerImp: TaskManager {

    private var realm: Realm?
    private var notificationManager: NotificationManager?
    private var tasks: [Task] = [] {
        didSet {
            guard let objects = realm?.objects(Task.self) else {
                tasks = []
                return
            }
            tasks = Array(objects)
        }
    }

    init(notificationManager: NotificationManager, realm: Realm?) {
        self.notificationManager = notificationManager
        self.realm = realm
    }

    // MARK: - TaskManager

    func addTask(title: String, deadline: Date, assignee: String?) {
        let newTask = Task()
        newTask.title = title
        newTask.deadline = deadline
        newTask.assignee = assignee
        try? realm?.write {
            realm?.add(newTask)
            notificationManager?.scheduleReminder(for: newTask)
        }
    }

    func deleteTask(task: Task) {
        try? realm?.write {
            realm?.delete(task)
        }
    }

    func updateTask(task: Task, newTitle: String?, newDeadline: Date?, newStatus: String?) {
        try? realm?.write {
            if let title = newTitle {
                task.title = title
            }
            if let deadline = newDeadline {
                task.deadline = deadline
            }
            if let status = newStatus {
                task.status = status
            }
            task.history.append("Задача обновлена")
        }
    }

    func addComment(task: Task, comment: Comment) {
        try? realm?.write {
            task.comments.append(comment)
        }
    }

    func markTaskAsCompleted(task: Task) {
        try? realm?.write {
            task.status = "Задача выполнена"
            task.history.append("Задача выполнена")
            notificationManager?.notifyAssigner(task: task, message: "Задача \(task.title) выполнена")
        }
    }
}
