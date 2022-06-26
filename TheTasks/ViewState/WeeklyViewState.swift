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

    //@Published var tasks = [TheTask]()
    @Published var days = [TaskDay]()
    @Published var focus = Date()
    @Published var completedTasks = 0
    @Published var error: Error?
    @Published var showAlert = false

    private var taskManager: TheTaskManager
    private var cursor: NSFetchedResultsController<TaskMO>

    override init() {
        log.debug("Initializing WeeklyViewState")
        self.taskManager = TheTaskManager(controller: PersistenceController.shared)
        self.cursor = taskManager.taskCursor()
        super.init()
        self.cursor.delegate = self
        self.refocus(on: self.focus)
        self.reload()
    }

    func focus(on date: Date) {
        self.focus = date
        refocus(on: date)
    }

    private func refocus(on date: Date) {
        let fromDate = date.startOfWeek() as NSDate
        let toDate = date.endOfWeek() as NSDate
        let predicate = NSPredicate(format: "completed >= %@ and completed <= %@", fromDate, toDate)
        let sorters = [NSSortDescriptor(key: "completed", ascending: true)]
        self.cursor.fetchRequest.predicate = predicate
        self.cursor.fetchRequest.sortDescriptors = sorters
    }

    private func reload() {
        Task {
            do {
                try cursor.performFetch()

                let tasks = (cursor.fetchedObjects ?? []).map { TheTask.init(mo: $0) }

                let days = Dictionary(grouping: tasks, by: { task in Calendar.current.startOfDay(for: task.completed!) })

                var records = [TaskDay]()
                for day in days.keys.sorted(by: { $0 < $1 }) {
                    let tasks = days[day]?.sorted(by: { $0.completed ?? Date.distantPast > $1.completed ?? Date.distantPast }) ?? []
                    let taskDay = TaskDay(id: day, tasks: tasks)
                    records.append(taskDay)
                }
                self.days = records
                self.completedTasks = tasks.count
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
