//
//  VolumeScrollApp.swift
//  VolumeScroll
//
//  Created by Ofir Segal-Prizat on 10/09/2025.
//

import SwiftUI
import AppKit

@main
struct VolumeScrollApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, MouseEventMonitorDelegate {
    private var statusBarItem: NSStatusItem?
    private let mouseMonitor = MouseEventMonitor()
    private let volumeManager = VolumeManager.shared
    private let areaDetector = AreaDetector.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from dock since this is a menu bar app
        NSApp.setActivationPolicy(.accessory)
        
        print("🚀 VolumeScroll launching...")
        
        setupStatusBar()
        print("📊 Status bar setup completed")
        
        // Check accessibility permissions first
        let hasPermissions = AXIsProcessTrusted()
        print("🔒 Accessibility permissions check: \(hasPermissions)")
        
        if hasPermissions {
            setupMouseMonitoring()
            print("✅ VolumeScroll started successfully with accessibility permissions")
        } else {
            print("⚠️ VolumeScroll started but needs accessibility permissions")
            // Don't show alert immediately, let user click the menu item instead
        }
    }
    
    private func setupStatusBar() {
        print("📊 Creating status bar item...")
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let statusButton = statusBarItem?.button {
            // Use a more visible icon and force it to show
            let icon = NSImage(systemSymbolName: "speaker.wave.2", accessibilityDescription: "Volume Control") ?? NSImage(systemSymbolName: "speaker.2", accessibilityDescription: "Volume Control")
            statusButton.image = icon
            statusButton.imagePosition = .imageOnly
            statusButton.toolTip = "VolumeScroll - Control volume by scrolling over Dock/Menu Bar"
            statusBarItem?.isVisible = true
            statusBarItem?.length = NSStatusItem.squareLength
            print("🔊 Status bar button created with speaker icon")
        } else {
            print("❌ Failed to create status bar button")
        }
        
        setupMenu()
        
        // Update volume display periodically
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateVolumeDisplay()
            self?.updateMenuItems()
        }
        
        print("📊 Status bar setup complete")
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        // Volume indicator
        let volumeItem = NSMenuItem(title: "Volume: \(Int(volumeManager.getCurrentVolume() * 100))%", action: nil, keyEquivalent: "")
        volumeItem.isEnabled = false
        menu.addItem(volumeItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Toggle monitoring - show status based on permissions
        let hasPermissions = AXIsProcessTrusted()
        let toggleTitle = hasPermissions ? "Volume Control: Enabled" : "Grant Accessibility Permission"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(toggleMonitoring), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        // Debug info
        let debugItem = NSMenuItem(title: "Debug: Permissions = \(hasPermissions)", action: #selector(recheckPermissions), keyEquivalent: "")
        debugItem.target = self
        menu.addItem(debugItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Settings
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        // Quit
        let quitItem = NSMenuItem(title: "Quit VolumeScroll", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusBarItem?.menu = menu
    }
    
    private func setupMouseMonitoring() {
        mouseMonitor.delegate = self
        mouseMonitor.startMonitoring()
    }
    
    @objc private func toggleMonitoring() {
        let hasPermissions = AXIsProcessTrusted()
        print("🔄 Toggle monitoring clicked. Permissions: \(hasPermissions)")
        
        if !hasPermissions {
            showPermissionsAlert()
        } else {
            // Restart mouse monitoring
            mouseMonitor.stopMonitoring()
            setupMouseMonitoring()
            print("🔄 Mouse monitoring restarted")
        }
    }
    
    @objc private func recheckPermissions() {
        let hasPermissions = AXIsProcessTrusted()
        print("🔍 Recheck permissions: \(hasPermissions)")
        
        if hasPermissions && !mouseMonitor.isMonitoring {
            setupMouseMonitoring()
        }
        
        updateMenuItems()
    }
    
    @objc private func openSettings() {
        // Open settings window
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quitApp() {
        mouseMonitor.stopMonitoring()
        NSApp.terminate(self)
    }
    
    private func showPermissionsAlert() {
        let alert = NSAlert()
        alert.messageText = "VolumeScroll Needs Accessibility Access"
        alert.informativeText = "To control volume with mouse scrolling, VolumeScroll needs accessibility permissions.\n\nClick 'Open Settings' to grant permissions, then restart the app."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Later")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
    
    private func updateVolumeDisplay() {
        guard let menu = statusBarItem?.menu,
              let volumeItem = menu.items.first else { return }
        
        let currentVolume = volumeManager.getCurrentVolume()
        volumeItem.title = "Volume: \(Int(currentVolume * 100))%"
    }
    
    private func updateMenuItems() {
        guard let menu = statusBarItem?.menu,
              menu.items.count > 2 else { return }
        
        let hasPermissions = AXIsProcessTrusted()
        
        // Update toggle item (index 2)
        if let toggleItem = menu.items[safe: 2] {
            toggleItem.title = hasPermissions ? "Volume Control: Enabled" : "Grant Accessibility Permission"
        }
        
        // Update debug item (index 3)
        if let debugItem = menu.items[safe: 3] {
            debugItem.title = "Debug: Permissions = \(hasPermissions)"
        }
    }
    
    // MARK: - MouseEventMonitorDelegate
    
    func didDetectScrollEvent(deltaY: CGFloat, at location: NSPoint) {
        let detectedArea = areaDetector.detectArea(at: location)
        
        // Only respond to scroll events over the Dock or Menu Bar
        guard detectedArea == .dock || detectedArea == .menuBar else { return }
        
        // Calculate volume adjustment (positive deltaY = scroll up = increase volume)
        let volumeAdjustment: Float = Float(deltaY) * 0.01  // Adjust sensitivity as needed
        
        // Apply volume change
        volumeManager.adjustVolume(delta: volumeAdjustment)
        
        // Optional: Provide visual feedback
        let areaName = detectedArea == .dock ? "Dock" : "Menu Bar"
        let volumePercent = Int(volumeManager.getCurrentVolume() * 100)
        print("Volume adjusted to \(volumePercent)% via \(areaName)")
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }
}
