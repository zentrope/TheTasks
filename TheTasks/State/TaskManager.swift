//
//  TaskManager.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import Foundation
import CoreData
import OSLog

fileprivate let log = Logger("TheTaskManager")

struct TaskManager {

    static var shared = TaskManager(controller: PersistenceController.shared)

    private var controller: PersistenceController

    // Make this public when I figure out how to make tests relevant
    private init(controller: PersistenceController) {
        self.controller = controller
    }

    func insert(task: TheTask) async throws {
        log.debug("inserting task: \(String(describing: task))")
        let context = controller.newBackgroundContext()
        try await context.perform {
            let taskMO = TaskMO(context: context)
            taskMO.id = task.id
            taskMO.task = task.task
            taskMO.created = task.created
            taskMO.completed = task.completed
            taskMO.status = task.status.rawValue
            taskMO.isExportable = false
            try context.commit()
        }
    }

    func update(task id: UUID, isExportable: Bool) async throws {
        let context = controller.newBackgroundContext()
        try await context.perform {
            let taskMO = try find(task: id, context: context)
            taskMO.isExportable = isExportable
            try context.commit()
        }
    }

    func update(task id: UUID, status: String, completed: Date? = nil) async throws {
        let context = controller.newBackgroundContext()
        try await context.perform {
            let taskMO = try find(task: id, context: context)
            taskMO.status = status
            taskMO.completed = completed
            try context.commit()
        }
    }

    func update(task id: UUID, description: String) async throws {
        log.debug("renaming task \(id) to \(description).")
        let context = controller.newBackgroundContext()
        try await context.perform {
            let taskMO = try find(task: id, context: context)
            taskMO.task = description
            try context.commit()
        }
    }

    func delete(task: UUID) async throws {
        let context = controller.newBackgroundContext()
        try await context.perform {
            let taskMO = try find(task: task, context: context)
            context.delete(taskMO)
            try context.commit()
        }
    }

    func taskCursor() -> NSFetchedResultsController<TaskMO> {
        let request = TaskMO.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: controller.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }

    func numberOfTasks(withStatus status: TaskMO.TaskStatus? = nil) throws -> Int {
        let fetch = TaskMO.fetchRequest()
        if let status {
            fetch.predicate = NSPredicate(format: "status = %@", status.rawValue)
        }
        return try controller.container.viewContext.count(for: fetch)
    }
}

extension TaskManager {

    private func find(task id: UUID, context: NSManagedObjectContext) throws -> TaskMO {
        let request = TaskMO.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        if let theTask = try context.fetch(request).first {
            return theTask
        }
        throw PersistenceError.taskNotFound
    }
}

fileprivate extension NSManagedObjectContext {

    func commit() throws {
        if hasChanges {
            try save()
        }
    }
}
