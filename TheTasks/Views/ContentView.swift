//
//  ContentView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var state: AppViewState

    @State private var defaultActive = true

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Browse")) {
                        NavigationLink(isActive: $defaultActive) {
                            DetailView()
                        } label: {
                            Label("Today", systemImage: "clock")
                        }

                        NavigationLink {
                            VStack {
                                Text("Not implemented")
                            }
                        } label: {
                            Label("This Week", systemImage: "calendar")
                        }

                        NavigationLink {
                            VStack {
                                Text("Not implemented")
                            }
                        } label: {
                            Label("Last Week", systemImage: "calendar")
                        }
                    }
                }
                .listStyle(.sidebar)
                .toolbar {
                    Button {
                        toggleSidebar()
                    } label: {
                        Image(systemName: "sidebar.left")
                    }
                }
            }
            .frame(minWidth: 180, idealWidth: 180)
        }
    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppViewState())
            .frame(width: 800, height: 600)
    }
}
