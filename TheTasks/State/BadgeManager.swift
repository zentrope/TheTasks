//
//  BadgeManager.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/3/22.
//

import Cocoa
import CoreData
import Foundation
import UserNotifications
import OSLog

fileprivate let log = Logger("BadgeManager")

@MainActor
class BadgeManager: NSObject, NSFetchedResultsControllerDelegate {

    static let shared = BadgeManager()

    private var cursor: NSFetchedResultsController<TaskMO>

    override init() {

        self.cursor = TheTaskManager.shared.taskCursor()
        self.cursor.fetchRequest.predicate = NSPredicate(format: "status = 'pending'")

        super.init()
        self.cursor.delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.badge]) { success, error in
            log.debug("Requesting authorization for badge access.")
            if success {
                log.debug("Authorization for badge access granted.")
            } else if let error = error {
                log.error("Unable to get authorization for badge access: \(String(describing: error.localizedDescription))")
            }
        }
    }

    func update() {
        do {
            try cursor.performFetch()
            let pending = cursor.fetchedObjects?.count ?? 0
            if pending == 0 {
                log.debug("No pending tasks, removing app icon badge.")
            } else {
                log.debug("Updating app icon badge: \(String(describing: pending)).")
                NSApp.dockTile.badgeLabel = pending == 0 ? "" : "\(pending)"
            }
        } catch (let error) {
            print("Error: \(error)")
        }
    }

    nonisolated func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Task {
            await update()
        }
    }
}
