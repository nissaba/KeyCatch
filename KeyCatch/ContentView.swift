//
//  ContentView.swift
//  KeyCatch
//
//  Created by Pascale on 2026-01-04.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var tap: GlobalEventTap = GlobalEventTap()
    @State private var latestEvent: String = "No Event"

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(latestEvent)
        }
        .padding()
        .onReceive(tap.$event.receive(on: DispatchQueue.main)) { value in
            latestEvent = value
        }
        .onAppear {
            tap.start()
        }
        .onDisappear() {
            tap.stop()
        }
    }
}

#Preview {
    ContentView()
}
