//
//  Logger.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import OSLog

extension Logger {
    init(_ category: String) {
        self.init(subsystem: Bundle.main.bundleIdentifier!, category: category)
    }
}
