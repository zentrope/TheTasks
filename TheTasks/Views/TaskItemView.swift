//
//  TaskItemView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import Combine
import SwiftUI
import UniformTypeIdentifiers

enum TaskItemEvent {
    case delete(TheTask)
    case save(TheTask)
    case complete(TheTask)
    case pending(TheTask)
    case remove(tag: TagManager.Tag, from: TheTask)
    case add(tag: TagManager.Tag, to: TheTask)
}

struct TaskItemView: View {

    @Binding var task: TheTask

    var action: ((TaskItemEvent) -> ())?

    @State private var isTargetedForDrop = false
    @State private var originalText = ""
    @FocusState private var isFocused: Bool?

    private let queue = PassthroughSubject<String, Never>()

    var body: some View {
        HStack { // Wrapper HSTack is so that the context menu covers whitespace but doesn't interfere with the onDrop/isTargeted background. Sigh.
            HStack (alignment: .center, spacing: 10) {
                TaskClickIcon(status: task.status)
                    .frame(width: 20, alignment: .leading)
                    .font(.title2)
                    .onHover { inside in
                        if inside {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .onTapGesture {
                        action?(pending ? .complete(task) : .pending(task))
                    }

                if task.isEditable {
                    TextField("", text: $task.task)
                        .labelsHidden()
                        .onChange(of: task.task) { newName in
                            queue.send(newName)
                        }
                        .onReceive(queue.debounce(for: .seconds(1), scheduler: DispatchQueue.main).removeDuplicates()) { text in
                            action?(.save(task))
                        }
                        .onSubmit {
                            task.toggleEditMode()
                            action?(.save(task))
                        }
                        .onExitCommand(perform: {
                            task.toggleEditMode()
                            task.task = originalText
                            action?(.save(task))
                        })
                        .focused($isFocused, equals: true)
                        .onAppear {
                            self.originalText = task.task
                            isFocused = true
                        }
                } else {
                    Text(task.task)
                        .foregroundColor(pending ? .primary : .secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 2.5)
                        .padding(.horizontal, 4)
                }

                HStack {
                    ForEach(task.tags, id: \.id) { tag in
                        TagBadgeView(tag: tag)
                            .font(.caption)
                            .contextMenu {
                                Button("Remove \"\(tag.name)\" Tag") {
                                    action?(.remove(tag: tag, from: task))
                                }
                            }
                    }
                }
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 2)
            .background(isTargetedForDrop ? Color(nsColor: .quaternaryLabelColor) : Color.clear)

            // The user might have clicked on some other part of the list, so force off edit mode.
            .onChange(of: isFocused) { currentFocus in
                guard let currentFocus, currentFocus == true else {
                    task.toggleEditMode(force: false)
                    return
                }
            }

            // This doesn't match the List-based highlight.
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
            .onDrop(of: [UTType.tag.identifier], isTargeted: $isTargetedForDrop) { providers in
                for p in providers {
                    p.loadObject(ofClass: TagManager.Draggable.self) { draggable, _ in
                        if let draggable = draggable as? TagManager.Draggable {
                            action?(.add(tag: draggable.tag, to: task))
                        }
                    }
                }
                return true
            }
        }
        .background(.background)
        .contextMenu {
            Button("Rename Task") { task.toggleEditMode() }
            if pending {
                Button("Complete Task") { action?(.complete(task)) }
            } else {
                Button("Mark Task Available") { action?(.pending(task)) }
            }
            Divider()
            Button("Delete Task") { action?(.delete(task)) }
        }
    }

    private var pending: Bool {
        task.status == .pending
    }
}

struct TaskClickIcon: View {
    var status: TaskMO.TaskStatus

    var body: some View {
        Image(systemName: icon)
            .foregroundColor(color)
    }

    private var icon: String {
        switch status {
            case .pending: return "circle"
            case .cancelled: return "circle.slash"
            case .completed: return "checkmark.circle"
        }
    }

    private var color: Color {
        switch status {
            case .pending: return .green
            case .cancelled: return Color.brown
            case .completed: return Color.secondary
        }
    }
}
