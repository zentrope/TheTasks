//
//  NavigationViewState.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/8/22.
//

import Combine
import Foundation
import OSLog

fileprivate let log = Logger("NavigationViewState")

@MainActor
class NavigationViewState: ObservableObject {

    @Published var activeView: CurrentView? = .today

    private var subscriptions = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: .appNavigateToView)
            .removeDuplicates()
            .sink { value in
                if let view = value.userInfo?["view"] as? CurrentView {
                    self.activeView = view
                }
            }
            .store(in: &subscriptions)
    }

    deinit {
        subscriptions.forEach { $0.cancel() }
    }

    enum CurrentView {
        case today
        case thisWeek
        case lastWeek
    }

}
