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

    @Published var showAll = false {
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

    func delete(task id: UUID) {
        Task {
            do {
                try await TaskManager.shared.delete(task: id)
            } catch (let error) {
                showAlert(error)
            }
        }
    }

    func createNewTask() {
        let newTask = TheTask(newTask: "New task")
        Task {
            do {
                try await TaskManager.shared.insert(task: newTask)

                Task {
                    // Hack: Scheduling this update seems to keep the database update from interfering with selection, or something like that. This occurs after "reload()" triggered by the previous insert. If we do this without a delay, the reload seems to clobber the selection. Guess: this updates the main actor so it is suspended until the previous task is completed due to actor serialization. Guessing that when you call a main-actor method from within the actor, the call is not serialized.
                    selectedTask = newTask.id
                    focusedTask = .task(newTask.id)
                }
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

        if showAll {
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
