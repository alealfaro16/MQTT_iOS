//
//  ReminderStore.swift
//  Today
//
//  Created by Ale Alfaro on 6/17/24.
//

import EventKit
import Foundation


final class ReminderStore {
    static let shared = ReminderStore()


    private let ekStore = EKEventStore()


    var isAvailable: Bool {
        EKEventStore.authorizationStatus(for: .reminder) == .authorized
    }
    
    var isAvailableCal: Bool {
        EKEventStore.authorizationStatus(for: .event) == .authorized
    }
    
    func requestAccess(type : EKEntityType) async throws {
        let status = EKEventStore.authorizationStatus(for: type)
        switch status {
        case .authorized:
            return
        case .restricted:
            throw MQTTAppError.accessRestricted
        case .notDetermined:
            let accessGranted = try await ekStore.requestAccess(to: type)
            guard accessGranted else {
                throw MQTTAppError.accessDenied
            }
        case .denied:
            throw MQTTAppError.accessDenied
        @unknown default:
            throw MQTTAppError.unknown
        }
    }
    
    func readAll() async throws -> [Reminder] {
        guard isAvailable else {
            throw MQTTAppError.accessDenied
        }


        let predicate = ekStore.predicateForReminders(in: nil)
        let ekReminders = try await ekStore.reminders(matching: predicate)
        let reminders: [Reminder] = try ekReminders.compactMap { ekReminder in
            do {
                return try Reminder(with: ekReminder)
            } catch MQTTAppError.reminderHasNoDueDate {
                return nil
            }
        }
        return reminders
    }
    
    @available(iOS 15.0, *)
    func readCalendarEvents() async throws -> [CalEvent] {
        
        guard isAvailableCal else {
            throw MQTTAppError.accessDenied
        }
        
        // Get the appropriate calendar.
        var calendar = Calendar.current


        // Create the start date components
        var oneDayAgoComponents = DateComponents()
        oneDayAgoComponents.day = -1
        var oneDayAgo = calendar.date(byAdding: oneDayAgoComponents, to: Date(), wrappingComponents: false)


        // Create the end date components.
        var oneYearFromNowComponents = DateComponents()
        oneYearFromNowComponents.day = 3
        var oneYearFromNow = calendar.date(byAdding: oneYearFromNowComponents, to: Date(), wrappingComponents: false)


        // Create the predicate from the event store's instance method.
        var predicate: NSPredicate? = nil
        if let anAgo = oneDayAgo, let aNow = oneYearFromNow {
            predicate = ekStore.predicateForEvents(withStart: Date(), end: aNow, calendars: nil)
        }


        // Fetch all events that match the predicate.
        if let aPredicate = predicate {
            let events = ekStore.events(matching: aPredicate)
            let filteredEvents : [CalEvent] = events.compactMap { event in
                
                if event.isAllDay { return nil }
                
                do {
                    return try CalEvent(with: event);
                }
                catch {
                    return nil
                }
                
            }
            
//            for event in filteredEvents {
//                print("Event description: ", event.title)
//                print("Start date: ", event.startDate.formatted(date: .numeric, time: .shortened))
//                print("End date: ", event.endDate.formatted(date: .numeric, time: .shortened))
//            }
            
            return filteredEvents
        }
        
        return []
    }
    
    func readIncompleteReminders() async throws -> [Reminder] {
        guard isAvailable else {
            throw MQTTAppError.accessDenied
        }


        //let cal = ekStore.calendars(for: .reminder).first
        let predicate = ekStore.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: nil)
        let ekReminders = try await ekStore.reminders(matching: predicate)
        let reminders: [Reminder] = try ekReminders.compactMap { ekReminder in
            do {
                return try Reminder(with: ekReminder)
            } catch MQTTAppError.reminderHasNoDueDate {
                return nil
            }
        }
        return reminders
    }
    
}
