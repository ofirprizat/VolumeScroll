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
    private var dockScreen: NSScreen?          // Screen where the dock is located
    
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
            // Ensure a minimum menu bar height
            if menuBarHeight < 20 {
                menuBarHeight = 24.0
            }
        }
        
        // Detect dock position and approximate size
        detectDockConfiguration()
    }
    
    private func detectDockConfiguration() {
        // Find which screen has the dock by checking all screens
        // The dock is on the screen where visibleFrame differs from frame
        for screen in NSScreen.screens {
            let screenFrame = screen.frame
            let visibleFrame = screen.visibleFrame
            
            // Check for dock at bottom
            if visibleFrame.minY > screenFrame.minY + 1 {
                dockPosition = .bottom
                dockHeight = visibleFrame.minY - screenFrame.minY
                dockScreen = screen
                return
            }
            
            // Check for dock on left
            if visibleFrame.minX > screenFrame.minX + 1 {
                dockPosition = .left
                dockHeight = visibleFrame.minX - screenFrame.minX
                dockScreen = screen
                return
            }
            
            // Check for dock on right
            if visibleFrame.maxX < screenFrame.maxX - 1 {
                dockPosition = .right
                dockHeight = screenFrame.maxX - visibleFrame.maxX
                dockScreen = screen
                return
            }
        }
        
        // Default to main screen with bottom dock if can't determine
        dockPosition = .bottom
        dockHeight = 64.0
        dockScreen = NSScreen.main
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
    
    /// Find the screen containing the given point
    private func screenContaining(point: NSPoint) -> NSScreen? {
        for screen in NSScreen.screens {
            if screen.frame.contains(point) {
                return screen
            }
        }
        return nil
    }
    
    func detectArea(at point: NSPoint) -> DetectedArea {
        // Find which screen contains the mouse pointer
        guard let screen = screenContaining(point: point) else {
            return .other
        }
        
        let screenFrame = screen.frame
        
        // Check if point is in menu bar area (menu bar exists on all screens when "Displays have separate Spaces" is enabled)
        if isPointInMenuBar(point, screen: screen) {
            return .menuBar
        }
        
        // Check if point is in dock area (dock only exists on one screen)
        if isPointInDock(point, screenFrame: screenFrame, screen: screen) {
            return .dock
        }
        
        return .other
    }
    
    private func isPointInMenuBar(_ point: NSPoint, screen: NSScreen) -> Bool {
        let screenFrame = screen.frame
        
        // Calculate menu bar height for this specific screen
        let screenMenuBarHeight = screenFrame.height - screen.visibleFrame.maxY
        let effectiveMenuBarHeight = max(screenMenuBarHeight, 24.0) // Ensure minimum height
        
        let menuBarRect = NSRect(
            x: screenFrame.minX,
            y: screenFrame.maxY - effectiveMenuBarHeight,
            width: screenFrame.width,
            height: effectiveMenuBarHeight
        )
        
        return menuBarRect.contains(point)
    }
    
    private func isPointInDock(_ point: NSPoint, screenFrame: NSRect, screen: NSScreen) -> Bool {
        // Check dock area on ANY screen (dock can move between screens in macOS)
        // Use a reasonable dock height for screens where dock isn't currently visible
        let effectiveDockHeight = (screen == dockScreen) ? dockHeight : 70.0
        
        let dockRect: NSRect
        
        switch dockPosition {
        case .bottom:
            dockRect = NSRect(
                x: screenFrame.minX,
                y: screenFrame.minY,
                width: screenFrame.width,
                height: effectiveDockHeight
            )
        case .left:
            dockRect = NSRect(
                x: screenFrame.minX,
                y: screenFrame.minY,
                width: effectiveDockHeight,
                height: screenFrame.height - menuBarHeight
            )
        case .right:
            dockRect = NSRect(
                x: screenFrame.maxX - effectiveDockHeight,
                y: screenFrame.minY,
                width: effectiveDockHeight,
                height: screenFrame.height - menuBarHeight
            )
        }
        
        return dockRect.contains(point)
    }
    
    // Helper method for debugging
    func getAreaInfo() -> String {
        var info = "Screens:\n"
        for (index, screen) in NSScreen.screens.enumerated() {
            let isDockScreen = screen == dockScreen
            info += """
            Screen \(index)\(isDockScreen ? " (Dock)" : ""):
              Frame: \(screen.frame)
              Visible: \(screen.visibleFrame)
            
            """
        }
        info += """
        Menu Bar Height: \(menuBarHeight)
        Dock Position: \(dockPosition)
        Dock Height/Width: \(dockHeight)
        """
        return info
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
