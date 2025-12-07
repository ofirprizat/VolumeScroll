//
//  VolumeManager.swift
//  VolumeScroll
//
//  Created by Ofir Segal-Prizat on 10/09/2025.
//

import Foundation
import CoreAudio
import AudioToolbox
import Cocoa

class VolumeManager {
    static let shared = VolumeManager()
    
    private var listenerBlock: AudioObjectPropertyListenerBlock?
    
    private init() {
        setupDeviceChangeListener()
        NSLog("VolumeManager initialized")
    }
    
    deinit {
        removeDeviceChangeListener()
    }
    
    /// Get the current default output device dynamically
    private func getDefaultOutputDevice() -> AudioDeviceID? {
        var deviceID: AudioDeviceID = 0
        var deviceSize: UInt32 = UInt32(MemoryLayout<AudioDeviceID>.size)
        
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &deviceSize,
            &deviceID
        )
        
        if status == noErr {
            return deviceID
        } else {
            NSLog("Failed to get default audio device: %d", status)
            return nil
        }
    }
    
    /// Setup listener for default output device changes
    private func setupDeviceChangeListener() {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        listenerBlock = { (_, _) in
            NSLog("Default audio output device changed")
        }
        
        AudioObjectAddPropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            DispatchQueue.main,
            listenerBlock!
        )
    }
    
    /// Remove device change listener
    private func removeDeviceChangeListener() {
        guard let block = listenerBlock else { return }
        
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        AudioObjectRemovePropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            DispatchQueue.main,
            block
        )
    }
    
    // MARK: - Get Current Volume (using AppleScript - most reliable)
    
    func getCurrentVolume() -> Float {
        let script = NSAppleScript(source: "output volume of (get volume settings)")
        var error: NSDictionary?
        let result = script?.executeAndReturnError(&error)
        
        if let error = error {
            NSLog("getCurrentVolume AppleScript error: %@", error)
            return 0.0
        }
        
        if let volumeInt = result?.int32Value {
            let volume = Float(volumeInt) / 100.0
            return volume
        }
        
        return 0.0
    }
    
    // MARK: - Set Volume (using AppleScript - works with all devices)
    
    func setVolume(_ volume: Float) {
        let clampedVolume = max(0.0, min(1.0, volume))
        let volumePercent = Int(clampedVolume * 100)
        
        NSLog("setVolume called: target=%d%%", volumePercent)
        
        let script = NSAppleScript(source: "set volume output volume \(volumePercent)")
        var error: NSDictionary?
        script?.executeAndReturnError(&error)
        
        if let error = error {
            NSLog("setVolume AppleScript error: %@", error)
        } else {
            NSLog("setVolume succeeded: %d%%", volumePercent)
        }
    }
    
    func adjustVolume(delta: Float) {
        let currentVolume = getCurrentVolume()
        let newVolume = currentVolume + delta
        NSLog("adjustVolume: current=%d%%, delta=%f, new=%d%%", Int(currentVolume * 100), delta, Int(newVolume * 100))
        setVolume(newVolume)
    }
    
    func increaseVolume(by amount: Float = 0.05) {
        adjustVolume(delta: amount)
    }
    
    func decreaseVolume(by amount: Float = 0.05) {
        adjustVolume(delta: -amount)
    }
    
    // MARK: - Mute Control (using AppleScript)
    
    func isMuted() -> Bool {
        let script = NSAppleScript(source: "output muted of (get volume settings)")
        var error: NSDictionary?
        let result = script?.executeAndReturnError(&error)
        
        if let error = error {
            NSLog("isMuted AppleScript error: %@", error)
            return false
        }
        
        return result?.booleanValue ?? false
    }
    
    func setMuted(_ muted: Bool) {
        let mutedString = muted ? "true" : "false"
        let script = NSAppleScript(source: "set volume output muted \(mutedString)")
        var error: NSDictionary?
        script?.executeAndReturnError(&error)
        
        if let error = error {
            NSLog("setMuted AppleScript error: %@", error)
        }
    }
    
    func toggleMute() {
        setMuted(!isMuted())
    }
}
