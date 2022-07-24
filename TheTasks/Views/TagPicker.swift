//
//  TagPicker.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/23/22.
//

import SwiftUI

struct TagPicker: View {

    typealias TagPickerAction = ([TagManager.Tag]) -> Void

    var initialTags: [TagManager.Tag]
    var action: TagPickerAction?

    @StateObject private var state = TagPickerViewState()

    var body: some View {
        List {
            ForEach($state.tags, id: \.id) { $tag in
                Toggle(tag.name, isOn: $tag.isSelected)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: state.tags) { _ in
            action?(state.selected())
        }
        .onAppear {
            state.preselect(tags: initialTags)
        }
    }
}

