# VolumeScroll

🔊 **macOS menu bar app for volume control via mouse scroll over Dock/Menu Bar**

Simply scroll your mouse while hovering over the Dock or Menu Bar to adjust your system volume - no need to reach for volume keys!

## ✨ Features

- **🖱️ Intuitive Control**: Scroll up/down over Dock or Menu Bar to increase/decrease volume
- **🎯 Smart Detection**: Automatically detects Dock position (bottom, left, right) and Menu Bar location
- **📊 Real-time Display**: Menu bar icon shows current volume percentage
- **⚙️ Settings Panel**: Adjust scroll sensitivity and monitor permissions
- **🔒 Privacy Focused**: Runs locally, no network access required
- **🚀 Lightweight**: Minimal resource usage, runs silently in background

## 🎮 How to Use

1. **Hover** your mouse over the Dock (bottom/sides of screen) or Menu Bar (top of screen)
2. **Scroll up** with mouse wheel or trackpad → Volume increases 🔊
3. **Scroll down** with mouse wheel or trackpad → Volume decreases 🔉
4. **Click** the speaker icon in menu bar → Access settings and current volume

## 🛠️ Installation

### Requirements
- macOS 14.0 or later
- Accessibility permissions (app will guide you through setup)

### Install from Source
1. Clone this repository:
   ```bash
   git clone https://github.com/ofirprizat/VolumeScroll.git
   cd VolumeScroll
   ```

2. Open `VolumeScroll.xcodeproj` in Xcode

3. Build and run the project (⌘+R)

4. Grant accessibility permissions when prompted:
   - System Settings → Privacy & Security → Accessibility
   - Add VolumeScroll and toggle it ON

5. The app will appear in your menu bar as a speaker icon 🔊

## 🏗️ Architecture

### Core Components

- **`VolumeManager`**: Core Audio integration for system volume control
- **`MouseEventMonitor`**: Global mouse scroll event detection with accessibility permissions
- **`AreaDetector`**: Smart detection of mouse position over Dock/Menu Bar regions
- **`SettingsView`**: SwiftUI settings interface for user configuration

### Technical Details

- **SwiftUI + AppKit**: Modern UI with native macOS integration
- **Core Audio APIs**: Direct system volume control without external dependencies
- **Global Event Monitoring**: Captures scroll events system-wide with proper permissions
- **Dynamic Area Detection**: Adapts to different Dock positions and screen configurations

## 🔒 Permissions

VolumeScroll requires **Accessibility** permissions to monitor global mouse events. This allows the app to detect scroll gestures over the Dock and Menu Bar. 

The app:
- ✅ Runs locally on your Mac
- ✅ No network access
- ✅ No data collection
- ✅ Open source code

## 🎛️ Configuration

Access settings by clicking the menu bar icon:

- **Volume Display**: Shows current system volume percentage
- **Sensitivity Control**: Adjust scroll sensitivity (future feature)
- **Permission Status**: Monitor accessibility permissions
- **Debug Info**: View current permission status

## 🤝 Contributing

Contributions welcome! Areas for improvement:

- [ ] Configurable scroll sensitivity
- [ ] Custom hotkey support  
- [ ] Multiple monitor support
- [ ] Volume limit settings
- [ ] Visual feedback animations

## 📝 License

MIT License - feel free to use and modify as needed.

## 🙏 Acknowledgments

Built with:
- Swift & SwiftUI
- Core Audio Framework
- Accessibility APIs
- AppKit for menu bar integration

---

**Enjoy effortless volume control!** 🎵✨
