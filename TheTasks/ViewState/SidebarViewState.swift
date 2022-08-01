//
//  SidebarViewState.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/8/22.
//

//import Combine
import CoreData
import OSLog

fileprivate let log = Logger("NavViewState")

@MainActor
class SidebarViewState: NSObject, ObservableObject {

    @Published var tags = [TagManager.Tag]()

    @Published var error: Error?
    @Published var showAlert = false

    private var cursor: NSFetchedResultsController<TagMO>
    private var taskCursor: NSFetchedResultsController<TaskMO>

    override init() {
        cursor = TagManager.shared.cursor()
        taskCursor = TaskManager.shared.cursor()

        super.init()

        cursor.delegate = self
        taskCursor.delegate = self
        taskCursor.fetchRequest.predicate = nil // everything
        try? taskCursor.performFetch() // initial request

        reload()
    }

    func upsert(tag: TagManager.Tag) {
        withTransaction {
            try await TagManager.shared.upsert(tag: tag)
        }
    }

    func delete(tag: TagManager.Tag) {
        withTransaction {
            try await TagManager.shared.delete(tag: tag)
        }
    }

    private func reload() {
        withTransaction {
            try self.cursor.performFetch()
            let tags = ( self.cursor.fetchedObjects ?? [] ).map { TagManager.Tag(mo: $0) }
            self.tags = tags.sorted(using: KeyPathComparator(\.totalTasks, order: .reverse))
        }
    }

    private func withTransaction(block: @escaping () async throws -> Void) {
        Task {
            do {
                try await block()
            } catch (let error) {
                show(alert: error)
            }
        }
    }

    private func show(alert: Error) {
        log.debug("\(alert.localizedDescription)")
        self.error = alert
        self.showAlert = true
    }

    enum CurrentView: Hashable, Codable {
        case available
        case thisWeek
        case lastWeek
    }
}

extension SidebarViewState: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reload()
    }
}
