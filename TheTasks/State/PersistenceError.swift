//
//  PersistenceError.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import Foundation

enum PersistenceError: Error, LocalizedError {

    case fetchRequestNotFound(String)
    case fetchFailed
    case taskNotFound

    var errorDescription: String? {
        switch self {
            case .fetchRequestNotFound(let name):
                return "No fetch request named '\(name)' was found."
            case .fetchFailed:
                return "Unable to complete a fetch."
            case .taskNotFound:
                return "Task not found."
        }
    }

}
