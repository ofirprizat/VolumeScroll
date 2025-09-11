//
//  VolumeManager.swift
//  VolumeScroll
//
//  Created by Ofir Segal-Prizat on 10/09/2025.
//

import Foundation
import CoreAudio

class VolumeManager {
    static let shared = VolumeManager()
    
    private var audioDeviceID: AudioDeviceID?
    
    private init() {
        setupAudioDevice()
    }
    
    private func setupAudioDevice() {
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
            self.audioDeviceID = deviceID
        } else {
            print("Failed to get default audio device: \(status)")
        }
    }
    
    func getCurrentVolume() -> Float {
        guard let deviceID = audioDeviceID else { return 0.0 }
        
        var volume: Float32 = 0.0
        var volumeSize: UInt32 = UInt32(MemoryLayout<Float32>.size)
        
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &volumeSize,
            &volume
        )
        
        if status == noErr {
            return volume
        } else {
            print("Failed to get volume: \(status)")
            return 0.0
        }
    }
    
    func setVolume(_ volume: Float) {
        guard let deviceID = audioDeviceID else { return }
        
        let clampedVolume = max(0.0, min(1.0, volume))
        var newVolume: Float32 = clampedVolume
        let volumeSize: UInt32 = UInt32(MemoryLayout<Float32>.size)
        
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectSetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            volumeSize,
            &newVolume
        )
        
        if status != noErr {
            print("Failed to set volume: \(status)")
        }
    }
    
    func adjustVolume(delta: Float) {
        let currentVolume = getCurrentVolume()
        let newVolume = currentVolume + delta
        setVolume(newVolume)
    }
    
    func increaseVolume(by amount: Float = 0.05) {
        adjustVolume(delta: amount)
    }
    
    func decreaseVolume(by amount: Float = 0.05) {
        adjustVolume(delta: -amount)
    }
    
    func isMuted() -> Bool {
        guard let deviceID = audioDeviceID else { return false }
        
        var isMuted: UInt32 = 0
        var mutedSize: UInt32 = UInt32(MemoryLayout<UInt32>.size)
        
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &mutedSize,
            &isMuted
        )
        
        return status == noErr ? isMuted != 0 : false
    }
    
    func setMuted(_ muted: Bool) {
        guard let deviceID = audioDeviceID else { return }
        
        var muteValue: UInt32 = muted ? 1 : 0
        let mutedSize: UInt32 = UInt32(MemoryLayout<UInt32>.size)
        
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectSetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            mutedSize,
            &muteValue
        )
        
        if status != noErr {
            print("Failed to set mute state: \(status)")
        }
    }
}
