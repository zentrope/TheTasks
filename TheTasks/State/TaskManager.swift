//
//  TaskManager.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import Foundation
import CoreData
import OSLog

fileprivate let log = Logger("TaskManager")

struct TaskManager {

    static var shared = TaskManager(controller: PersistenceController.shared)

    private var controller: PersistenceController

    // Make this public when I figure out how to make tests relevant
    private init(controller: PersistenceController) {
        self.controller = controller
    }

    func add(tag: TagManager.Tag, to task: TheTask) async throws {
        let context = controller.newBackgroundContext()
        try await context.perform {
            let taskMO = try find(task: task.id, context: context)
            let tagMO = try TagManager.shared.find(id: tag.id, context: context)
            taskMO.addToTags(tagMO)
            try context.commit()
        }
    }

    func remove(tag: TagManager.Tag, from task: TheTask) async throws {
        let context = controller.newBackgroundContext()
        try await context.perform {
            let taskMO = try find(task: task.id, context: context)
            let tagMO = try TagManager.shared.find(id: tag.id, context: context)
            taskMO.removeFromTags(tagMO)            
            try context.commit()
        }
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

    /// Update the task if it already exists, or create a new one if not.
    func upsert(task: TheTask) async throws {
        let context = controller.newBackgroundContext()
        try await context.perform {
            let taskMO = findOrMake(task: task, context: context)
            taskMO.id = task.id
            taskMO.created = task.created
            taskMO.status = task.status.rawValue
            taskMO.task = task.task
            taskMO.tags = NSSet(array: task.tags.map { TagManager.shared.findOrMake(tag: $0, context: context)})
            taskMO.isExportable = task.isExportable
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

    func cursor(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) -> NSFetchedResultsController<TaskMO> {
        let request = TaskMO.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }

    func numberOfTasks(withStatus status: TaskMO.TaskStatus? = nil) throws -> Int {
        let fetch = TaskMO.fetchRequest()
        if let status {
            fetch.predicate = NSPredicate(format: "status = %@", status.rawValue)
        }
        return try controller.container.viewContext.count(for: fetch)
    }


    func removeDuplicates() async throws {

        // This is necessary due something going wrong with CloudKit integration, or a bug on my part. CloudKit integration does not allow uniqueness constraints, so it's possible that an incoming update will duplicate items. Or maybe it was just the one time.

        log.info("Invoking remove duplicates function.")
        let context = controller.newBackgroundContext()
        try await context.perform {
            let cursor = cursor(context: context)
            try cursor.performFetch()

            var checker = [UUID:[TaskMO]]()

            for task in (cursor.fetchedObjects ?? []) {
                if let matchList = checker[task.id] {
                    checker[task.id] = matchList + [task]
                } else {
                    checker[task.id] = [task]
                }
            }

            if checker.isEmpty {
                log.debug("No duplicate tasks found.")
                return
            }

            for duplicates in checker.values {
                if duplicates.count == 1 {
                    continue
                }

                for index in (1..<duplicates.count) {
                    let taskMO = duplicates[index]
                    log.debug("Removing instance \(index) of \(duplicates.count) of task \(taskMO.id).")
                    context.delete(taskMO)
                }
            }

            try context.commit()
        }
    }
}

extension TaskManager {

    private func findOrMake(task: TheTask, context: NSManagedObjectContext) -> TaskMO {
        do {
            let task = try find(task: task.id, context: context)
            return task
        } catch {
            return TaskMO(context: context)
        }
    }

    private func find(task id: UUID, context: NSManagedObjectContext) throws -> TaskMO {
        let request = TaskMO.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        if let theTask = try context.fetch(request).first {
            return theTask
        }
        throw PersistenceError.taskNotFound
    }
}
