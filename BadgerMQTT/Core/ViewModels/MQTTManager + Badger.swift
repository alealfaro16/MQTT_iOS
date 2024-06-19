//
//  MQTTAppState + Badger.swift
//  SwiftUI_MQTT
//
//  Created by Ale Alfaro on 6/17/24.
//

import SwiftUI
import SwiftyJSON

extension MQTTManager {
    
    func initializeBadger(brokerAddress: String, pubTopic: String, subTopic: String) {
        badgerPubTopic = pubTopic
        badgerSubTopic = subTopic
        // Initialize the MQTT Manager
        initializeMQTT(host: brokerAddress, identifier: UUID().uuidString)
        // Connect
        connect()
    }
    
    @available(iOS 15.0, *)
    func sendRemindersToBadger(reminders : [Reminder]) {
        
        if (badgerPubTopic.isEmpty) {
            print("Badger pub topic hasn't been set")
            return
        }
        
        var remindersJSON : Array<JSON> = []
        for reminder in reminders {
            //Need to modify time string due to weird character being insert by formatted(date: .omitted, time: .shortened) between number and PM/AM
            let components = Calendar.current.dateComponents([.hour, .minute], from: reminder.dueDate)
            let hour = components.hour ?? 0
            let dueDateStr =  reminder.dueDate.formatted(date: .omitted, time: .shortened)
            let index = dueDateStr.index(dueDateStr.endIndex, offsetBy: -3)
            var modifiedString = dueDateStr.prefix(upTo: index)
            if (hour > 11) {
                modifiedString += " PM"
            }
            else {
                modifiedString += " AM"
            }
            //let reminderJson = ["title" : reminder.title, "date" : reminder.dueDate.formatted(date: .abbreviated, time: .omitted), "time" : modifiedString] as [String : Any]
            let json = JSON(["title" : reminder.title, "date" : reminder.dueDate.formatted(date: .abbreviated, time: .omitted), "time" : modifiedString])
            remindersJSON.append(json)
        }
        
        
        let json = JSON(["reminders": remindersJSON])
        if let rawString = json.rawString() {
            //print("sending reminder: ", rawString)
            publishToTopic(topic: badgerPubTopic, message: rawString)
        } else {
            print("json.rawString is nil")
        }
    }
    
    @available(iOS 15.0, *)
    func sendEventsToBadger(events : [CalEvent]) {
        
        if (badgerPubTopic.isEmpty) {
            print("Badger pub topic hasn't been set")
            return
        }
        
        var eventsJSON : Array<JSON> = []
        for event in events {
            //Need to modify time string due to weird character being insert by formatted(date: .omitted, time: .shortened) between number and PM/AM
            let components = Calendar.current.dateComponents([.hour, .minute], from: event.startDate)
            let hour = components.hour ?? 0
            let startDateStr =  event.startDate.formatted(date: .omitted, time: .shortened)
            let index = startDateStr.index(startDateStr.endIndex, offsetBy: -3)
            var modifiedString = startDateStr.prefix(upTo: index)
            if (hour > 11) {
                modifiedString += " PM"
            }
            else {
                modifiedString += " AM"
            }
            //let reminderJson = ["title" : reminder.title, "date" : reminder.dueDate.formatted(date: .abbreviated, time: .omitted), "time" : modifiedString] as [String : Any]
            let json = JSON(["title" : event.title, "date" : event.startDate.formatted(date: .abbreviated, time: .omitted), "time" : modifiedString])
            eventsJSON.append(json)
        }
        
        
        let json = JSON(["cal events": eventsJSON])
        if let rawString = json.rawString() {
            //print("sending events: ", rawString)
            publishToTopic(topic: badgerPubTopic, message: rawString)
        } else {
            print("json.rawString is nil")
        }
    }
    
    func sendMessageToBadger(message: String) {
        
        if (badgerPubTopic.isEmpty) {
            print("Badger pub topic hasn't been set")
            return
        }
        
        let json = JSON(["message": message])
        if let rawString = json.rawString() {
            publishToTopic(topic: badgerPubTopic, message: rawString)
        } else {
            print("json.rawString is nil")
        }
    }
}
