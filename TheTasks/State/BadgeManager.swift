//
//  BadgeManager.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/3/22.
//

import Cocoa
import CoreData
import UserNotifications
import OSLog

fileprivate let log = Logger("BadgeManager")

@MainActor
class BadgeManager: NSObject, NSFetchedResultsControllerDelegate {

    static let shared = BadgeManager()

    private var cursor: NSFetchedResultsController<TaskMO>

    /// Show or don't show the number of pending tasks on the application icon's badge. Setting this value on application start will trigger an update.
    var showBadge = false {
        didSet {
            update()
        }
    }

    private override init() {

        self.cursor = TaskManager.shared.taskCursor()
        self.cursor.fetchRequest.predicate = NSPredicate(format: "status = 'pending'")

        super.init()
        self.cursor.delegate = self

        self.requestBadgeNotifications()
    }

    private func update() {
        guard showBadge else {
            log.debug("Hiding badge at user's request in settings.")
            NSApp.dockTile.badgeLabel = ""
            return
        }

        do {
            try cursor.performFetch()
            let pending = cursor.fetchedObjects?.count ?? 0
            if pending == 0 {
                log.debug("No pending tasks, removing app icon badge.")
                NSApp.dockTile.badgeLabel = ""
            } else {
                log.debug("Updating app icon badge: \(String(describing: pending)).")
                NSApp.dockTile.badgeLabel = "\(pending)"
            }
        } catch (let error) {
            // If this doesn't work, it's not the worst thing in the world, so log it. If there's a way to expose activity to the user without modal alerts (like a logging window), add this message to that.
            log.error("Unable to update dock tile badge: \(error.localizedDescription).")
        }
    }

    // MARK: - Core Data Delegate

    nonisolated func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Task {
            await update()
        }
    }

    // MARK: - User Authorization

    private func requestBadgeNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge]) { success, error in
            log.debug("Requesting authorization for badge access.")
            if success {
                log.debug("Authorization for badge access granted.")
            } else if let error = error {
                log.error("Unable to get authorization for badge access: \(String(describing: error.localizedDescription))")
            }
        }
    }
}
