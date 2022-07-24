//
//  TagPickerViewState.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/23/22.
//

import CoreData
import OSLog

fileprivate let log = Logger("TagPickerViewState")

@MainActor
final class TagPickerViewState: ObservableObject {

    @Published var tags = [Tag]()
    @Published var showAlert = false
    @Published var error: Error?

    private var cursor: NSFetchedResultsController<TagMO>

    init() {
        cursor = TagManager.shared.cursor()
        load()
    }

    func selected() -> [TagManager.Tag] {
        self.tags.filter { $0.isSelected }.map { TagManager.Tag(id: $0.id, name: $0.name)}
    }

    func preselect(tags: [TagManager.Tag]) {
        let ids = Set<TagManager.Tag.ID>(tags.map { $0.id })
        for (index, tag) in self.tags.enumerated() {
            self.tags[index].isSelected = ids.contains(tag.id)
        }
    }

    private func load() {
        do {
            try cursor.performFetch()
            let taskMOs = cursor.fetchedObjects ?? []
            let tags = taskMOs.map { Tag(tagMO: $0) }
                .sorted(using: KeyPathComparator(\.taskCount, order: .reverse))
            self.tags = tags
        } catch (let error) {
            show(alert: error)
        }
    }

    private func show(alert: Error) {
        self.showAlert = true
        self.error = alert
        log.error("\(alert)")
    }

    struct Tag: Identifiable, Equatable {
        var id: UUID
        var name: String
        var taskCount: Int
        var isSelected: Bool

        init(tagMO: TagMO) {
            self.id = tagMO.id
            self.name = tagMO.name
            self.isSelected = false
            self.taskCount = (tagMO.tasks ?? []).count
        }
    }

}
