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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(state)
                .frame(minWidth: 500, idealWidth: 500, maxWidth: .infinity, minHeight: 400, idealHeight: 400, maxHeight: .infinity)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            SidebarCommands()
            CommandGroup(after: .newItem) {
                Button("New Task") { state.createNewTask() }
                    .keyboardShortcut("n", modifiers: [.command, .option])
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()
