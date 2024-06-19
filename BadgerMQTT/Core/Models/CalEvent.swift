//
//  CalEvent.swift
//  SwiftUI_MQTT
//
//  Created by Ale Alfaro on 6/18/24.
//

import Foundation

struct CalEvent: Equatable, Identifiable {
    var id: String = UUID().uuidString
    var title: String
    var startDate: Date
    var endDate: Date
    var notes: String? = nil
}

extension [CalEvent] {
    func indexOfReminder(withId id: CalEvent.ID) -> Self.Index {
        guard let index = firstIndex(where: { $0.id == id }) else {
            fatalError()
        }
        return index
    }
}

#if DEBUG
extension CalEvent {
    static var sampleData = [
        CalEvent(
            title: "Submit reimbursement report", startDate: Date().addingTimeInterval(800.0),
            endDate: Date().addingTimeInterval(860.0)),
        CalEvent(
            title: "Code Review", startDate: Date().addingTimeInterval(900.0),
            endDate: Date().addingTimeInterval(960.0)),
        CalEvent(
            title: "Pick up new contacts", startDate: Date().addingTimeInterval(1000.0),
            endDate: Date().addingTimeInterval(1050.0)),
        CalEvent(
            title: "Add notes to retrospective", startDate: Date().addingTimeInterval(2000.0),
            endDate: Date().addingTimeInterval(2100.0)),
    ]
}
#endif
