//
//  ReminderListView.swift
//  SwiftUI_MQTT
//
//  Created by Ale Alfaro on 6/17/24.
//

import SwiftUI

struct CalEventRowView: View {
    var event : CalEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(event.title)
                .foregroundColor(.primary)
                .font(.headline)
            HStack(spacing: 3) {
                if #available(iOS 15.0, *) {
                    VStack {
                        Text(event.startDate, format: .dateTime.hour().minute().day().month())
                        Text(event.endDate, format: .dateTime.hour().minute().day().month())
                    }
                } else {
                    Text(event.startDate.description)
                    Text(event.endDate.description)
                    // Fallback on earlier versions
                }
            }
            .foregroundColor(.secondary)
            .font(.subheadline)
        }
    }
}


struct CalEventsListView: View {
    var events: [CalEvent]
    
    var body: some View {
        List {
            ForEach(events) { event in
                CalEventRowView(event: event)
            }
        }
    }
}

#Preview {
    CalEventsListView(events: CalEvent.sampleData)
}
