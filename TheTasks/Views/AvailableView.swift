//
//  AvailableView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/22/22.
//

import SwiftUI
import UniformTypeIdentifiers


fileprivate struct TaskOp {
    var isPresented = false
    var task = TheTask(newTask: "New Task")
}

struct AvailableView: View {

    @StateObject private var state = AvailableViewState()

    @State private var deleteOp = TaskOp()
    @State private var upsertOp = TaskOp()

    var body: some View {
        VStack(spacing: 0) {
            List(selection: $state.selectedTask) {
                ForEach(state.tasks, id: \.id) { task in
                    TaskItemView(task: task, action: handleTaskEvent)
                        .lineLimit(1)
                }
            }
            .listStyle(.inset(alternatesRowBackgrounds: false))

            TaskStatsView(stats: state.stats)
        }
        .navigationTitle("Available")
        .navigationSubtitle(state.stats.pending == 0 ? "All clear" : "\(state.stats.pending) pending tasks")
        .frame(minWidth: 350, idealWidth: 350)
        .alert(state.error?.localizedDescription ?? "Error", isPresented: $state.showAlert) {}

        .confirmationDialog("Delete '\(deleteOp.task.task)'?", isPresented: $deleteOp.isPresented) {
            Button("Delete") {
                state.delete(task: deleteOp.task.id)
            }
        }

        .sheet(isPresented: $upsertOp.isPresented, content: {
            EditTaskForm(task: $upsertOp.task) { revisedTask in                
                state.upsert(task: revisedTask)
            }
        })

        .toolbar {

            Button {
                upsertOp.task = TheTask(newTask: "New Task")
                upsertOp.isPresented = true
            } label: {
                Image(systemName: "plus")
            }

            Spacer()

            // Using toggles like this doesn't feel like the right way to go, but leaving this in until I see something better. I think a segmented controll for all, today and today+completed is more reasonable.
            Toggle(isOn: $state.showCompleted) {
                // MACOS13: use checklist.checked and checklist.unchecked
                Image(systemName: state.showCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                    .frame(width: 15)
            }
            .help("Show completed")

            Toggle(isOn: $state.showToday) {
                Image(systemName: state.showToday ? "clock.fill" : "clock")
                    .frame(width: 15)
            }
            .help("Show today only")
        }
    }

    private func handleTaskEvent(_ event: TaskItemEvent) {
        switch event {
            case .edit(task: let task):
                upsertOp.task = task
                upsertOp.isPresented = true
            case .save(let task):
                state.update(task: task.id, name: task.task)
            case .delete(let task):
                deleteOp.task = task
                deleteOp.isPresented.toggle()
            case .complete(let task):
                state.update(task: task.id, status: .completed)
            case .pending(let task):
                state.update(task: task.id, status: .pending)
            case .remove(tag: let tag, from: let task):
                state.remove(tag: tag, from: task)
            case .add(tag: let tag, to: let task):
                state.add(tag: tag, to: task)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        AvailableView()
    }
}
