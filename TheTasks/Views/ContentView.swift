//
//  ContentView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import SwiftUI


struct ContentView: View {

    @State private var selectedItem: SidebarViewState.CurrentView? = .available
    @State private var navState: NavigationSplitViewVisibility = .all

    @AppStorage("NavigationState") private var storedNavigationState: Data?

    var body: some View {
        VStack {
            NavigationSplitView(columnVisibility: $navState) {
                SidebarView(selection: $selectedItem)
                    .navigationSplitViewColumnWidth(min: 180, ideal: 180, max: 220)                    
            } detail: {
                Group {
                    switch selectedItem {
                        case .available:
                            AvailableView()
                        case .thisWeek:
                            WeeklyView(date: Date())
                        case .lastWeek:
                            WeeklyView(date: Date().lastWeek())
                        default:
                            Text("Select View")
                    }
                }
                .frame(minWidth: APP_MIN_DETAIL_WIDTH, minHeight: APP_MIN_DETAIL_WIDTH)
            }
        }
        .frame(minWidth: 180 + APP_MIN_DETAIL_WIDTH)
        .onChange(of: navState) { visibility in
            storedNavigationState = NavigationStoredState(visibility: visibility, view: selectedItem).getData()
        }
        .onChange(of: selectedItem) { item in
            storedNavigationState = NavigationStoredState(visibility: navState, view: item).getData()
        }
        .task {
            let restored = NavigationStoredState.decode(data: storedNavigationState)
            navState = restored.navigationVisibility
            selectedItem = restored.currentView
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 800, height: 600)
    }
}
