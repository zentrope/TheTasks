//
//  EditTagForm.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/17/22.
//

import SwiftUI

struct EditTagForm: View {

    @Binding var tag: TagManager.Tag
    var perform: ((TagManager.Tag) -> Void)?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Label {
                    Text("Update Tag")
                } icon: {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.accentColor)
                }
                .font(.title3)
            }

            Form {
                TextField("Name", text: $tag.name)
            }
            .onSubmit {
                perform?(tag)
                dismiss()
            }

            HStack {
                Spacer()
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Cancel").frame(width: 50)
                }
                .keyboardShortcut(.cancelAction)
                .controlSize(.small)

                Button {
                    perform?(tag)
                    dismiss()
                } label: {
                    Text("Save").frame(width: 50)
                }
                .keyboardShortcut(.defaultAction)
                .controlSize(.small)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

struct EditTagForm_Previews: PreviewProvider {
    static var previews: some View {
        EditTagForm(tag: .constant(TagManager.Tag(name: "New Tag")))
    }
}
