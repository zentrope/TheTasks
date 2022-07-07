//
//  EditableText.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import SwiftUI
import Combine

struct EditableText: View {

    // Future: Might be interesting to account for Escape and Commit by creating an
    // enum: .escape, .commit, .update(String) and building the queue based on those
    // values. The .escape enum might restore the initial value we saved ... somehow.

    // Although marked as @State, this is directly set by callers. Hack alert! A
    // better solution would be to require a @Binding and yet still process changes
    // here via a callback, rather than somewhere up the chain. Do _not_ use this
    // variant in a simple form: only as part of a long list of "lines" to edit when
    // you can't declare an @State var for each element of the list.

    @State var text = ""

    // Track the value locally and report back to the caller when it should save the
    // value in the persistence store.

    var onChange: ((String) -> ())?

    // Text changes are published here for de-dup and debounce processing.

    private let changeQueue = PassthroughSubject<String, Never>()

    var body: some View {
        TextField("", text: $text)
            .labelsHidden()
            .onChange(of: text) { newText in
                changeQueue.send(newText)
            }

            .onReceive(changeQueue
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates()) { text in

                // Only send the text after a 1 second delay in activity. Remove
                // duplicates, too, while we're at it.

                onChange?(text)
            }
    }
}

struct EditableText_Previews: PreviewProvider {
    static var previews: some View {
        EditableText(text: "Some text")
            .padding()
    }
}
