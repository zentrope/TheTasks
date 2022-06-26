//
//  WeeklyViewStats.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/25/22.
//

import SwiftUI

struct WeeklyViewStats: View {

    var focus: Date
    var count: Int

    var body: some View {
        HStack(spacing: 20) {
            Spacer()

            DateView(date: focus.startOfWeek(), format: .nameMonthDayYear)
                .foregroundColor(.purple)

            Divider()

            HStack {
                Text("Completed:")
                Text("\(count)")
                    .foregroundColor(.green)
            }

            Divider()

            DateView(date: focus.endOfWeek(), format: .nameMonthDayYear)
                .foregroundColor(.purple)

            Spacer()
        }
        .fixedSize(horizontal: false, vertical: true)
        .lineLimit(1)
        .padding(.vertical, 6)
        .padding(.horizontal, 20)
        .font(.callout)
        .foregroundColor(.secondary)
        .background(.background)
        .overlay(Divider(), alignment: .top)
    }
}

struct WeeklyViewStat_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyViewStats(focus: Date(), count: 52)
    }
}
