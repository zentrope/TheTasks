//
//  TagBadgeView.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/16/22.
//

import SwiftUI

struct TagBadgeView: View {

    var tag: TagManager.Tag

    @State private var active = false

    var body: some View {
        Text(tag.name)
            .foregroundColor(active ? .red : .accentColor)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .overlay(RoundedRectangle(cornerRadius: 4, style: .circular)
                .stroke(active ? Color.red : Color.accentColor, lineWidth: 1))
            .onHover { over in
                active.toggle()
                if over { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagBadgeView(tag: TagManager.Tag(name: "TCC"))
    }
}
