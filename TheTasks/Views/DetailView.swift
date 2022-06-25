//
//  DetailView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/22/22.
//

import SwiftUI

struct DetailView: View {

    @EnvironmentObject private var state: AppViewState
    @FocusState private var focusedTask: FocusTask?

    var body: some View {
        VStack(spacing: 0) {
            DetailTitleView(date: state.focusDate)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background)

            List(selection: $state.selectedTask) {
                ForEach(state.tasks, id: \.id) { task in
                    if state.isFocusedOnToday {
                        TaskItemView(task: task)
                            .padding(4)
                    } else {
                        PastTaskItem(task: task, focusDate: state.focusDate)
                            .padding(4)
                    }
                }
            }

            Divider()
            TaskStatsView()
        }
        .listStyle(.inset(alternatesRowBackgrounds: false))
        .alert(state.error?.localizedDescription ?? "Error", isPresented: $state.showAlert) {}
        .onChange(of: state.focusedTask) { focus in
            focusedTask = focus
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
