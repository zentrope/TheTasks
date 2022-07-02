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
    @Published var focusDate = Date()
    @Published var showAlert = false
    @Published var error: Error?

    @Published var selectedTask: TheTask.ID?
    @Published var focusedTask: FocusTask?

    @Published var cancelledTasks = 0
    @Published var completedTasks = 0
    @Published var totalTasks = 0
    @Published var pendingTasks = 0

    // MARK: - Local State

    private var cursor: NSFetchedResultsController<TaskMO>
    private var taskManager: TheTaskManager
    private var subscribers = Set<AnyCancellable>()

    override init() {
        self.taskManager = TheTaskManager(controller: PersistenceController.shared)
        self.cursor = taskManager.taskCursor()
        super.init()
        self.cursor.delegate = self

        self.$focusDate
            .removeDuplicates()
            .sink { [weak self] newDate in
                self?.refocusTasks(on: newDate)
            }

            .store(in: &subscribers)
        self.gotoToday()
        self.reload()
    }
}

// MARK: - Public API

extension AppViewState {

    var isFocusedOnToday: Bool {
        Calendar.current.isDateInToday(focusDate)
    }

    func gotoToday() {
        focusDate = Calendar.current.startOfDay(for: Date())
    }

    func goBackOneDay() {
        let current = Calendar.current.startOfDay(for: self.focusDate)
        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: current) {
            self.focusDate = yesterday
        }
    }

    func goForwardOneDay() {
        if isFocusedOnToday {
            return
        }
        let current = Calendar.current.startOfDay(for: self.focusDate)
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: current) {
            self.focusDate = tomorrow
        }
    }

    func update(task id: UUID, name: String) {
        Task {
            do {
                try await taskManager.update(task: id, description: name)
            } catch (let error) {
                showAlert(error)
            }
        }
    }

    func update(task id: UUID, status: TaskMO.TaskStatus) {
        Task {
            do {
                let date = status == .pending ? nil : Date()
                try await taskManager.update(task: id, status: status.rawValue, completed: date)
            } catch (let error) {
                showAlert(error)
            }
        }
    }

    func delete(task id: UUID) {
        Task {
            do {
                try await taskManager.delete(task: id)
            } catch (let error) {
                showAlert(error)
            }
        }
    }

    func createNewTask() {
        let newTask = TheTask(newTask: "New task")
        if !isFocusedOnToday {
            // You can create a new task whenever you want, but always make sure "Today" is visible before adding it to the list of today's task list.
            Task {
                self.gotoToday()
            }
        }
        Task {
            do {
                try await self.taskManager.insert(task: newTask)

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

                self.totalTasks = try taskManager.numberOfTasks()
                self.completedTasks = try taskManager.numberOfTasks(withStatus: .completed)
                self.pendingTasks = try taskManager.numberOfTasks(withStatus: .pending)
                self.cancelledTasks = try taskManager.numberOfTasks(withStatus:.cancelled)

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

    private func refocusTasks(on date: Date) {
        let fromDate = Calendar.current.startOfDay(for: date)
        let toDate = Calendar.current.date(byAdding: .day, value: 1, to: fromDate)!

        if Calendar.current.isDateInToday(date) {
            self.cursor.fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "status == 'pending'"),
                NSPredicate(format: "completed >= %@ and completed <= %@", fromDate as NSDate, toDate as NSDate)
            ])

            self.cursor.fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "status", ascending:  false),
                NSSortDescriptor(key: "created", ascending: true)
            ]
        } else {
            self.cursor.fetchRequest.predicate = NSPredicate(format: "completed >= %@ and completed <= %@", fromDate as NSDate, toDate as NSDate)

            self.cursor.fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "completed", ascending: true)
            ]
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
