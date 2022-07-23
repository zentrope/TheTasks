//
//  TaskStatsView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/22/22.
//

import SwiftUI

struct TaskStatsView: View {

    @EnvironmentObject private var state: AvailableViewState

    var stats: AvailableViewState.TaskStats

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Spacer()
            HStack(spacing: 4) {
                Text("Total:")
                Text("\(stats.total)")
                    .foregroundColor(.blue)
                    .font(.callout.monospacedDigit())
            }

            Divider()

            HStack(spacing: 4) {
                Text("Pending:")
                Text("\(stats.pending)")
                    .foregroundColor(.red)
                    .font(.callout.monospacedDigit())
            }

            Divider()

            HStack(spacing: 4) {
                Text("Completed:")
                Text("\(stats.completed)")
                    .foregroundColor(.blue)
                    .font(.callout.monospacedDigit())
            }

            Spacer()

            // TODO: This should be in Settings along with diagnostics of some sort
//            Button {
//                Task {
//                    try await TaskManager.shared.removeDuplicates()
//                }
//            } label: {
//                Image(systemName: "cross.case")
//            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .lineLimit(1)
        .padding(.vertical, 6)
        .padding(.horizontal, 20)
        .font(.callout)
        .foregroundColor(.secondary)
        .background(.background)
        .overlay(Divider(), alignment: .top)
    }
}

struct TaskStatsView_Previews: PreviewProvider {
    static var previews: some View {
        TaskStatsView(stats: AvailableViewState.TaskStats(completed: 10, total: 110, pending: 100))
    }
}
