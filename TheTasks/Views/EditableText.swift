//
//  EditableText.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import SwiftUI
import Combine

struct EditableText: View {

    @State var text = ""
    var onChange: ((String) -> ())?

    private let pubber = PassthroughSubject<String, Never>()

    var body: some View {
        TextField("", text: $text)
            .onChange(of: text) { newText in
                pubber.send(newText)
            }
            .onReceive(pubber.debounce(for: .seconds(1), scheduler: RunLoop.main).removeDuplicates()) { text in
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
