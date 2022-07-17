//
//  AvailableView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/22/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct AvailableView: View {

    @EnvironmentObject private var state: AppViewState

    @State private var confirmDelete = false
    @State private var taskToDelete: TheTask?

    var body: some View {
        VStack(spacing: 0) {

            Text("Available")
                .font(.taskHeading)
                .foregroundColor(.accentColor)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background)

            ScrollView {
                ForEach($state.tasks, id: \.id) { $task in
                    HStack {
                        TaskItemView(task: $task, action: handleTaskEvent)
                            .lineLimit(1)
                    }
                    .confirmationDialog("Delete '\(taskToDelete?.task ?? "Unknown")'?", isPresented: $confirmDelete) {
                        Button("Delete") {
                            if let taskToDelete {
                                state.delete(task: taskToDelete.id)
                            }
                        }
                    }
                }
            }
            .listStyle(.inset(alternatesRowBackgrounds: false))
            TaskStatsView()
        }

        .frame(minWidth: 350, idealWidth: 350)
        .alert(state.error?.localizedDescription ?? "Error", isPresented: $state.showAlert) {}

        .toolbar {

            Button(action: { state.createNewTask() }, label: { Image(systemName: "plus") })

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
            case .save(let task):
                state.update(task: task.id, name: task.task)
            case .delete(let task):
                taskToDelete = task
                confirmDelete.toggle()
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
