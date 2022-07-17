//
//  TagView.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/16/22.
//

import SwiftUI

struct TagView: View {
    var tag: TagManager.Tag
    var body: some View {
        Text(tag.name)
            .foregroundColor(.accentColor)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .overlay(RoundedRectangle(cornerRadius: 3, style: .continuous)
                .stroke(Color.accentColor, lineWidth: 1))
            .contextMenu {
                Button("Delete Tag") {
                    print("Not implemented.")
                }
            }
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(tag: TagManager.Tag(name: "TCC"))
    }
}
