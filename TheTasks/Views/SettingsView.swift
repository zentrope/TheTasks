//
//  SettingsView.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/3/22.
//

import SwiftUI

struct SettingsView: View {

    @AppStorage("showBadge") private var showBadge = true

    var body: some View {
        Form {
            Toggle("Show pending tasks in dock icon?", isOn: $showBadge)
        }
        .padding()
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
