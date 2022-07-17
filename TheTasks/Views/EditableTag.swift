//
//  EditableTag.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/9/22.
//

import SwiftUI
import Combine

struct EditableTag: View {

    @Binding var tag: TagManager.Tag

    var perform: ((String) -> ())?

    @FocusState private var isFocused: Bool?

    private let queue = PassthroughSubject<String, Never>()

    var body: some View {
        Label {
            if tag.isEditable {
                TextField("", text: $tag.name)
                    .labelsHidden()
                    .onChange(of: tag.name) { newName in
                        queue.send(newName)
                    }
                    .onReceive(queue
                        .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
                        .removeDuplicates()) { text in
                            perform?(text)
                        }
                    .onSubmit {
                        tag.toggleEditMode()
                        perform?(tag.name)
                    }
                    .focused($isFocused, equals: true)
                    .onAppear {
                        isFocused = true
                    }                    
            } else {
                Text(tag.name)
            }
        } icon: {
            Image(systemName: "tag")
        }
    }
}
