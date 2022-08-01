//
//  NavigationStoredState.swift
//  TheTasks
//
//  Created by Keith Irwin on 8/1/22.
//

import SwiftUI

struct NavigationStoredState: Codable {

    var navigationVisibility: NavigationSplitViewVisibility
    var currentView: SidebarViewState.CurrentView?

    init(visibility: NavigationSplitViewVisibility, view: SidebarViewState.CurrentView?) {
        self.navigationVisibility = visibility
        self.currentView = view
    }

    static func decode(data: Data?) -> NavigationStoredState {
        if let data,
           let result = try? JSONDecoder().decode(Self.self, from: data) {
            return result
        }
        return NavigationStoredState(visibility: .all, view: .available)
    }

    func getData() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
