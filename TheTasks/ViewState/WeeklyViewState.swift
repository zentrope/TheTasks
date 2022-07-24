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

    // State
    @Published var days = [TaskDay]()
    @Published var focus = Date()

    // Status
    @Published var completedTasks = 0
    @Published var exportableTasks = 0

    // Reporting
    @Published var error: Error?
    @Published var showAlert = false

    // Implementation state
    private var cursor: NSFetchedResultsController<TaskMO>
    private var showAllTasks = true
    private var showMostRecentFirst = true

    override init() {
        self.cursor = TaskManager.shared.cursor()
        super.init()
        self.cursor.delegate = self

        self.showAllTasks = UserDefaults.standard.bool(forKey: "showAllTasks", ifNew: true)
        self.showMostRecentFirst = UserDefaults.standard.bool(forKey: "showMostRecentFirst", ifNew: true)

        self.refocus(on: self.focus)
        self.reload()
    }

    func exportWeek() {
        let tasks = days
            .reduce([], {$0 + $1.tasks})
            .filter { $0.isExportable }
        export(tasks: tasks, qualifier: "Work Week")
    }

    func exportAll() {
        let cursor = TaskManager.shared.cursor()
        cursor.fetchRequest.predicate = NSPredicate(format: "status = 'completed' && isExportable = true")
        cursor.fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "completed", ascending: false)]
        do {
            try cursor.performFetch()
            let tasks = (cursor.fetchedObjects ?? []).map { TheTask(mo: $0) }
            export(tasks: tasks, qualifier: "All as of")
        } catch (let error) {
            show(alert: error)
        }
    }

    private func export(tasks: [TheTask], qualifier: String) {
        let columns = ["id", "task", "created", "completed", "tags"]
            .joined(separator: ",")

        func row(_ task: TheTask) -> String {
            let row = [
                task.id.uuidString.lowercased(),
                task.task.quoted,
                task.created.iso8601,
                task.completed?.iso8601 ?? "-",
                task.tags.map { $0.name }.joined(separator: "; ")]
                .joined(separator: #"",""#)
            return #""\#(row)""#
        }

        let rows = tasks .map { row($0) }
        let text = ([columns] + rows).joined(separator: "\n")

        do {
            let timestamp = focus.endOfWeek().exportMonthYearWeekString
            let filename = "Task Inventory \(qualifier) \(timestamp)"
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
        self.showAllTasks = visible
        refocus(on: self.focus)
    }

    func resort(mostRecentFirst: Bool) {
        self.days = [] // This seems to help the SwiftUI List view do the right thing at the cost of a little flicker.
        self.showMostRecentFirst = mostRecentFirst
        refocus(on: self.focus)
    }

    func update(task id: UUID, isExportable: Bool) {
        Task {
            do {
                try await TaskManager.shared.update(task: id, isExportable: isExportable)
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
        let sorters = [
            NSSortDescriptor(key: "completed", ascending: true)
        ]
        self.cursor.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: clauses)
        self.cursor.fetchRequest.sortDescriptors = sorters
        reload()
    }

    private func reload() {

        Task {
            do {
                try cursor.performFetch()

                let tasks = (cursor.fetchedObjects ?? []).map { TheTask.init(mo: $0) }

                var records = [TaskDay]()

                let stamps = self.focus.weeklyStarts.sorted(by: { if showMostRecentFirst { return $0 < $1 } else { return $1 < $0 }})

                for stamp in stamps {
                    let tasks = tasks.filter { stamp.onSameDay(as: $0.completed) }
                    let taskDay = TaskDay(id: stamp, tasks: tasks)
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
        var id: Int
        var date: Date
        var tasks: [TheTask]

        init(id: Date, tasks: [TheTask]) {
            self.id = Calendar.current.dateComponents([.day], from: id).day ?? 0
            self.date = id
            self.tasks = tasks
        }
    }
}

extension WeeklyViewState: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reload()
    }
}
