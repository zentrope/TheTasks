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

            Divider()

            HStack(spacing: 4) {
                Text("Pending:")
                Text("\(state.pendingTasks)")
                    .foregroundColor(.red)
            }

            Divider()

            HStack(spacing: 4) {
                Text("Completed:")
                Text("\(state.completedTasks)")
                    .foregroundColor(.blue)
            }

            Divider()

            HStack(spacing: 4) {
                Text("Cancelled:")
                Text("\(state.cancelledTasks)")
                    .foregroundColor(.blue)
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
        TaskStatsView()
            .environmentObject(AppViewState())
    }
}
