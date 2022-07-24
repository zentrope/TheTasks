//
//  String.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/23/22.
//

import Foundation

extension String {
    var quoted: String {
        self.replacingOccurrences(of: "\"", with: "\"\"")
    }
}
