//
//  TaskMO+CoreDataProperties.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//
//

import Foundation
import CoreData


extension TaskMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskMO> {
        return NSFetchRequest<TaskMO>(entityName: "TaskMO")
    }

    @NSManaged public var id: UUID
    @NSManaged public var task: String
    @NSManaged public var created: Date
    @NSManaged public var completed: Date?
    @NSManaged public var status: String

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
