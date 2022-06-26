//
//  DetailView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/22/22.
//

import SwiftUI

struct DetailView: View {

    @EnvironmentObject private var state: AppViewState

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

            TaskStatsView()
        }
        .listStyle(.inset(alternatesRowBackgrounds: false))
        .frame(minWidth: 350, idealWidth: 350)
        .alert(state.error?.localizedDescription ?? "Error", isPresented: $state.showAlert) {}
        .toolbar { [unowned state] in
            // Using unowned here because I head a rumor that .toolbar retains stuff. Doing this seems to reduce memory leaks when the view is re-created after being completely swapped out. Declaring toolbar items inline here is worse.
            TodayToolbar(state: state)
        }

    }

    @State private var selectedDate: Date = Date()
    @State private var showPicker = false

    @available(macOS, deprecated: 13, message: "Verify toolbar workaround still necessary")
    @ToolbarContentBuilder
    func TodayToolbar(state: AppViewState) -> some ToolbarContent {
        // Using this rather than in-lining the toolbar items seems to prevent the memory leak that happens when the toolbar is recreated after switch back from another view in the application. Revisit this with macos 13.

        ToolbarItemGroup {
            Button(action: { state.createNewTask() }, label: { Image(systemName: "plus") })

            Button {
                showPicker.toggle()
            } label: {
                Image(systemName: "calendar")

            }
            .popover(isPresented: $showPicker) {
                VStack(alignment: .center, spacing: 10) {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.graphical)
                    Button {
                        state.gotoToday()
                    } label: {
                        Label("Today", systemImage: "calendar")
                    }
                }
                .padding()
            }
            .onChange(of: selectedDate) { newDate in
                // TODO: get rid of state.focusDate
                state.focusDate = newDate
            }

            Spacer()
            ControlGroup {
                Button(action: { state.goBackOneDay() }, label: { Image(systemName: "chevron.backward") })
                    .help("Show yesterday's tasks")

                Button("Today", action: { state.gotoToday() })
                    .help("Show today's tasks")

                Button(action: { state.goForwardOneDay() }, label: { Image(systemName: "chevron.forward") })
                    .help("Show tomorrow's tasks")
                    .disabled(state.isFocusedOnToday)
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
