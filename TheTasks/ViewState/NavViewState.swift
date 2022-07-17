//
//  NavViewState.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/8/22.
//

import Combine
import CoreData
import OSLog

fileprivate let log = Logger("NavigationViewState")

@MainActor
class NavViewState: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

    @Published var activeView: CurrentView? = .available
    @Published var tags = [TagManager.Tag]()

    @Published var error: Error?
    @Published var showAlert = false

    private var subscriptions = Set<AnyCancellable>()
    private var cursor: NSFetchedResultsController<TagMO>

    override init() {
        cursor = TagManager.shared.cursor()

        super.init()

        cursor.delegate = self
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

    func makeNewTask() {
        Task {
            do {
                try await TagManager.shared.insertNew()
            } catch (let error) {
                show(alert: error)
            }
        }
    }

    func rename(tag: TagManager.Tag, name: String) {
        Task {
            do {
                try await TagManager.shared.rename(tag: tag, name: name.trimmingCharacters(in: .whitespacesAndNewlines))
            } catch (let error) {
                show(alert: error)
            }
        }
    }

    func delete(tag: TagManager.Tag) {
        Task {
            do {
                try await TagManager.shared.delete(tag: tag)
            } catch (let error) {
                show(alert: error)
            }
        }
    }

    private func reload() {
        Task {
            do {
                try cursor.performFetch()
                let tags = ( cursor.fetchedObjects ?? [] ).map { TagManager.Tag(mo: $0) }
                self.tags = tags
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

    internal nonisolated func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Task { await reload() }
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
