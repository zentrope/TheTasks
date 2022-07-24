//
//  EditTaskForm.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/18/22.
//

import SwiftUI

struct EditTaskForm: View {

    typealias EditTaskAction = (TheTask) -> Void

    @Binding var task: TheTask

    var action: EditTaskAction?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Label {
                Text("Update Task")
            } icon: {
                Image(systemName: "checkmark.square")
                    .foregroundColor(.accentColor)
            }
            .font(.title3.bold())

            TextField("Description:", text: $task.task)
                .onSubmit {
                    save()
                }

            Toggle("Allow task to be exported as part of a work report", isOn: $task.isExportable)
                .padding(.vertical, 6)

            TagPicker(initialTags: task.tags) { selectedTags in
                task.tags = selectedTags
            }
            .listStyle(.bordered(alternatesRowBackgrounds: true))
            .frame(maxWidth: .infinity, minHeight: 200)
            .border(Color(nsColor: .gridColor))

            HStack {
                Spacer()
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Cancel").frame(width: 50)
                }
                .keyboardShortcut(.cancelAction)

                Button {
                    save()
                } label: {
                    Text("Save").frame(width: 50)
                }
                .keyboardShortcut(.defaultAction)
            }

        }
        .padding()
        .frame(minWidth: 600, maxWidth: 1000)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func save() {
        action?(task)
        dismiss()
    }
}

struct EditTaskForm_Previews: PreviewProvider {
    static var previews: some View {
        EditTaskForm(task: .constant(TheTask(newTask: "Preview the form")))
    }
}
