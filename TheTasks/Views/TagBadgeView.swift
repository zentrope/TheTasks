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
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color(red: 0.9, green: 0.9, blue: 0.9).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .circular))
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
