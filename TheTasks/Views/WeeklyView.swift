//
//  WeeklyView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/25/22.
//

import SwiftUI

struct WeeklyView: View {

    var date: Date

    @StateObject private var state = WeeklyViewState()
    @AppStorage("showAllTasks") var showAllTasks = true
    @AppStorage("showMostRecentFirst") var showMostRecentFirst = true

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(state.days, id: \.id) { day in
                    Section(header: DateView(date: day.date, format: .journalStyle)) {
                        ForEach(day.tasks, id: \.id) { task in
                            HStack {
                                Image(systemName: "arrow.down.circle")
                                    .foregroundColor(task.isExportable ? .mint : .secondary)
                                    .font(.title2)
                                    .help(task.isExportable ? "Omit from export" : "Include in export")
                                    .onTapGesture {
                                        state.update(task: task.id, isExportable: !task.isExportable)
                                    }

                                Text(task.task)
                                    .foregroundColor(task.isExportable ? .primary : .secondary)

                                Spacer()
                                HStack {
                                    ForEach(task.tags, id: \.id) { tag in
                                        TagBadgeView(tag: tag)
                                            .font(.caption)
                                            .opacity(task.isExportable ? 1 : 0.5)
                                    }
                                }
                            }
                            .lineLimit(1)
                        }
                    }
                }
            }
            .listStyle(.inset(alternatesRowBackgrounds: true))
            WeeklyViewStats(focus: state.focus, count: state.completedTasks, exportableCount: state.exportableTasks)
        }
        .frame(minWidth: 350, idealWidth: 350)
        .alert(state.error?.localizedDescription ?? "Error", isPresented: $state.showAlert) {}
        .onAppear { state.focus(on: date) }
        .onChange(of: showAllTasks) { isVisible in state.toggle(visible: isVisible) }
        .onChange(of: showMostRecentFirst) { isMostRecent in state.resort(mostRecentFirst: isMostRecent) }
        .toolbar {
            Spacer()

            Menu {
                Toggle("Show all tasks", isOn: $showAllTasks)
                Divider()
                Toggle("Most recent first", isOn: $showMostRecentFirst)
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }

            Menu {
                Button("Export this week") {
                    state.exportWeek()
                }
                Button("Export all weeks") {
                    state.exportAll()
                }
            } label: {
                Image(systemName: "square.and.arrow.down")
            }
                .help("Export weekly work task report")
        }
    }
}

struct WeeklyView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyView(date: Date())
    }
}
