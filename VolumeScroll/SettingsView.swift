//
//  SettingsView.swift
//  VolumeScroll
//
//  Created by Ofir Segal-Prizat on 10/09/2025.
//

import SwiftUI
import AppKit

struct SettingsView: View {
    @State private var volumeSensitivity: Double = 1.0
    @State private var enableDockControl: Bool = true
    @State private var enableMenuBarControl: Bool = true
    @State private var currentVolume: Float = 0.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: "speaker.2")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text("VolumeScroll")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Control system volume by scrolling over Dock or Menu Bar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Current Volume Display
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Volume")
                    .font(.headline)
                
                HStack {
                    Image(systemName: currentVolume > 0.5 ? "speaker.3" : currentVolume > 0 ? "speaker.1" : "speaker.slash")
                        .foregroundColor(.blue)
                    
                    Text("\(Int(currentVolume * 100))%")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
            }
            
            Divider()
            
            // Volume Control Areas
            VStack(alignment: .leading, spacing: 12) {
                Text("Enable Volume Control")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Dock Area", isOn: $enableDockControl)
                    Toggle("Menu Bar Area", isOn: $enableMenuBarControl)
                }
                .padding(.leading)
            }
            
            Divider()
            
            // Sensitivity Setting
            VStack(alignment: .leading, spacing: 12) {
                Text("Scroll Sensitivity")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Low")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(value: $volumeSensitivity, in: 0.1...3.0, step: 0.1)
                        
                        Text("High")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Current: \(String(format: "%.1f", volumeSensitivity))x")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading)
                }
            }
            
            Divider()
            
            // Permissions Info
            VStack(alignment: .leading, spacing: 8) {
                Text("Permissions")
                    .font(.headline)
                
                HStack {
                    Image(systemName: AXIsProcessTrusted() ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(AXIsProcessTrusted() ? .green : .orange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Accessibility Access")
                            .font(.subheadline)
                        
                        Text(AXIsProcessTrusted() ? "Granted" : "Required for global mouse monitoring")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if !AXIsProcessTrusted() {
                        Button("Open System Settings") {
                            openAccessibilitySettings()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            
            Spacer()
            
            // Footer
            HStack {
                Text("Tip: Scroll up to increase volume, scroll down to decrease volume")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding(24)
        .frame(width: 480, height: 400)
        .onAppear {
            updateVolumeDisplay()
            
            // Set up timer to update volume display
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                updateVolumeDisplay()
            }
        }
    }
    
    private func updateVolumeDisplay() {
        currentVolume = VolumeManager.shared.getCurrentVolume()
    }
    
    private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}
