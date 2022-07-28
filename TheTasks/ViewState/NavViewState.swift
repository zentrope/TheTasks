//
//  NavViewState.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/8/22.
//

import Combine
import CoreData
import OSLog

fileprivate let log = Logger("NavViewState")

@MainActor
class NavViewState: NSObject, ObservableObject {

    @Published var activeView: CurrentView? = .available
    @Published var tags = [TagManager.Tag]()

    @Published var error: Error?
    @Published var showAlert = false

    private var subscriptions = Set<AnyCancellable>()
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
        NotificationCenter.default.publisher(for: .appNavigateToView)
            .removeDuplicates()
            .sink { value in
                if let view = value.userInfo?["view"] as? CurrentView {
                    self.activeView = view
                }
            }
            .store(in: &subscriptions)
    }

    deinit {
        subscriptions.forEach { $0.cancel() }
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

    enum CurrentView: Hashable {
        case available
        case thisWeek
        case lastWeek

        // Not needed for MacOS 13 and iOS 16
        case tag(TagManager.Tag)
    }

    /// A value for managing the selected tag and setting focus when it's in edit mode.
    enum FocusTag: Hashable {
        case none
        case tag(TagManager.Tag.ID)
    }
}

extension NavViewState: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reload()
    }
}
