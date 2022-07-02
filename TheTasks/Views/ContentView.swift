//
//  ContentView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import SwiftUI

// The "new task" menu item tells AppViewState which enum to use, so we can switch to the right view. But that view will be the detail view, which won't exist (if we ditch global state), so how will it know to create a new task? The alternative is to allow for creating new tasks via a modal when not showing the daily view. Handler: if activeView == .today, then send the create task notification (I guess), otherwise create the modal. Something like that? Hm. Forcing the view to switch to Today when looking at another view is not good. So, modal it is.

enum ActiveView {
    case today
    case thisWeek
    case lastWeek
}

struct ContentView: View {

    @State private var activeView: ActiveView? = ActiveView.today

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Browse")) {
                        NavigationLink(destination: DailyView().frame(minWidth: 350), tag: ActiveView.today, selection: $activeView) {
                            Label("Today", systemImage: "clock")
                        }

                        NavigationLink(destination: WeeklyView(date: Date()).frame(minWidth: 350), tag: ActiveView.thisWeek, selection: $activeView) {
                            Label("This Week", systemImage: "calendar")
                        }

                        NavigationLink(destination: WeeklyView(date: Date().lastWeek()).frame(minWidth: 350), tag: ActiveView.lastWeek, selection: $activeView) {
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
