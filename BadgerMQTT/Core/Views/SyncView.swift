//
//  SyncView.swift
//  SwiftUI_MQTT
//
//  Created by Ale Alfaro on 6/18/24.
//

import SwiftUI

struct SyncView: View {
    var reminders: [Reminder]
    var events: [CalEvent]
    @EnvironmentObject private var mqttManager: MQTTManager
    var body: some View {
        VStack{
            ConnectionStatusBar(message: mqttManager.connectionStateMessage(), isConnected: mqttManager.isConnected())
            Text("Reminders")
            ReminderListView(reminders: reminders)
            Text("Events")
            CalEventsListView(events: events)
            setUpSyncButton()
        }
        .frame(maxHeight: 800)
        .padding()
        .navigationTitle("Sync")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func setUpSyncButton() -> some View  {
        return Button(action: { if #available(iOS 15.0, *) {
            syncAll()
        } else {
            // Fallback on earlier versions
        } }) {
                Text("Sync")
            }.buttonStyle(BaseButtonStyle(foreground: .white, background: .blue))
            .disabled(!mqttManager.currentAppState.appConnectionState.isConnected)
        .frame(width: 150)
    }
    
    @available(iOS 15.0, *)
    private func syncAll(){
        mqttManager.sendRemindersToBadger(reminders: reminders)
        mqttManager.sendEventsToBadger(events: events)
    }
}

#Preview {
    SyncView(reminders: Reminder.sampleData, events: CalEvent.sampleData)
        .environmentObject(MQTTManager.shared())
}
