//
//  MouseEventMonitor.swift
//  VolumeScroll
//
//  Created by Ofir Segal-Prizat on 10/09/2025.
//

import Foundation
import AppKit
import Carbon

protocol MouseEventMonitorDelegate: AnyObject {
    func didDetectScrollEvent(deltaY: CGFloat, at location: NSPoint)
}

class MouseEventMonitor {
    weak var delegate: MouseEventMonitorDelegate?
    private var eventMonitor: Any?
    private var _isMonitoring = false
    
    var isMonitoring: Bool {
        return _isMonitoring
    }
    
    init() {}
    
    func startMonitoring() {
        guard !_isMonitoring else { 
            NSLog("⚠️ Mouse monitoring already active")
            return 
        }
        
        // Request accessibility permissions if not already granted
        if !AXIsProcessTrusted() {
            NSLog("⚠️ No accessibility permissions - attempting to request...")
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
            
            if !accessEnabled {
                NSLog("❌ Accessibility permission required for global mouse monitoring")
                NSLog("💡 Please go to System Settings > Privacy & Security > Accessibility and enable VolumeScroll")
                return
            } else {
                NSLog("✅ Accessibility permissions granted!")
            }
        } else {
            NSLog("✅ Accessibility permissions already granted")
        }
        
        // Create global event monitor for scroll wheel events
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
            self?.handleScrollEvent(event)
        }
        
        _isMonitoring = true
        NSLog("✅ Mouse event monitoring started")
    }
    
    func stopMonitoring() {
        guard _isMonitoring else { return }
        
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        
        _isMonitoring = false
        NSLog("🛑 Mouse event monitoring stopped")
    }
    
    private func handleScrollEvent(_ event: NSEvent) {
        // Get mouse location in screen coordinates
        let mouseLocation = NSEvent.mouseLocation
        
        // Check if we have meaningful scroll delta (ignore tiny movements)
        let deltaY = event.scrollingDeltaY
        
        NSLog("🖱️ handleScrollEvent called: deltaY=%f at %@", deltaY, mouseLocation.debugDescription)
        
        // Only process significant scroll movements
        if abs(deltaY) > 0.1 {
            NSLog("🖱️ Scroll significant - calling delegate")
            delegate?.didDetectScrollEvent(deltaY: deltaY, at: mouseLocation)
        }
    }
    
    deinit {
        stopMonitoring()
    }
}
