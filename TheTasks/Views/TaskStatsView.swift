//
//  TaskStatsView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/22/22.
//

import SwiftUI

struct TaskStatsView: View {

    @EnvironmentObject private var state: AppViewState

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Spacer()
            HStack(spacing: 4) {
                Text("Total:")
                Text("\(state.totalTasks)")
                    .foregroundColor(.blue)
            }

            HStack(spacing: 4) {
                Text("Pending:")
                Text("\(state.pendingTasks)")
                    .foregroundColor(.red)
            }

            HStack(spacing: 4) {
                Text("Completed:")
                Text("\(state.completedTasks)")
                    .foregroundColor(.blue)
            }

            HStack(spacing: 4) {
                Text("Cancelled:")
                Text("\(state.cancelledTasks)")
                    .foregroundColor(.blue)

            }
            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 20)
        .font(.callout)
        .foregroundColor(.secondary)
    }
}

struct TaskStatsView_Previews: PreviewProvider {
    static var previews: some View {
        TaskStatsView()
            .environmentObject(AppViewState())
    }
}
