//
//  EditTaskViewState.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/18/22.
//

import CoreData

@MainActor
final class EditTaskViewState: ObservableObject {

    @Published var claimed = [Tag]()
    @Published var available = [Tag]()

    private var all = [Tag]()

    private var cursor: NSFetchedResultsController<TagMO>

    init() {
        self.cursor = TagManager.shared.cursor()
        self.reload()
    }

    func load(task: TheTask) {
        Task {
            self.claimed = task.tags
                .map { Tag(id: $0.id, name: $0.name, isSelected: false) }
                .sorted(using: KeyPathComparator(\.name))
            self.available = all.filter { !self.claimed.contains($0) }
        }
    }

    func claim() {

        var claimed = Set<Tag>(self.claimed)

        let tags = self.available
            .filter { $0.isSelected }

        for tag in tags {
            claimed.insert(tag.unselect())
        }

        self.claimed = Array(claimed).sorted(using: KeyPathComparator(\.name))
        self.available = self.all.filter { !claimed.contains($0) }.map { $0.unselect() }
    }

    func unclaim() {
        let moved = self.claimed.filter { $0.isSelected }.map { $0.unselect() }
        self.claimed = self.claimed.filter { !$0.isSelected }
        let avail = Set<Tag>(self.available + moved)
        self.available = Array(avail).sorted(using: KeyPathComparator(\.name))
    }

    /// Return the claimed tags in a format suitable for updating a task object.
    func tags() -> [TagManager.Tag] {
        claimed.map { TagManager.Tag(id: $0.id, name: $0.name) }
    }

    private func reload() {
        Task {
            do {
                try cursor.performFetch()
                let managed = cursor.fetchedObjects ?? []
                self.all = managed
                    .map { .init(tagMO: $0) }
                    .sorted(using: KeyPathComparator(\.name))
            } catch {
                print("ERROR: \(error)")
            }
        }
    }

    struct Tag: Identifiable, Hashable {
        var id: UUID
        var name: String
        var isSelected: Bool

        init(tagMO: TagMO) {
            id = tagMO.id
            name = tagMO.name
            isSelected = false
        }

        init(id: Tag.ID, name: String, isSelected: Bool) {
            self.id = id
            self.name = name
            self.isSelected = isSelected
        }

        func select() -> Tag {
            Tag(id: self.id, name: self.name, isSelected: true)
        }

        func unselect() -> Tag {
            Tag(id: self.id, name: self.name, isSelected: false)
        }

        func toggle() -> Tag {
            Tag(id: self.id, name: self.name, isSelected: !self.isSelected)
        }
    }
}
