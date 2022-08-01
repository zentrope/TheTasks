//
//  TheTasksApp.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import SwiftUI
import OSLog

fileprivate let log = Logger("TheTasksApp")

let APP_MIN_DETAIL_WIDTH = CGFloat(350)

@main
struct TheTasksApp: App {

    @AppStorage("showBadge") private var showBadge = true

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    BadgeManager.shared.showBadge = showBadge
                }
                .onChange(of: showBadge) { updatedShowBadgeToggle in
                    BadgeManager.shared.showBadge = updatedShowBadgeToggle
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            SidebarCommands()

            // File menu
            CommandGroup(after: .newItem) {
                Button("New Task") {
                    // TODO: Find a way to have this invoke the appropriate form, maybe right here.
                }
                .keyboardShortcut("n", modifiers: [.command, .option])
                .disabled(true)
            }

            // View menu
            CommandGroup(before: .sidebar) {

                Button("Available") {
                    NotificationCenter.default.navigateTo(view: .available)
                }
                .keyboardShortcut("1", modifiers: [.command])

                Button("This Week") {
                    NotificationCenter.default.navigateTo(view: .thisWeek)
                }
                .keyboardShortcut("2", modifiers: [.command])

                Button("Last Week") {
                    NotificationCenter.default.navigateTo(view: .lastWeek)
                }
                .keyboardShortcut("3", modifiers: [.command])

                Divider()
            }
        }

        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
