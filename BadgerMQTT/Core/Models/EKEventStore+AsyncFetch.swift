//
//  EKEventStore+AsyncFetch.swift
//  Today
//
//  Created by Ale Alfaro on 6/17/24.
//

import EventKit
import Foundation


extension EKEventStore {
    func reminders(matching predicate: NSPredicate) async throws -> [EKReminder] {
        try await withCheckedThrowingContinuation { continuation in
            fetchReminders(matching: predicate) { reminders in
                if let reminders {
                    continuation.resume(returning: reminders)
                } else {
                    continuation.resume(throwing: MQTTAppError.failedReadingReminders)
                }
            }
        }
    }
}
