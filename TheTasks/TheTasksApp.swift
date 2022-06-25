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
                .toolbar {

                    ToolbarItemGroup(placement: .navigation) {
                        Button(action: { toggleSidebar() }, label: { Image(systemName: "sidebar.left")})
                        Button(action: { state.createNewTask() }, label: { Image(systemName: "plus") })
                    }

                    ToolbarItem {
                        Spacer()
                    }

                    ToolbarItemGroup {
                        ControlGroup {
                            Button(action: { state.goBackOneDay() }, label: { Image(systemName: "chevron.backward") })
                                .help("Show yesterday's tasks")

                            Button("Today", action: { state.gotoToday() })
                                .help("Show today's tasks")

                            Button(action: { state.goForwardOneDay() }, label: { Image(systemName: "chevron.forward") })
                                .help("Show tomorrow's tasks")
                                .disabled(state.isFocusedOnToday)
                        }
                    }
                }
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

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()
