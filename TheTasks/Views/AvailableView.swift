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
    @State private var selectedTask: TheTask.ID?

    var body: some View {
        List(selection: $selectedTask) {
            ForEach(state.tasks, id: \.id) { task in
                TaskItemView(task: task, action: handleTaskEvent)
                    .padding(8)
            }

        }
        .listStyle(.inset)

        .alert(state.error?.localizedDescription ?? "Error", isPresented: $state.showAlert) {}

        .confirmationDialog("Delete '\(deleteOp.task.task)'?", isPresented: $deleteOp.isPresented) {
            Button("Delete") {
                state.delete(task: deleteOp.task.id)
            }
        }

        .sheet(isPresented: $upsertOp.isPresented) {
            EditTaskForm(task: $upsertOp.task) { revisedTask in
                state.upsert(task: revisedTask)
            }
        }

        .toolbar {
            Spacer()

            TagFilterButton(filter: $state.viewFilter) {
                state.processFilter()
            }

            Button {
                upsertOp.task = TheTask(newTask: "New Task")
                upsertOp.isPresented = true
            } label: {
                Image(systemName: "plus")
            }
        }        
    }

    private func handleTaskEvent(_ event: TaskItemEvent) {
        switch event {
            case .edit(task: let task):
                upsertOp.task = task
                upsertOp.isPresented = true
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

fileprivate struct TagFilterButton: View {

    @Binding
    var filter: TaskViewFilter
    var action: (() -> Void)?

    @State private var show = false

    var body: some View {
        Button {
            show.toggle()
        } label: {
            Image(systemName: "tag")
        }
        .popover(isPresented: $show) {

            Form {
                Picker("Tasks:", selection: $filter.completed) {
                    ForEach(TaskViewFilter.Completed.allCases, id: \.self) { coverage in
                        Text(coverage.rawValue).tag(coverage)
                    }
                }
                .pickerStyle(.radioGroup)

                Picker("Match:", selection: $filter.rule) {
                    ForEach(TaskViewFilter.Rule.allCases, id: \.self) { op in
                        Text(op.rawValue).tag(op)
                    }
                }

                TagPicker(initialTags: filter.tags, action: { tags in
                    filter.tags = tags
                })
                .listStyle(.plain)

                Button("Reset") {
                    filter.completed = .today
                    filter.rule = .or
                    filter.tags = []
                    action?()
                }
            }
            .frame(minWidth: 150, minHeight: 500, maxHeight: 600)
            .padding()
            .onChange(of: filter) { _ in
                action?()
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        AvailableView()
    }
}
