# MikuFans

A Flutter-based anime player application for multiple platforms.

## Features

- **Multi-platform Support**: Windows, macOS, Linux, Android, and iOS
- **Media Playback**: High-quality video playback with hardware acceleration support
- **Theme Support**: Light, dark, and system theme modes
- **System Tray Integration**: Minimize to system tray for convenient access
- **Hardware Acceleration**: Optimized video decoding for better performance
- **Search Functionality**: Easy to search and discover anime content
- **History Tracking**: Keep track of your viewing history
- **Subscription Management**: Subscribe to your favorite anime

## Supported Platforms

- ✅ Windows x86
- ✅ Windows ARM
- ✅ macOS (Intel and Apple Silicon)
- ✅ Linux (Debian-based and Red Hat-based distributions)

## Installation

### From GitHub Releases

1. Visit the [GitHub Releases](https://github.com/qiqd/flutter_mikufans/releases) page
2. Download the appropriate installer for your platform
3. Follow the installation instructions for your platform

### Building from Source

```bash
# Clone the repository
git clone https://github.com/qiqd/flutter_mikufans.git
cd flutter_mikufans

# Install dependencies
flutter pub get

# Build for your platform
flutter build <platform> --release
```

Replace `<platform>` with `windows`, `macos`, `linux`, `android`, or `ios`.

## Usage

1. Launch the application
2. Use the navigation rail on the left to access different features:
   - **Search**: Search for anime content
   - **Subscribe**: Manage your subscriptions
   - **History**: View your viewing history
   - **Settings**: Configure application settings
3. Click on any anime to view details and start watching
4. Use the player controls to play/pause, adjust volume, and navigate episodes

## Settings

### Playback Settings

- **Auto Play Next Episode**: Automatically plays the next episode when the current one ends
- **Hardware Acceleration**: Uses hardware acceleration for better video decoding performance (recommended)

### System Settings

- **Minimize to Tray**: Minimizes the application to the system tray instead of closing it (requires application restart to take effect)

### Interface Settings

- **Theme Mode**: Choose between light, dark, or system theme modes

### Other

- **About**: View application information, version, and licensing details
- **Check for Updates**: Verify if you're running the latest version of the application

## Technologies Used

- **Framework**: Flutter 3.38.4
- **Routing**: go_router ^17.0.1
- **Network Requests**: dio ^5.9.0
- **Media Playback**: media_kit ^1.2.6
- **Local Storage**: shared_preferences ^2.5.4
- **Window Management**: window_manager ^0.5.1
- **System Tray**: tray_manager ^0.5.2
- **HTML Parsing**: html ^0.15.6
- **Encryption**: encrypt ^5.0.3

## License

This project is licensed under the AGPL-3.0 License. See the [LICENSE](LICENSE) file for details.

## Terms of Use

1. This application is for learning and communication purposes only
2. All resources are sourced from the internet
3. This application does not store any personal information
4. Commercial use is prohibited
5. By using this application, you agree to all terms and conditions
6. If you have any objections to the content, please stop using it immediately

---

© 2025 MikuFans
