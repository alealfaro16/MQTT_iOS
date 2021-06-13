//
//  ContentView.swift
//  SwiftUI_MQTT
//
//  Created by Anoop M on 2021-01-19.
//

import SwiftUI

struct ContentView: View {
    // TODO: Remove singleton
    @StateObject var mqttManager = MQTTManager.shared()
    var body: some View {
        NavigationView {
            Text("Hello, world!")
                .padding()
                .navigationTitle("Messages")
                .navigationBarItems(trailing: NavigationLink(
                    destination: SettingsView(),
                    label: {
                        Image(systemName: "gear")
                    }))
        }
        .environmentObject(mqttManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}