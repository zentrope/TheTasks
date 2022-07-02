//
//  TaskIcon.swift
//  TheTasks
//
//  Created by Keith Irwin on 7/2/22.
//

import SwiftUI

struct TaskIcon: View {

    var status: TaskMO.TaskStatus

    var body: some View {
        switch status {
            case .completed:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.mint)
                    .help("Completed")

            case .cancelled:
                Image(systemName: "slash.circle.fill")
                    .foregroundColor(.pink)
                    .help("Cancelled")

            case .pending:
                Image(systemName: "circle")
                    .help("Pending")
        }
    }
}

struct TaskIcon_Previews: PreviewProvider {
    static var previews: some View {
        TaskIcon(status: .completed)
    }
}
