//
//  DateView.swift
//  TheTasks
//
//  Created by Keith Irwin on 12/30/21.
//

import SwiftUI

struct DateView: View {

    enum Format: String {

        /// Tuesday
        case weekdayName = "EEEE"

        /// 12:34 AM
        case timeHourMinute = "hh:mm a"

        /// "MM-dd-yyyy hh:mm a"
        case dateTimeMonthFirst = "MM-dd-yyyy hh:mm a"

        /// "yyyy-MM-dd"
        case dateShort = "yyyy-MM-dd"

        /// "yyyy-MM-dd hh:mm a"
        case dateTime = "yyyy-MM-dd hh:mm a"

        /// "yyyy-MM-dd'T'HH:mm:ssZ"
        case iso8601 = "yyyy-MM-dd'T'HH:mm:ssZ"

        /// "MMMM d, yyyy @ hh:mm a"
        case dateTimeNameLong = "MMMM d, yyyy @ hh:mm a"

        /// "MMMM d, yyyy"
        case dateNameMedium = "MMMM d, yyyy"

        /// "MMM dd, yyyy"
        case dateNameShort = "MMM dd, yyyy"

        /// "EEEE, MMMM d, yyyy' - 'h:mm a"
        case dateDayTimeNameLong = "EEEE, MMMM d, yyyy' - 'h:mm a"

        /// Tue, Dec 21, 2021
        case nameMonthDayYear = "EEE, MMM d, yyyy"

        /// Tuesday — December 21, 2021
        case journalStyle = "EEEE — MMMM d, yyyy"

        /// "MMMM yyyy"
        case dateMonthYear = "MMMM yyyy"

        case overdueSince = "formatOverdue()"

        case timeSince = "formatTimeSince()"
    }

    var date: Date?
    var format: Format
    var ifNil: String = "…"

    var body: some View {
        Text(fmt(date, using: format))
    }

    private func fmt(_ date: Date?, using format: Format) -> String {
        guard let date = date else { return ifNil }
        if format == .overdueSince {
            return formatOverdue(date)
        }
        if format == .timeSince {
            return formatTimeSince(date)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        let result = formatter.string(from: date)
        return result
    }

    private func formatOverdue(_ date: Date) -> String {
        let interval = abs(date.timeIntervalSince(Date()))

        let hours = interval / 60 / 60

        if hours > (3 * 24) {
            return String(format: "Overdue %.0f days", hours / 24)
        }

        let rounding = hours < 10 ? "Overdue %.2f hours" : "Overdue %.0f hours"
        return String(format: rounding, interval / 60 / 60)
    }

    private func formatTimeSince(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }

        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        }

        let interval = abs(date.timeIntervalSince(Date()))
        let hours = interval / 60 / 60

        let numberOfDays = Int(ceil(hours / 24.0))
        return String(format: "%d days", numberOfDays)
    }

}
