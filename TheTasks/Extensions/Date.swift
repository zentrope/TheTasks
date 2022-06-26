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

    func startOfWeek() -> Date {
        Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }

    func endOfWeek() -> Date {
        let start = startOfWeek()
        let weekLater = Calendar.current.date(byAdding: .day, value: 7, to: start)!
        return Calendar.current.date(byAdding: .second, value: -1, to: weekLater)!
    }

    func lastWeek() -> Date {
        Calendar.current.date(byAdding: .day, value: -7, to: self)!
    }
}
