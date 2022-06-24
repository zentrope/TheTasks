//
//  TaskItemView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import SwiftUI

struct TaskItemView: View {

    var task: TheTask

    @EnvironmentObject private var state: AppViewState

    @FocusState private var focus: FocusTask?

    @State private var confirmDelete = false
    @State private var title: String

    init(task: TheTask) {
        self.task = task
        self._title = State(initialValue: task.task)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Label {
                EditableText(text: task.task, onChange: { state.update(task: task.id, name: $0) })
                    .focused($focus, equals: .task(task.id))
                    .font(task.status == .cancelled ? .body.weight(.thin).italic() : task.status == .completed ? .callout.weight(.thin).italic() : .body)
            } icon: {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30, alignment: .center)
                    .onHover { inside in
                        if inside {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .onTapGesture {
                        state.update(task: task.id, status: task.status == .completed ? .pending : .completed)
                    }
            }

            Spacer()
            Group {
                switch task.status {
                    case .cancelled:
                        DateView(date: task.completed, format: .nameMonthDayYear)
                    case .completed:
                        DateView(date: task.completed, format: .nameMonthDayYear)
                    case .pending:
                        DateView(date: task.created, format: .timeSince)
                }
            }
            .font(task.status == .cancelled ? .caption.weight(.thin).italic() : task.status == .completed ? .caption.weight(.thin).italic() : .callout)
        }
        .confirmationDialog("Delete '\(task.task)'?", isPresented: $confirmDelete) {
            Button("Delete") {
                state.delete(task: task.id)
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if task.status == .cancelled {
                Button(role: .none) {
                    state.update(task: task.id, status: .pending)
                } label: {
                    Text("Restore")
                }
            } else {
                Button(role: .cancel) {
                    state.update(task: task.id, status: .cancelled)
                } label: {
                    Text("Cancel")
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                state.delete(task: task.id)
            } label: {
                Text("Delete")
            }
        }
        .contextMenu {
            if task.status == .completed {
                Button("Mark uncompleted") {
                    state.update(task: task.id, status: .pending)
                }
            } else if task.status == .cancelled {
                Button("Uncancel") {
                    state.update(task: task.id, status: .pending)
                }
                Button("Complete") {
                    state.update(task: task.id, status: .completed)
                }
            } else {
                Button("Complete") {
                    state.update(task: task.id, status: .completed)
                }
                Button("Cancel") {
                    state.update(task: task.id, status: .cancelled)
                }
            }
            Divider()
            Button("Delete") {
                confirmDelete.toggle()

            }
        }
        .onChange(of: state.focusedTask) { newFocus in
            focus = newFocus
        }
    }

    private var icon: String {
        switch task.status {
            case .pending: return "circle"
            case .cancelled: return "circle.slash"
            case .completed: return "checkmark.circle"
        }
    }

    private var color: Color {
        switch task.status {
            case .pending: return .green
            case .cancelled: return Color.brown
            case .completed: return .gray
        }
    }
}

//struct TaskItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskItemView(task: .init(newTask: "Test task description"))
//    }
//}
