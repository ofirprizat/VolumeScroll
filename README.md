# VolumeScroll

🔊 **macOS menu bar app for volume control via mouse scroll over Dock/Menu Bar**

Simply scroll your mouse while hovering over the Dock or Menu Bar to adjust your system volume - no need to reach for volume keys!

## ✨ Features

- **🖱️ Intuitive Control**: Scroll up/down over Dock or Menu Bar to increase/decrease volume
- **🎯 Smart Detection**: Automatically detects Dock position (bottom, left, right) and Menu Bar location
- **🖥️ Multi-Monitor Support**: Works on all connected displays - scroll on any monitor's menu bar or dock area
- **🎧 Universal Audio**: Works with all audio output devices (built-in speakers, Bluetooth headphones, external speakers, AirPods, etc.)
- **📊 Real-time Display**: Menu bar dropdown shows current volume percentage, updates live as you scroll
- **🔒 Privacy Focused**: Runs locally, no network access required
- **🚀 Lightweight**: Minimal resource usage, runs silently in background

## 🎮 How to Use

1. **Hover** your mouse over the Dock (bottom/sides of screen) or Menu Bar (top of screen)
2. **Scroll up** with mouse wheel or trackpad → Volume increases 🔊
3. **Scroll down** with mouse wheel or trackpad → Volume decreases 🔉
4. **Click** the speaker icon in menu bar → View current volume and access options

## 🛠️ Installation

### Requirements
- macOS 14.0 or later
- Xcode 15+ (for building from source)
- Accessibility permissions (app will guide you through setup)

### Option 1: Build with Xcode

1. Clone this repository:
   ```bash
   git clone https://github.com/ofirprizat/VolumeScroll.git
   cd VolumeScroll
   ```

2. Open `VolumeScroll.xcodeproj` in Xcode

3. Build and run the project (⌘+R)

4. Grant accessibility permissions when prompted (see [Permissions](#-permissions) section)

### Option 2: Build from Command Line

1. Clone this repository:
   ```bash
   git clone https://github.com/ofirprizat/VolumeScroll.git
   cd VolumeScroll
   ```

2. Build a Release version:
   ```bash
   xcodebuild -project VolumeScroll.xcodeproj -scheme VolumeScroll -configuration Release build
   ```

3. Copy to Applications folder:
   ```bash
   cp -R ~/Library/Developer/Xcode/DerivedData/VolumeScroll-*/Build/Products/Release/VolumeScroll.app /Applications/
   ```

4. Launch the app:
   ```bash
   open /Applications/VolumeScroll.app
   ```

5. Grant accessibility permissions (see [Permissions](#-permissions) section)

### Optional: Auto-start at Login

To have VolumeScroll start automatically when you log in:

1. Open **System Settings** → **General** → **Login Items**
2. Click the **"+"** button
3. Select **VolumeScroll** from your Applications folder

## 🔒 Permissions

VolumeScroll requires **Accessibility** permissions to monitor global mouse events. This allows the app to detect scroll gestures over the Dock and Menu Bar.

### Granting Permissions

1. When you first launch VolumeScroll, macOS may prompt you to grant Accessibility access
2. If not prompted automatically, go to:
   - **System Settings** → **Privacy & Security** → **Accessibility**
3. Click the **"+"** button
4. Navigate to and select **VolumeScroll.app** (from `/Applications/` or wherever you installed it)
5. Make sure the toggle next to VolumeScroll is **ON**
6. Restart the app if it was already running

### Important Notes

- If you rebuild the app, you may need to **remove and re-add** it in Accessibility settings (each build has a different code signature)
- The app will show "Volume Control: Enabled" in the menu bar dropdown when permissions are correctly configured

### Privacy

The app:
- ✅ Runs entirely locally on your Mac
- ✅ No network access required or used
- ✅ No data collection or telemetry
- ✅ Fully open source

## 🏗️ Architecture

### Core Components

- **`VolumeManager`**: System volume control using AppleScript for universal device compatibility
- **`MouseEventMonitor`**: Global mouse scroll event detection with accessibility permissions
- **`AreaDetector`**: Smart detection of mouse position over Dock/Menu Bar regions on all monitors
- **`SettingsView`**: SwiftUI settings interface for user configuration

### Technical Details

- **SwiftUI + AppKit**: Modern UI with native macOS integration
- **AppleScript Volume Control**: Uses `set volume output volume` for universal audio device support (works with Bluetooth, USB, and all other audio outputs)
- **Global Event Monitoring**: Captures scroll events system-wide with proper accessibility permissions
- **Multi-Monitor Support**: Dynamically detects screen configurations and responds to scroll events on any display

## 🎛️ Configuration

Access the menu by clicking the speaker icon in the menu bar:

- **Volume Display**: Shows current system volume percentage (updates in real-time)
- **Volume Control Status**: Shows whether accessibility permissions are granted
- **Settings**: Access additional configuration options
- **Quit**: Exit the application

## 🤝 Contributing

Contributions welcome! Areas for improvement:

- [ ] Configurable scroll sensitivity
- [ ] Custom hotkey support
- [ ] Volume limit settings
- [ ] Visual feedback animations (on-screen display)
- [ ] Per-app volume control

### Development Setup

1. Fork and clone the repository
2. Open in Xcode 15+
3. Build and run (⌘+R)
4. Make your changes
5. Test thoroughly (especially multi-monitor and different audio devices)
6. Submit a pull request

## 📝 License

MIT License - feel free to use and modify as needed.

## 🙏 Acknowledgments

Built with:
- Swift & SwiftUI
- AppKit for menu bar integration
- AppleScript for universal volume control
- Accessibility APIs for global event monitoring

---

**Enjoy effortless volume control!** 🎵✨
