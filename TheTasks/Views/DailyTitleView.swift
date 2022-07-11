//
//  DailyTitleView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/24/22.
//

import SwiftUI

struct DailyTitleView: View {
    var date: Date

    var body: some View {
        HStack(alignment: .center) {
            Text("Available")
                .font(.taskHeading)
                .foregroundColor(.accentColor)

            Spacer()
            DateView(date: date, format: .dateNameMedium)
                .font(.taskHeading)
                .foregroundColor(.secondary)
        }
    }
}

struct DetailTitleView_Previews: PreviewProvider {
    static var previews: some View {
        DailyTitleView(date: Date())
    }
}
