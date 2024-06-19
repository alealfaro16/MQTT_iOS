//
//  SettingsView.swift
//  SwiftUI_MQTT
//
//  Created by Anoop M on 2021-01-20.
//

import SwiftUI

struct SettingsView: View {
    @State var brokerAddress: String = ""
    @State var topic: String = ""
    @EnvironmentObject private var mqttManager: MQTTManager
    
    var body: some View {
        
        VStack {
            ConnectionStatusBar(message: mqttManager.connectionStateMessage(), isConnected: mqttManager.isConnected())
            MQTTTextField(placeHolderMessage: "Enter broker Address", isDisabled: mqttManager.currentAppState.appConnectionState != .disconnected, message: $brokerAddress)
                .padding(EdgeInsets(top: 0.0, leading: 7.0, bottom: 0.0, trailing: 7.0))
            HStack(spacing: 50) {
                setUpConnectButton()
                setUpDisconnectButton()
            }
            .padding()
            HStack {
                MQTTTextField(placeHolderMessage: "Enter a topic to subscribe", isDisabled: !mqttManager.isConnected() || mqttManager.isSubscribed(), message: $topic)
                Button(action: functionFor(state: mqttManager.currentAppState.appConnectionState)) {
                    Text(titleForSubscribButtonFrom(state: mqttManager.currentAppState.appConnectionState))
                        .font(.system(size: 14.0))
                }.buttonStyle(BaseButtonStyle(foreground: .white, background: .green))
                    .frame(width: 100)
                    .disabled(!mqttManager.isConnected() || topic.isEmpty)
            }
            Spacer()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Configure / enable /disable connect button
    private func setUpConnectButton() -> some View  {
        return Button(action: { configureAndConnect() }) {
                Text("Connect")
            }.buttonStyle(BaseButtonStyle(foreground: .white, background: .blue))
        .disabled(mqttManager.currentAppState.appConnectionState != .disconnected || brokerAddress.isEmpty)
    }
    
    private func setUpDisconnectButton() -> some View  {
        return Button(action: { disconnect() }) {
            Text("Disconnect")
        }.buttonStyle(BaseButtonStyle(foreground: .white, background: .red))
        .disabled(mqttManager.currentAppState.appConnectionState == .disconnected)
    }
    private func configureAndConnect() {
        // Initialize the MQTT Manager
        mqttManager.initializeMQTT(host: brokerAddress, identifier: UUID().uuidString)
        // Connect
        mqttManager.connect()
    }

    private func disconnect() {
        mqttManager.disconnect()
    }
    
    private func subscribe(topic: String) {
        mqttManager.subscribe(topic: topic)
    }

    private func usubscribe() {
        mqttManager.unSubscribeFromCurrentTopic()
    }
    
    private func titleForSubscribButtonFrom(state: MQTTAppConnectionState) -> String {
        switch state {
        case .connected, .connectedUnSubscribed, .disconnected, .connecting:
            return "Subscribe"
        case .connectedSubscribed:
            return "Unsubscribe"
        }
    }
    
    private func functionFor(state: MQTTAppConnectionState) -> () -> Void {
        switch state {
        case .connected, .connectedUnSubscribed, .disconnected, .connecting:
            return { subscribe(topic: topic) }
        case .connectedSubscribed:
            return { usubscribe() }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(MQTTManager.shared())
    }
}
