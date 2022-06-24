//
//  SidebarView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/22/22.
//

import SwiftUI

struct SidebarView: View {

    @EnvironmentObject private var state: AppViewState

    var body: some View {
        VStack(alignment: .leading) {
            List {
                Section(header: Text("Recent")) {
                    Label(title: {Text("Today") }, icon: { Image(systemName: "line.3.horizontal.decrease.circle")})
                    Label(title: {Text("This week?") }, icon: { Image(systemName: "calendar")})
                    Label(title: {Text("Last week?") }, icon: { Image(systemName: "calendar")})
                    
                }
            }
            .listStyle(.sidebar)
            HStack {

                DatePicker("", selection: $state.focusDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                Spacer()
            }
            .padding()

        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var state = AppViewState()
    static var previews: some View {

        SidebarView()
            .frame(width: 180)
            .environmentObject(state)
    }
}
