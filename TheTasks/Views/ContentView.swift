//
//  ContentView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import SwiftUI

struct ContentView: View {

    @State private var selectedItem: NavViewState.CurrentView? = .available

    var body: some View {
        VStack {
            NavigationSplitView {
                SidebarView(selection: $selectedItem)
                    .navigationSplitViewColumnWidth(min: 180, ideal: 180, max: 220)
            } detail: {
                VStack {
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 800, height: 600)
    }
}
