//
//  AppViewState.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import Combine
import CoreData
import Foundation
import OSLog

fileprivate let log = Logger("AppViewState")

enum FocusTask: Hashable {
    case none
    case task(TheTask.ID)
}

@MainActor
final class AppViewState: NSObject, ObservableObject { // NSObject required for use as a delegate

    // MARK: - Publishers

    @Published var tasks = [TheTask]()
    @Published var showAlert = false
    @Published var error: Error?

    // Filters

    @Published var showCompleted = true {
        didSet {
            refilter()
        }
    }

    @Published var showToday = true {
        didSet {
            refilter()
        }
    }

    @Published var selectedTask: TheTask.ID?
    @Published var focusedTask: FocusTask?

    // TODO: Make this a struct
    @Published var cancelledTasks = 0
    @Published var completedTasks = 0
    @Published var totalTasks = 0
    @Published var pendingTasks = 0

    // MARK: - Local State

    private var cursor: NSFetchedResultsController<TaskMO>
    private var subscribers = Set<AnyCancellable>()

    override init() {
        self.cursor = TaskManager.shared.taskCursor()
        super.init()
        self.cursor.delegate = self

        self.cursor.fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "created", ascending: false)
        ]
        self.refilter()
    }
}

// MARK: - Public API

extension AppViewState {

    private func doTask(_ handler: @escaping () async throws -> Void) {
        Task {
            do {
                try await handler()
            } catch (let error) {
                showAlert(error)
            }
        }
    }

    func add(tag: TagManager.Tag, to task: TheTask) {
        doTask { try await TaskManager.shared.add(tag: tag, to: task) }
    }

    func remove(tag: TagManager.Tag, from task: TheTask) {
        doTask { try await TaskManager.shared.remove(tag: tag, from: task) }
    }

    /// Update a task's name.
    func update(task id: UUID, name: String) {
        Task {
            do {
                try await TaskManager.shared.update(task: id, description: name)
            } catch (let error) {
                showAlert(error)
            }
        }
    }

    /// Update a tasks's status.
    func update(task id: UUID, status: TaskMO.TaskStatus) {
        Task {
            do {
                let date = status == .pending ? nil : Date()
                try await TaskManager.shared.update(task: id, status: status.rawValue, completed: date)
            } catch (let error) {
                showAlert(error)
            }
        }
    }

    /// Upsert (create or update) a task
    func upsert(task: TheTask) {
        Task {
            do {
                try await TaskManager.shared.upsert(task: task)
            } catch {
                print("ERROR: \(error)")
            }
        }
    }

    func delete(task id: UUID) {
        Task {
            do {
                try await TaskManager.shared.delete(task: id)
            } catch (let error) {
                showAlert(error)
            }
        }
    }
}

// MARK: - Implementation details

extension AppViewState {

    private func reload() {
        Task {
            do {
                try cursor.performFetch()
                let tasks = cursor.fetchedObjects ?? []
                self.tasks = tasks.map { .init(mo: $0) }

                self.totalTasks = try TaskManager.shared.numberOfTasks()
                self.completedTasks = try TaskManager.shared.numberOfTasks(withStatus: .completed)
                self.pendingTasks = try TaskManager.shared.numberOfTasks(withStatus: .pending)
                self.cancelledTasks = try TaskManager.shared.numberOfTasks(withStatus:.cancelled)

            }
            catch (let error) {
                showAlert(error)
            }
        }
    }

    private func showAlert(_ error: Error) {
        log.error("\(error)")
        self.error = error
        self.showAlert = true
    }

    private func refilter() {
        let fromDate = Calendar.current.startOfDay(for: Date())
        let toDate = Calendar.current.date(byAdding: .day, value: 1, to: fromDate)!

        let completedToday = NSPredicate(format: "completed >= %@ and completed <= %@", fromDate as NSDate, toDate as NSDate)
        let available = NSPredicate(format: "status == 'pending'")

        if !showToday {
            cursor.fetchRequest.predicate = nil
        } else if showCompleted {
            cursor.fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [completedToday, available])
        } else {
            cursor.fetchRequest.predicate = available
        }

        reload()
    }
}

// MARK: - Fetched Results Delegate

extension AppViewState: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reload()
    }
}
