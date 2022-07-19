//
//  EditTaskForm.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/18/22.
//

import SwiftUI

struct EditTaskForm: View {

    @Binding var task: TheTask

    var perform: ((TheTask) -> Void)?

    @StateObject private var state = EditTaskViewState()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Label {
                    Text("Update Task")
                } icon: {
                    Image(systemName: "checkmark.square")
                        .foregroundColor(.accentColor)
                }
                .font(.title3)
            }

            TextField("Description:", text: $task.task)
                .onSubmit {
                    save()
                }

            Toggle("Allow task to be exported as part of a work report", isOn: $task.isExportable)
                .padding(.vertical, 6)

            HStack(alignment: .center) {
                unclaimButton

                ScrollView(.horizontal) {
                    HStack(spacing: 4) {
                        ForEach($state.claimed, id: \.id) { $tag in
                            Tag(tag: $tag)
                        }
                    }
                    .frame(height: 20)
                }
                .padding(4)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(nsColor: .gridColor), lineWidth: 1))
                .overlay(Text("Select tags to remove from this task")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .offset(x: 4, y: 14), alignment: .bottomLeading)
            }
            .padding(.vertical, 6)


            HStack(alignment: .center) {
                claimButton

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach($state.available, id: \.id) { $tag in
                            Tag(tag: $tag)
                        }
                    }
                    .frame(height: 20)
                }
                .padding(4)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(nsColor: .gridColor), lineWidth: 1))
                .overlay(Text("Select tags to add to this task")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .offset(x: 4, y: 14), alignment: .bottomLeading)
            }
            .padding(.vertical, 8)

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
        .padding(.horizontal, 20)
        .frame(minWidth: 600, maxWidth: 1000)
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            state.load(task: task)
        }
    }

    private var claimButton: some View {
        Button {
            state.claim()
        } label: {
            Image(systemName: "plus.circle")
        }
        .buttonStyle(.borderless)
        .help("Add selected tags to this task")
    }

    private var unclaimButton: some View {
        Button {
            state.unclaim()
        } label: {
            Image(systemName: "minus.circle")
        }
        .buttonStyle(.borderless)
        .help("Remove selected tags from this class")
    }

    @ViewBuilder
    private func Tag(tag: Binding<EditTaskViewState.Tag>) -> some View {
        Text(tag.wrappedValue.name)
            .font(.callout)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundColor(tag.wrappedValue.isSelected ? .white : .primary)
            .background(tag.wrappedValue.isSelected ? .blue : .gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            .onTapGesture {
                tag.wrappedValue.isSelected.toggle()
            }
    }

    private func save() {
        task.tags = state.tags()
        perform?(task)
        dismiss()
    }
}

struct EditTaskForm_Previews: PreviewProvider {
    static var previews: some View {
        EditTaskForm(task: .constant(TheTask(newTask: "Preview the form")))
    }
}
