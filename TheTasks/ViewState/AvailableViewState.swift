//
//  AvailableViewState.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import CoreData
import OSLog

fileprivate let log = Logger("AvailableViewState")

@MainActor
final class AvailableViewState: NSObject, ObservableObject { // NSObject required for use as a delegate

    typealias Tag = TagManager.Tag

    // MARK: - Publishers

    @Published var tasks = [TheTask]()
    @Published var showAlert = false
    @Published var error: Error?

    // Filters

    @Published var viewFilter = TaskViewFilter(tags: [], rule: .or, completed: .today)

    // MARK: - Local State

    private var cursor: NSFetchedResultsController<TaskMO>

    // If a tag is re-named, we want to refresh the display. This will also refresh the display if tags are added or removed, but it's rare enough that I don't think it's necessary to refine.
    private var tagCursor: NSFetchedResultsController<TagMO>

    override init() {
        self.cursor = TaskManager.shared.cursor()
        self.tagCursor = TagManager.shared.cursor()
        super.init()
        self.cursor.delegate = self
        self.tagCursor.delegate = self

        // Do an initial request to load the cursor so we can get change notifications
        try? tagCursor.performFetch()

        self.cursor.fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "created", ascending: false)
        ]

        processFilter()
    }
}

// MARK: - Public API

extension AvailableViewState {

    private func doTask(_ handler: @escaping () async throws -> Void) {
        Task {
            do {
                try await handler()
            } catch (let error) {
                showAlert(error)
            }
        }
    }

    func processFilter() {
        cursor.fetchRequest.predicate = self.viewFilter.predicate()
        reload()
    }

    /// Remove a tag from the task.
    func add(tag: TagManager.Tag, to task: TheTask) {
        doTask { try await TaskManager.shared.add(tag: tag, to: task) }
    }

    /// Add a tag to the task.
    func remove(tag: TagManager.Tag, from task: TheTask) {
        doTask { try await TaskManager.shared.remove(tag: tag, from: task) }
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
                showAlert(error)
            }
        }
    }

    /// Delete a task
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

extension AvailableViewState {

    private func reload() {
        Task {
            do {
                try cursor.performFetch()
                let tasks = cursor.fetchedObjects ?? []
                self.tasks = tasks.map { .init(mo: $0) }
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
}

// MARK: - Fetched Results Delegate

extension AvailableViewState: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reload()
    }
}
