//
//  TaskMO+CoreDataProperties.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/8/22.
//
//

import Foundation
import CoreData


extension TaskMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskMO> {
        return NSFetchRequest<TaskMO>(entityName: "TaskMO")
    }

    @NSManaged public var completed: Date?
    @NSManaged public var created: Date
    @NSManaged public var id: UUID
    @NSManaged public var isExportable: Bool
    @NSManaged public var status: String
    @NSManaged public var task: String
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for tags
extension TaskMO {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: TagMO)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: TagMO)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}

extension TaskMO : Identifiable {

    var taskStatus: TaskStatus {
        TaskStatus(rawValue: status) ?? .pending
    }

    enum TaskStatus: String {
        case pending = "pending"
        case cancelled = "cancelled"
        case completed = "completed"
    }
}
