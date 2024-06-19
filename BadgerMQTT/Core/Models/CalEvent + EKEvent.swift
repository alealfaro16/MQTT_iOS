//
//  Reminder+EKReminder.swift
//  Today
//
//  Created by Ale Alfaro on 6/17/24.
//

import EventKit
import Foundation


extension CalEvent {
    init(with ekEvent: EKEvent) throws {
        guard let start = ekEvent.startDate, let end = ekEvent.endDate
        else {
            throw MQTTAppError.eventHasNoStartOrEndDate
        }
        id = ekEvent.calendarItemIdentifier
        title = ekEvent.title
        startDate = start
        endDate = end
        notes = ekEvent.notes
    }
}
