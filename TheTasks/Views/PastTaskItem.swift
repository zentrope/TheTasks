//
//  PastTaskItem.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/20/22.
//

import SwiftUI

struct PastTaskItem: View {

    var task: TheTask
    var focusDate: Date

    private enum CompleteState {
        case completedLater
        case completedNow
        case notCompleted
    }

    private var completion: CompleteState {
        guard let completed = task.completed else {
            return .notCompleted
        }
        return Calendar.current.startOfDay(for: completed) == Calendar.current.startOfDay(for: focusDate) ? .completedNow : .completedLater
    }

    private var completedOnFocusDate: Bool {
        guard let completed = task.completed else {
            return false
        }
        return Calendar.current.startOfDay(for: completed) == Calendar.current.startOfDay(for: focusDate)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Label {
                Text(task.task)
                    .foregroundColor(completion == .notCompleted ? .primary : .secondary)
            } icon: {
                TaskIcon(status: task.status)
            }
            Spacer()
            DateView(date: task.completed, format: .timeHourMinute)
                .font(.callout.monospacedDigit())
            HStack {
                Spacer()
                if task.isExportable {
                    Image(systemName: "arrow.down.circle")
                        .foregroundColor(.secondary)
                        .help("Exportable")
                }
            }
            .font(.callout)
            .frame(width: 20)
        }
        .lineLimit(1)
    }
}

//struct PastTaskItem_Previews: PreviewProvider {
//    static var previews: some View {
//        PastTaskItem()
//    }
//}
