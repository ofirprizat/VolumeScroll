//
//  AreaDetector.swift
//  VolumeScroll
//
//  Created by Ofir Segal-Prizat on 10/09/2025.
//

import Foundation
import AppKit

enum DetectedArea {
    case dock
    case menuBar
    case other
}

class AreaDetector {
    static let shared = AreaDetector()
    
    private var menuBarHeight: CGFloat = 24.0  // Default menu bar height
    private var dockHeight: CGFloat = 64.0     // Estimated dock height
    private var dockPosition: DockPosition = .bottom
    
    private enum DockPosition {
        case bottom, left, right
    }
    
    private init() {
        updateSystemMetrics()
        observeSystemChanges()
    }
    
    private func updateSystemMetrics() {
        // Get menu bar height from main screen
        if let mainScreen = NSScreen.main {
            menuBarHeight = mainScreen.frame.height - mainScreen.visibleFrame.maxY
        }
        
        // Detect dock position and approximate size
        detectDockConfiguration()
    }
    
    private func detectDockConfiguration() {
        guard let mainScreen = NSScreen.main else { return }
        
        let screenFrame = mainScreen.frame
        let visibleFrame = mainScreen.visibleFrame
        
        // Determine dock position based on visible frame differences
        if visibleFrame.minY > screenFrame.minY {
            // Dock is at bottom
            dockPosition = .bottom
            dockHeight = visibleFrame.minY - screenFrame.minY
        } else if visibleFrame.minX > screenFrame.minX {
            // Dock is on the left
            dockPosition = .left
            dockHeight = visibleFrame.minX - screenFrame.minX
        } else if visibleFrame.maxX < screenFrame.maxX {
            // Dock is on the right  
            dockPosition = .right
            dockHeight = screenFrame.maxX - visibleFrame.maxX
        } else {
            // Default to bottom if can't determine
            dockPosition = .bottom
            dockHeight = 64.0
        }
    }
    
    private func observeSystemChanges() {
        // Observe screen configuration changes
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateSystemMetrics()
        }
    }
    
    func detectArea(at point: NSPoint) -> DetectedArea {
        guard let mainScreen = NSScreen.main else { return .other }
        
        let screenFrame = mainScreen.frame
        
        // Check if point is in menu bar area
        if isPointInMenuBar(point, screenFrame: screenFrame) {
            return .menuBar
        }
        
        // Check if point is in dock area
        if isPointInDock(point, screenFrame: screenFrame) {
            return .dock
        }
        
        return .other
    }
    
    private func isPointInMenuBar(_ point: NSPoint, screenFrame: NSRect) -> Bool {
        let menuBarRect = NSRect(
            x: screenFrame.minX,
            y: screenFrame.maxY - menuBarHeight,
            width: screenFrame.width,
            height: menuBarHeight
        )
        
        return menuBarRect.contains(point)
    }
    
    private func isPointInDock(_ point: NSPoint, screenFrame: NSRect) -> Bool {
        let dockRect: NSRect
        
        switch dockPosition {
        case .bottom:
            dockRect = NSRect(
                x: screenFrame.minX,
                y: screenFrame.minY,
                width: screenFrame.width,
                height: dockHeight
            )
        case .left:
            dockRect = NSRect(
                x: screenFrame.minX,
                y: screenFrame.minY,
                width: dockHeight,
                height: screenFrame.height - menuBarHeight
            )
        case .right:
            dockRect = NSRect(
                x: screenFrame.maxX - dockHeight,
                y: screenFrame.minY,
                width: dockHeight,
                height: screenFrame.height - menuBarHeight
            )
        }
        
        return dockRect.contains(point)
    }
    
    // Helper method for debugging
    func getAreaInfo() -> String {
        guard let mainScreen = NSScreen.main else { return "No screen available" }
        
        let screenFrame = mainScreen.frame
        let visibleFrame = mainScreen.visibleFrame
        
        return """
        Screen: \(screenFrame)
        Visible: \(visibleFrame)
        Menu Bar Height: \(menuBarHeight)
        Dock Position: \(dockPosition)
        Dock Height/Width: \(dockHeight)
        """
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
