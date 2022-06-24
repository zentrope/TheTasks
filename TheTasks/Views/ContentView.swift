//
//  ContentView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var state: AppViewState

    var body: some View {
        NavigationView {
            SidebarView()
                .frame(minWidth: 180, idealWidth: 180)
            DetailView()
                .frame(idealWidth: 350, maxWidth: .infinity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppViewState())
            .frame(width: 800, height: 600)
    }
}
