//
//  TagManager.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/8/22.
//

import Foundation
import CoreData
import OSLog
import UniformTypeIdentifiers

fileprivate let log = Logger("TagManager")

struct TagManager {

    static var shared = TagManager(controller: PersistenceController.shared)

    private var controller: PersistenceController

    private init(controller: PersistenceController) {
        self.controller = controller
    }

    @discardableResult
    func insertNew() async throws -> TagManager.Tag? {
        let context = controller.newBackgroundContext()
        let id = UUID()
        var returnTag: TagManager.Tag?
        try await context.perform {
            var index = 1

            var name = "New Tag"
            var done = false

            while !done {
                do {
                    let _ = try find(name: name, context: context)
                    name = "New Tag \(index)"
                    index += 1
                    continue
                } catch {
                    let tagMO = TagMO(context: context)
                    tagMO.id = id
                    tagMO.name = name
                    returnTag = TagManager.Tag(mo: tagMO)
                    done = true
                }
            }

            try context.commit()
        }
        return returnTag
    }

    func insert(tag: Tag) async throws {
        log.debug("Inserting tag: \(String(describing: tag))")
        let context = controller.newBackgroundContext()
        try await context.perform {
            let tagMO = TagMO(context: context)
            tagMO.id = tag.id
            tagMO.name = tag.name
            try context.commit()
        }
    }

    func delete(tag: Tag) async throws {
        let context = controller.newBackgroundContext()
        try await context.perform {
            let tagMO = try find(id: tag.id, context: context)
            context.delete(tagMO)
            try context.commit()
        }
    }

    func rename(tag: Tag, name: String) async throws {
        let context = controller.newBackgroundContext()
        try await context.perform {
            if isDuplicate(name: name, context: context) {
                throw PersistenceError.tagAlreadyUsed
            }

            let tagMO = try find(id: tag.id, context: context)
            tagMO.name = name
            try context.commit()
        }
    }

    func cursor() -> NSFetchedResultsController<TagMO> {
        let request = TagMO.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: controller.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }

    private func isDuplicate(name: String, context: NSManagedObjectContext) -> Bool {
        do {
            let _ = try find(name: name, context: context)
            return true
        } catch {
            return false
        }
    }

    private func find(name: String, context: NSManagedObjectContext) throws -> TagMO {
        let request = TagMO.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[c] %@", name as CVarArg)
        if let tag = try context.fetch(request).first {
            return tag
        }
        throw PersistenceError.tagNotFound
    }

    func find(id: TaskMO.ID, context: NSManagedObjectContext) throws -> TagMO {
        let request = TagMO.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        if let tag = try context.fetch(request).first {
            return tag
        }
        throw PersistenceError.tagNotFound
    }
}

// MARK: - UI Related Tag Types

extension TagManager {

    // A SwiftUI presentation friendly view of a tag

    struct Tag: Identifiable, Codable, Hashable {

        var id: UUID
        var name: String

        /// Set to true to indicate that the presentation UI should allow this tag to be edited.
        var isEditable = false


        /// Create a new tag with the given name.
        init(name: String) {
            self.id = UUID()
            self.name = name
        }

        /// Create a tag based on the value of the managaged object retrieved from the data store.
        init(mo: TagMO) {
            self.id = mo.id
            self.name = mo.name
        }

        /// Toggle the current editing mode, indicating that the UI should allow the tag to be edited.
        mutating func toggleEditMode() {
            isEditable.toggle()
        }

        func draggable() -> Draggable {
            Draggable(self)
        }
    }

    /// MACOS13: Used to allow for NSItemProvider -- remove when Transferable is available. An alternative to this might be to create a custom UTType (info.plist), make it conform to utf8 text, then see if we can drag plain text to the drop target. What does conformance actually mean?
    class Draggable: NSObject, Codable, NSItemProviderReading, NSItemProviderWriting {

        var tag: Tag

        init(_ tag: Tag) {
            self.tag = tag
        }

        static var writableTypeIdentifiersForItemProvider: [String] { [UTType.tag.identifier] }
        static var readableTypeIdentifiersForItemProvider: [String] { [UTType.tag.identifier] }

        static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
            let decoder = JSONDecoder()
            do {
                return try decoder.decode(Draggable.self, from: data) as! Self
            } catch {
                // TODO: This sucks, but will fix when we can move to the Transferable protocol with Macos13.
                fatalError("Error: \(error)")
            }
        }

        func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {

            let progress = Progress(totalUnitCount: 100)

            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(self)
                completionHandler(data, nil)
            } catch {
                completionHandler(nil, error)
            }
            return progress
        }
    }

}
