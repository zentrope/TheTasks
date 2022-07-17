//
//  AvailableView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/22/22.
//

import SwiftUI

struct AvailableView: View {

    @EnvironmentObject private var state: AppViewState
    
    var body: some View {
        VStack(spacing: 0) {
            //DailyTitleView(date: Date())
            Text("Available")
                .font(.taskHeading)
                .foregroundColor(.accentColor)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background)

            List(selection: $state.selectedTask) {
                ForEach(state.tasks, id: \.id) { task in
                    TaskItemView(task: task)
                        .padding(2)                        
                }
            }
            
            TaskStatsView()
        }
        .listStyle(.inset(alternatesRowBackgrounds: false))
        .frame(minWidth: 350, idealWidth: 350)
        .alert(state.error?.localizedDescription ?? "Error", isPresented: $state.showAlert) {}

        .toolbar {

            Button(action: { state.createNewTask() }, label: { Image(systemName: "plus") })

            Spacer()

            // Using toggles like this doesn't feel like the right way to go, but leaving this in until I see something better. I think a segmented controll for all, today and today+completed is more reasonable.
            Toggle(isOn: $state.showCompleted) {
                // MACOS13: use checklist.checked and checklist.unchecked
                Image(systemName: state.showCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                    .frame(width: 15)
            }
            .help("Show completed")

            Toggle(isOn: $state.showToday) {
                Image(systemName: state.showToday ? "clock.fill" : "clock")
                    .frame(width: 15)
            }
            .help("Show today only")
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        AvailableView()
    }
}
