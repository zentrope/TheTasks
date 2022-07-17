//
//  NSManagedObjectContext.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/8/22.
//

import CoreData

extension NSManagedObjectContext {

    func commit() throws {
        if hasChanges {
            try save()
        }
    }
}
