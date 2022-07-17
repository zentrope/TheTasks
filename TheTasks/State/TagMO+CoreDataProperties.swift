//
//  TagMO+CoreDataProperties.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/8/22.
//
//

import Foundation
import CoreData


extension TagMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TagMO> {
        return NSFetchRequest<TagMO>(entityName: "TagMO")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var tasks: NSSet?

}

// MARK: Generated accessors for tasks
extension TagMO {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: TaskMO)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: TaskMO)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}

extension TagMO : Identifiable {

}
