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
            print("⚠️ Mouse monitoring already active")
            return 
        }
        
        // Request accessibility permissions if not already granted
        if !AXIsProcessTrusted() {
            print("⚠️ No accessibility permissions - attempting to request...")
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
            
            if !accessEnabled {
                print("❌ Accessibility permission required for global mouse monitoring")
                print("💡 Please go to System Settings > Privacy & Security > Accessibility and enable VolumeScroll")
                return
            } else {
                print("✅ Accessibility permissions granted!")
            }
        } else {
            print("✅ Accessibility permissions already granted")
        }
        
        // Create global event monitor for scroll wheel events
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
            self?.handleScrollEvent(event)
        }
        
        _isMonitoring = true
        print("✅ Mouse event monitoring started")
    }
    
    func stopMonitoring() {
        guard _isMonitoring else { return }
        
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        
        _isMonitoring = false
        print("🛑 Mouse event monitoring stopped")
    }
    
    private func handleScrollEvent(_ event: NSEvent) {
        // Get mouse location in screen coordinates
        let mouseLocation = NSEvent.mouseLocation
        
        // Check if we have meaningful scroll delta (ignore tiny movements)
        let deltaY = event.scrollingDeltaY
        
        // Only process significant scroll movements
        if abs(deltaY) > 0.1 {
            print("🖱️ Scroll detected: deltaY=\(deltaY) at \(mouseLocation)")
            delegate?.didDetectScrollEvent(deltaY: deltaY, at: mouseLocation)
        }
    }
    
    deinit {
        stopMonitoring()
    }
}
