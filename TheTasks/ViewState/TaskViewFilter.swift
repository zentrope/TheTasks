//
//  TaskViewFilter.swift
//  TheTasks
//
//  Created by Keith Irwin on 8/6/22.
//

import Foundation

struct TaskViewFilter: Equatable {

    // TODO: Add sort order to TaskViewFilter
    // TODO: Add serilization to TaskViewFilter for saved filter or settings restore

    var tags: [TagManager.Tag]
    var rule: Rule
    var completed: Completed

    enum Completed: String, CaseIterable {
        case hide = "Available"
        case today = "Available and completed today"
        case all = "All"
    }

    enum Rule: String, CaseIterable { // `operator` is reserved in Swift
        case and = "Match all selected"
        case or = "Match any selected"
        case not = "Match all except selected"
    }

    func predicate() -> NSPredicate {
        var coveragePredicate: NSPredicate
        switch self.completed {

            case .today:
                // Show all uncompleted tasks, and those tasks completed today as well.
                let fromDate = Calendar.current.startOfDay(for: Date())
                let toDate = Calendar.current.date(byAdding: .day, value: 1, to: fromDate)!
                coveragePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                    NSPredicate(format: "completed >= %@ and completed <= %@", fromDate as NSDate, toDate as NSDate),
                    NSPredicate(format: "status == 'pending'")
                ])

            case .all:
                // Show all tasks, regardless of date completed or current status
                coveragePredicate = NSPredicate(value: true)

            case .hide:
                // Show uncompleted tasks
                coveragePredicate = NSPredicate(format: "status == 'pending'")
        }

        let tagPredicates = self.tags.map { NSPredicate(format: "subquery(tags, $tag, $tag.name = %@).@count > 0", $0.name) }
        var tagFilterPredicate: NSPredicate
        if tagPredicates.isEmpty {
            tagFilterPredicate = NSPredicate(value: true)
        } else {
            switch self.rule {
                case .and:
                    tagFilterPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: tagPredicates)
                case .or:
                    tagFilterPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: tagPredicates)
                case .not:
                    tagFilterPredicate = NSCompoundPredicate(notPredicateWithSubpredicate: NSCompoundPredicate(orPredicateWithSubpredicates: tagPredicates))
            }
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: [coveragePredicate, tagFilterPredicate])
    }
}
