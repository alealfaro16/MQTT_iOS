//
//  ContentView.swift
//  SwiftUI_MQTT
//
//  Created by Anoop M on 2021-01-19.
//

import SwiftUI
import SwiftyJSON

@available(iOS 15.0, *)
struct MessagesView: View {
    // TODO: Remove singleton
    @StateObject var mqttManager = MQTTManager.shared()
    var body: some View {
        NavigationView {
            MessageView()
        }
        .environmentObject(mqttManager)
    }
}

@available(iOS 15.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}

@available(iOS 15.0, *)
struct MessageView: View {
    @State var topic: String = ""
    @State var publishTopic: String = ""
    @State var message: String = ""
    @State var badgerMessage: String = ""
    
    @State var reminders: [Reminder] = []
    @State var events: [CalEvent] = []
    private var reminderStore: ReminderStore { ReminderStore.shared }
    
    let initialBrokerAddress : String = "192.168.4.32"
    let badgerPubTopic : String = "TNG/badger/TPC/Badger/req"
    let badgerSubTopic : String = "TNG/badger/TPC/Badger/state"
    @EnvironmentObject private var mqttManager: MQTTManager
    
    var body: some View {
        VStack {
            ConnectionStatusBar(message: mqttManager.connectionStateMessage(), isConnected: mqttManager.isConnected())
            Text("Basic Commands")
            VStack {
                HStack {
                    MQTTTextField(placeHolderMessage: "Enter a topic to publish to", isDisabled: !mqttManager.isConnected(), message: $publishTopic)
                }
                
                HStack {
                    MQTTTextField(placeHolderMessage: "Enter a message", isDisabled: publishTopic.isEmpty, message: $message)
                    Button(action: { send(message: message) }) {
                        Text("Send").font(.body)
                    }.buttonStyle(BaseButtonStyle(foreground: .white, background: .green))
                        .frame(width: 80)
                        .disabled(publishTopic.isEmpty || message.isEmpty)
                }
                Text("Badger2040 Commands")
                HStack {
                    MQTTTextField(placeHolderMessage: "Enter a message to send to badger", isDisabled: !mqttManager.isConnected(), message: $badgerMessage)
                    Button(action: { sendToBadger(message: badgerMessage) }) {
                        Text("Send").font(.body)
                    }.buttonStyle(BaseButtonStyle(foreground: .white, background: .green))
                        .frame(width: 80)
                        .disabled(badgerMessage.isEmpty)
                }
                
                if #available(iOS 16.0, *) {
                    TextField("", text: $mqttManager.currentAppState.historyText, axis: .vertical)
                        .padding()
                        .border(.black)
                        .lineLimit(20...30)
                } else {
                    // Fallback on earlier versions
                    MessageHistoryTextView(text: $mqttManager.currentAppState.historyText).frame(height: 450)
                }
            }.padding(EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7))
            Spacer()
        }
        .navigationTitle("Messages")
        .navigationBarItems(leading: NavigationLink(destination: SyncView(reminders: reminders, events: events),
                            label: {
                            Image(systemName: "paperplane")
        }), trailing:
            NavigationLink(destination: SettingsView(brokerAddress: mqttManager.currentHost() ?? initialBrokerAddress),
                            label: {
                            Image(systemName: "gear")
            })
        )
        .task {
            await prepareReminderStore()
        }
        .onAppear {
            if (!mqttManager.isInitialized()) {
                mqttManager.initializeBadger(brokerAddress: initialBrokerAddress, pubTopic: badgerPubTopic, subTopic: badgerSubTopic)
            }
        }
    }

    private func send(message: String) {
        mqttManager.publishToTopic(topic: self.publishTopic, message: message)
        self.message = ""
    }
    
    private func sendToBadger(message: String) {
        mqttManager.sendMessageToBadger(message: message)
        badgerMessage = ""
    }
    
    func prepareReminderStore() async {
        do {
            try await reminderStore.requestAccess(type: .reminder)
            try await reminderStore.requestAccess(type: .event)
            reminders = try await reminderStore.readIncompleteReminders()
            events = try await reminderStore.readCalendarEvents()
        } catch MQTTAppError.accessDenied, MQTTAppError.accessRestricted {
            #if DEBUG
            reminders = Reminder.sampleData
            events = CalEvent.sampleData
            #endif
        } catch {
            showError(error)
        }
    }
    
    func showError(_ error: Error) {
        let alertTitle = NSLocalizedString("Error", comment: "Error alert title")
        let alert = UIAlertController(
            title: alertTitle, message: error.localizedDescription, preferredStyle: .alert)
        let actionTitle = NSLocalizedString("OK", comment: "Alert OK button title")
        alert.addAction(
            UIAlertAction(
                title: actionTitle, style: .default) {
                    (UIAlertAction) in
                })
        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alert, animated: true, completion: nil)
    }
}
