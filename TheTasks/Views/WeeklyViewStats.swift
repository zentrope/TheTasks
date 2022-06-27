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
    var exportableCount: Int

    var body: some View {
        HStack(spacing: 20) {

            Spacer()

            Group {
                DateView(date: focus.startOfWeek(), format: .nameMonthDayYear)
                    .foregroundColor(.purple)

                Divider()
            }

            HStack(spacing: 4) {
                Text("Completed:")
                Text("\(count)")
                    .foregroundColor(.green)
                    .font(.callout.monospacedDigit())
            }

            Divider()

            HStack(spacing: 4) {
                Text("Exportable:")
                Text("\(exportableCount)")
                    .foregroundColor(.green)
                    .font(.callout.monospacedDigit())
            }
            .fixedSize()

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
        WeeklyViewStats(focus: Date(), count: 52, exportableCount: 32)
    }
}
