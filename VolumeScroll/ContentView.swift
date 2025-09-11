//
//  ContentView.swift
//  VolumeScroll
//
//  Created by Ofir Segal-Prizat on 10/09/2025.
//

import SwiftUI

// This file is kept for potential future use but not currently used in the app
// The main UI is now handled through the status bar menu and settings window

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "speaker.2")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("VolumeScroll")
                .font(.title)
            Text("This app runs in the menu bar")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
