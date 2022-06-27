//
//  WeeklyViewState.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/25/22.
//

import CoreData
import Foundation
import OSLog

fileprivate let log = Logger("WeeklyViewState")

@MainActor
final class WeeklyViewState: NSObject, ObservableObject {

    @Published var days = [TaskDay]()
    @Published var focus = Date()
    @Published var completedTasks = 0
    @Published var exportableTasks = 0
    @Published var showAllTasks = true
    @Published var error: Error?
    @Published var showAlert = false

    private var taskManager: TheTaskManager
    private var cursor: NSFetchedResultsController<TaskMO>

    override init() {
        self.taskManager = TheTaskManager(controller: PersistenceController.shared)
        self.cursor = taskManager.taskCursor()
        super.init()
        self.cursor.delegate = self
        self.refocus(on: self.focus)
        self.reload()
    }

    func export() {
        log.debug("An export was requested.")
        var lines = [String]()
        for day in days {
            let tasks = day.tasks.filter({ $0.isExportable })
            guard tasks.count > 0 else { continue }

            let title = "\n# \(day.id.humanString)\n"
            lines.append(title)

            for task in tasks {

                let token     = ":task"
                let id        = "[id:\(task.id.uuidString.lowercased())]"
                let created   = "[created:\(task.created.iso8601)]"
                let completed = "[completed:\(task.completed?.iso8601 ?? "none")]"
                let name      = task.task

                let row = "\(token) \(id) \(created) \(completed) \(name)"
                lines.append(row)
            }
        }
        let text = lines.joined(separator: "\n")

        do {
            let timestamp = focus.endOfWeek().exportMonthYearWeekString
            let filename = "Task Inventory \(timestamp)"
            try AppKit.save(text: text, toName: filename)
        } catch (let error) {
            show(alert: error)
        }
    }

    func focus(on date: Date) {
        self.focus = date
        refocus(on: date)
    }

    func toggle(visible: Bool) {
        showAllTasks = visible        
        refocus(on: self.focus)
    }

    func update(task id: UUID, isExportable: Bool) {
        Task {
            do {
                try await taskManager.update(task: id, isExportable: isExportable)
            } catch (let error) {
                show(alert: error)
            }
        }
    }

    private func refocus(on date: Date) {
        let fromDate = date.startOfWeek() as NSDate
        let toDate = date.endOfWeek() as NSDate
        var clauses = [NSPredicate(format: "completed >= %@ and completed <= %@", fromDate, toDate)]
        if !showAllTasks {
            clauses.append(NSPredicate(format: "isExportable = true"))
        }
        let sorters = [NSSortDescriptor(key: "completed", ascending: true)]
        self.cursor.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: clauses)
        self.cursor.fetchRequest.sortDescriptors = sorters
        reload()
    }

    private func reload() {
        Task {
            do {
                try cursor.performFetch()

                let tasks = (cursor.fetchedObjects ?? []).map { TheTask.init(mo: $0) }
                let days = Dictionary(grouping: tasks, by: { task in Calendar.current.startOfDay(for: task.completed!) })

                var records = [TaskDay]()
                for day in days.keys.sorted(by: { $0 < $1 }) {
                    let tasks = days[day]?
                        .sorted(by: { $0.completed ?? Date.distantPast > $1.completed ?? Date.distantPast })
                        .sorted(by: { $0.isExportable && !$1.isExportable })
                    ?? []
                    let taskDay = TaskDay(id: day, tasks: tasks)
                    records.append(taskDay)
                }
                self.days = records
                self.completedTasks = tasks.count
                self.exportableTasks = tasks.filter { $0.isExportable }.count
            } catch (let error) {
                show(alert: error)
            }
        }
    }

    private func show(alert: Error) {
        log.error("\(alert)")
        self.error = alert
        self.showAlert = true
    }

    struct TaskDay: Identifiable {
        var id: Date
        var tasks: [TheTask]
    }
}

extension WeeklyViewState: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reload()
    }
}
