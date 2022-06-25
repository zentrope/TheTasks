//
//  Date.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/24/22.
//

import Foundation

extension Date {

    func isToday() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.isDate(self, inSameDayAs: today)
    }

    func isYesterday() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        return Calendar.current.isDate(self, inSameDayAs: yesterday)
    }
}
