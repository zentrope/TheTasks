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
            List {
                ForEach(state.days, id: \.id) { day in
                    Section(header: DateView(date: day.id, format: .journalStyle)) {
                        ForEach(day.tasks, id: \.id) { task in
                            HStack {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                    .font(.title2)
                                Text(task.task)

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
            WeeklyViewStats(focus: state.focus, count: state.completedTasks)
        }
        .frame(minWidth: 350, idealWidth: 350)
        .alert(state.error?.localizedDescription ?? "Error", isPresented: $state.showAlert) {}
        .onAppear {
            state.focus(on: date)
        }
        .toolbar {
            Spacer()
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
