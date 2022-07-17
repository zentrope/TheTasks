//
//  TaskItemView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct TaskItemView: View {

    var task: TheTask

    @EnvironmentObject private var state: AppViewState

    @FocusState private var focus: FocusTask?

    @State private var confirmDelete = false
    @State private var title: String
    @State private var isTargeted = false

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
                    .foregroundColor(task.status == .pending ? .primary : .secondary)
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
            HStack {
                ForEach(task.tags, id: \.id) { tag in
                    TagView(tag: tag)
                        .font(.caption)
                }
            }
        }
        .padding([.horizontal], 5)
        .overlay(RoundedRectangle(cornerRadius: 4, style: .continuous).stroke(isTargeted ? .blue : .clear, lineWidth: 2))

        .onDrop(of: [UTType.tag.identifier], isTargeted: $isTargeted) { providers in
            for p in providers {
                p.loadObject(ofClass: TagManager.Draggable.self) { draggable, _ in
                    if let draggable = draggable as? TagManager.Draggable {                        
                        state.add(tag: draggable.tag, to: task)
                    }
                }
            }
            return true
        }
        .confirmationDialog("Delete '\(task.task)'?", isPresented: $confirmDelete) {
            Button("Delete") {
                state.delete(task: task.id)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: task.status == .completed ? .none : .destructive) {
                state.update(task: task.id, status: task.status == .completed ? .pending : .completed)
            } label: {
                Label {
                    Text(task.status == .completed ? "Available" : "Complete")
                } icon: {
                    Image(systemName: task.status == .completed ? "circle" : "checkmark.circle")
                }
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
            case .completed: return Color.secondary
        }
    }
}

//struct TaskItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskItemView(task: .init(newTask: "Test task description"))
//    }
//}
