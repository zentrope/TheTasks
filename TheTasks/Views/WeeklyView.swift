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

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                DateView(date: state.focus.startOfWeek(), format: .nameMonthDayYear)
                Spacer()
                DateView(date: state.focus.endOfWeek(), format: .nameMonthDayYear)
            }
            .lineLimit(1)
            .font(.taskHeading)
            .foregroundColor(.secondary)
            .padding()
            .background(.background)

            List {
                ForEach(state.days, id: \.id) { day in
                    Section(header: DateView(date: day.id, format: .journalStyle)) {
                        ForEach(day.tasks, id: \.id) { task in
                            HStack {

                                if task.isExportable {
                                    Image(systemName: "square.and.arrow.down")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                        .help("Click to omit from export")
                                        .onTapGesture {
                                            state.update(task: task.id, isExportable: false)
                                        }

                                } else {
                                    Image(systemName: "hand.raised.slash")
                                        .foregroundColor(.secondary)
                                        .font(.title2)
                                        .help("Click to include in export")
                                        .onTapGesture {
                                            state.update(task: task.id, isExportable: true)
                                        }
                                }

                                Text(task.task)
                                    //.foregroundColor(task.isExportable ? .primary : .secondary)

                                Spacer()
                                DateView(date: task.created, format: .dateShort)
                                    .foregroundColor(.blue)
                                    .font(.callout.weight(.thin))
                            }
                            .lineLimit(1)
                        }
                    }
                }
            }
            WeeklyViewStats(focus: state.focus, count: state.completedTasks, exportableCount: state.exportableTasks)
        }
        .frame(minWidth: 350, idealWidth: 350)
        .alert(state.error?.localizedDescription ?? "Error", isPresented: $state.showAlert) {}
        .onAppear {
            state.focus(on: date)
        }
        .onChange(of: state.showAllTasks) { visible in
            state.toggle(visible: visible)
        }
        .toolbar {
            Spacer()
            Menu {
                Toggle("Show all tasks", isOn: $state.showAllTasks)
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }

            Button {
                state.export()
            } label: {
                Image(systemName: "square.and.arrow.down")
            }
            .help("Export weekly task report")
        }
    }
}

struct WeeklyView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyView(date: Date())
    }
}
