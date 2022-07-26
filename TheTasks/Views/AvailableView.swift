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
            // Hack, to keep the list from showing up in the toolbar when window style is set to to .hiddenTitleBar
            Spacer().frame(height: 0.5)

            List(selection: $state.selectedTask) {
                ForEach(state.tasks, id: \.id) { task in
                    TaskItemView(task: task, action: handleTaskEvent)
                        .lineLimit(1)
                        .padding(8)
                }
            }
            .listStyle(.inset(alternatesRowBackgrounds: false))

            TaskStatsView(stats: state.stats)
        }
        .frame(minWidth: 350, idealWidth: 350)

        // Hack: so that the toolbar doesn't get the semi-transparent look
        .background(.background)

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
            Toggle(isOn: $state.showCompleted) {
                Image(systemName: state.showCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                    .frame(width: 15)
            }
            .help("Show completed")

            Toggle(isOn: $state.showToday) {
                Image(systemName: state.showToday ? "clock.fill" : "clock")
                    .frame(width: 15)
            }
            .help("Show today only")

            Spacer()

            TagFilterButton()
                .help("Non-function filter")

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

fileprivate struct TagFilterButton: View {

    typealias FilterAction = ([TagManager.Tag], Bool, String) -> Void

    enum Logical: String, CaseIterable {
        case matchAny = "Match any"
        case matchAll = "Match all"
    }

    var action: FilterAction?

    @State private var show = false
    @State private var strategy = Logical.matchAll
    @State private var savedQuery = ""
    @State private var shouldSave = false
    @State private var selectedTags = [TagManager.Tag]()

    var body: some View {
        Button {
            show.toggle()
        } label: {
            Image(systemName: "tag")
        }
        .popover(isPresented: $show, content: {
            VStack(alignment: .leading, spacing: 10) {
                Picker("", selection: $strategy) {
                    ForEach(Logical.allCases, id: \.self) { strategy in
                        Text(strategy.rawValue).tag(strategy)
                    }
                }
                Divider()
                TagPicker(initialTags: [], action: { tags in
                    selectedTags = tags
                })
                .listStyle(.plain)

                HStack(spacing: 10) {
                    TextField("Save search name", text: $savedQuery)
                    Toggle("Save?", isOn: $shouldSave)
                        .disabled(savedQuery.isEmpty)
                }
            }
            .frame(minWidth: 150, minHeight: 300, maxHeight: 600)

            .padding()
        })
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        AvailableView()
    }
}
