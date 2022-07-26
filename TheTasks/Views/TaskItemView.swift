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
    case edit(task: TheTask)
    case complete(TheTask)
    case pending(TheTask)
    case remove(tag: TagManager.Tag, from: TheTask)
    case add(tag: TagManager.Tag, to: TheTask)
}

struct TaskItemView: View {

    var task: TheTask

    var action: ((TaskItemEvent) -> ())?

    @State private var isTargetedForDrop = false

    private let queue = PassthroughSubject<String, Never>()

    var body: some View {
        HStack (alignment: .top, spacing: 10) {

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
                .overlay(Image(systemName: "plus.circle.fill")
                         // When you hover over a list item to drop a tag, you see a (+) over the checkbox icon to indicate which item you're going to drop on. If you ever see a more appropriate affordance for dropping on a SwiftUI list item, use it. I'd put a border around the row, but I can't find a way to make it match the selection shape (and size) computed by List.
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(isTargetedForDrop ? Color.white : .clear,
                                     isTargetedForDrop ? Color.accentColor : .clear)
                        .font(.title2), alignment: .center)

            VStack(alignment: .leading, spacing: 6) {
                Text(task.task)
                    .foregroundColor(pending ? .primary : .secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    ForEach(task.tags, id: \.id) { tag in
                        TagBadgeView(tag: tag)
                            .font(.caption)
                            .opacity(task.status == .pending ? 1.0 : 0.5)
                    }
                    Spacer()
                }
                .lineLimit(1)
                .overlay(Divider().offset(y: 12), alignment: .bottom)
            }
        }
        .contextMenu {
            Button("Edit Task") {
                action?(.edit(task: task))
            }
            if pending {
                Button("Complete Task") { action?(.complete(task)) }
            } else {
                Button("Mark Task Available") { action?(.pending(task)) }
            }
            Divider()
            Button("Delete Task") { action?(.delete(task)) }
        }
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
