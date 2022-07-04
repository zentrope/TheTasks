//
//  UserDefaults.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/4/22.
//

import Foundation

extension UserDefaults {

    func bool(forKey key: String, ifNew value: Bool) -> Bool {
        if object(forKey: key) == nil {
            set(value, forKey: key)
            return value
        }
        return bool(forKey: key)
    }
}
