//
//  ContentView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import SwiftUI
import UniformTypeIdentifiers
// The "new task" menu item tells AppViewState which enum to use, so we can switch to the right view. But that view will be the detail view, which won't exist (if we ditch global state), so how will it know to create a new task? The alternative is to allow for creating new tasks via a modal when not showing the daily view. Handler: if activeView == .today, then send the create task notification (I guess), otherwise create the modal. Something like that? Hm. Forcing the view to switch to Today when looking at another view is not good. So, modal it is.

struct ContentView: View {

    @StateObject private var state = NavViewState()

    @FocusState private var tagFocus: NavViewState.FocusTag?

    @State private var dropFocus = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Browse")) {
                        NavigationLink(destination: AvailableView().frame(minWidth: 350), tag: NavViewState.CurrentView.available, selection: $state.activeView) {
                            Label("Available", systemImage: "clock")
                        }

                        NavigationLink(destination: WeeklyView(date: Date()).frame(minWidth: 350), tag: NavViewState.CurrentView.thisWeek, selection: $state.activeView) {
                            Label("This Week", systemImage: "calendar")
                        }

                        NavigationLink(destination: WeeklyView(date: Date().lastWeek()).frame(minWidth: 350), tag: NavViewState.CurrentView.lastWeek, selection: $state.activeView) {
                            Label("Last Week", systemImage: "calendar")
                        }
                    }

                    Section(header: Text("Context")) {
                        ForEach($state.tags, id: \.id) { $tag in
                            // Note: HStack is required here so that onDrag and contextMenu are on separate elements, otherwise one will cancel out the other.
                            HStack {
                                EditableTag(tag: $tag) { state.rename(tag: tag, name: $0) }
                                    .onDrag { NSItemProvider(object: tag.draggable())}
                            }
                            .contextMenu {
                                Button(#"Rename "\#(tag.name)""#) { tag.toggleEditMode() }
                                Button("Delete") { state.delete(tag: tag) }
                            }
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
                Spacer()
                HStack {
                    Button {
                        state.makeNewTask()
                    } label: {
                        Label("New tag", systemImage: "plus.circle")
                    }
                    .buttonStyle(.borderless)
                    Spacer()
                }
                .padding()

                .alert(state.error?.localizedDescription ?? "Error", isPresented: $state.showAlert) {}
            }
            .frame(minWidth: 180, idealWidth: 180)

            Text("Pick a view")
        }
    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 800, height: 600)
    }
}
