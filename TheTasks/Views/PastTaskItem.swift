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
                switch completion {
                    case .completedLater:
                        Image(systemName: "arrow.right.to.line.circle")
                            .foregroundColor(.green)
                            .font(.title2)
                    case .completedNow:
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.gray)
                            .font(.title2)
                    case .notCompleted:
                        Image(systemName: "arrow.forward.circle")
                            .foregroundColor(.red)
                            .font(.title2)
                }
            }
            Spacer()
            Group {
                switch completion {
                    case .completedLater:
                        Text("completed later")
                    case .completedNow:
                        Text("completed")
                    case .notCompleted:
                        Text("still pending")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .lineLimit(1)
    }
}

//struct PastTaskItem_Previews: PreviewProvider {
//    static var previews: some View {
//        PastTaskItem()
//    }
//}
