//
//  TheTasksApp.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import SwiftUI
import OSLog

fileprivate let log = Logger("TheTasksApp")

@main
struct TheTasksApp: App {

    @StateObject private var state = AppViewState()

    @AppStorage("showBadge") var showBadge = true

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(state)
                .frame(minWidth: 500, idealWidth: 500, maxWidth: .infinity, minHeight: 400, idealHeight: 400, maxHeight: .infinity)
                .task {
                    BadgeManager.shared.showBadge = showBadge
                }
                .onChange(of: showBadge) { updatedShowBadgeToggle in
                    BadgeManager.shared.showBadge = updatedShowBadgeToggle
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
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
