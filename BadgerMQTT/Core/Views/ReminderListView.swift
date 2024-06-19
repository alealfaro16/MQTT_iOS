//
//  ReminderListView.swift
//  SwiftUI_MQTT
//
//  Created by Ale Alfaro on 6/17/24.
//

import SwiftUI

struct ReminderRowView: View {
    var reminder: Reminder

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(reminder.title)
                .foregroundColor(.primary)
                .font(.headline)
            HStack(spacing: 3) {
                if #available(iOS 15.0, *) {
                    Text(reminder.dueDate.formatted(date: .abbreviated, time: .omitted))
                    Text(reminder.dueDate.formatted(date: .omitted, time: .shortened))
                } else {
                    Label(reminder.dueDate.description, systemImage: "phone")
                    // Fallback on earlier versions
                }
            }
            .foregroundColor(.secondary)
            .font(.subheadline)
        }
    }
}


struct ReminderListView: View {
    var reminders: [Reminder]
    
    var body: some View {
        List {
            ForEach(reminders) { reminder in
                ReminderRowView(reminder: reminder)
            }
        }
    }
}

#Preview {
    ReminderListView(reminders: Reminder.sampleData)
}
