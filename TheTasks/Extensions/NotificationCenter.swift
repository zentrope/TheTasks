//
//  NotificationCenter.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/8/22.
//

import Foundation

extension Notification.Name {

    static let appNavigateToView = Notification.Name("appNavigateToView")

}

extension NotificationCenter {

    func navigateTo(view: NavViewState.CurrentView) {
        post(name: .appNavigateToView, object: nil, userInfo: ["view": view])
    }
}
