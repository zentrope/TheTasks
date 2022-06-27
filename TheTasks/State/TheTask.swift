//
//  TheTask.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import Foundation

struct TheTask: Identifiable, Equatable {

    var id: UUID
    var task: String
    var created: Date
    var completed: Date?
    var isExportable: Bool
    var status: TaskMO.TaskStatus

    init(newTask: String) {
        self.id = UUID()
        self.task = newTask
        self.created = Date()
        self.completed = nil
        self.status = .pending
        self.isExportable = false
    }

    init(mo task: TaskMO) {
        self.id = task.id
        self.task = task.task
        self.created = task.created
        self.completed = task.completed
        self.status = task.taskStatus
        self.isExportable = task.isExportable
    }
}
