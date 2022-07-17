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
    var tags: [TagManager.Tag]

    var isEditable = false

    init(newTask: String) {
        self.id = UUID()
        self.task = newTask
        self.created = Date()
        self.completed = nil
        self.status = .pending
        self.isExportable = false
        self.tags = []
    }

    init(mo task: TaskMO) {
        self.id = task.id
        self.task = task.task
        self.created = task.created
        self.completed = task.completed
        self.status = task.taskStatus
        self.isExportable = task.isExportable

        self.tags = ((task.tags?.allObjects as? [TagMO]) ?? [])
            .map { TagManager.Tag(mo: $0) }
            .sorted(using: KeyPathComparator(\.name, order: .forward))
    }

    mutating func toggleEditMode(force: Bool? = nil) {
        if let force {
            isEditable = force
            return
        }
        isEditable.toggle()
    }
}
