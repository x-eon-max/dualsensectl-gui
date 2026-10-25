# 🎮 DualSense Expressive (`dualsensectl-gui` v2.0)

[![Platform](https://img.shields.io/badge/Platform-Linux%20%28Wayland%20%2F%20X11%29-blue.svg)](https://kernel.org)
[![Language](https://img.shields.io/badge/Language-C%2B%2B20-blue.svg)](https://en.cppreference.com/w/cpp/20)
[![Qt](https://img.shields.io/badge/GUI-Qt6%20QML%20(SceneGraph)-41CD52.svg)](https://qt.io)
[![Design](https://img.shields.io/badge/Design-Material%203%20Expressive-purple.svg)](https://m3.material.io)
[![Backend](https://img.shields.io/badge/Backend-dualsensectl%20v0.7.0-purple.svg)](https://github.com/nowrep/dualsensectl)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> A modern, fluid, and native Linux desktop manager for **Sony PlayStation 5 DualSense** and **DualSense Edge** controllers, built from the ground up with the **Material 3 Expressive** design system in **C++20 & Qt6 / QML**.  
> Provides granular real-time control over adaptive triggers, RGB lightbar calibration, battery telemetry, audio routing, and hardware microphone controls powered by [`dualsensectl`](https://github.com/nowrep/dualsensectl).

---

## 🎨 Design System: Material 3 Expressive

### 🌟 Visual Experience & Micro-Interactions
- **Deep OLED Gaming Palette:** Rich black backgrounds (`#0B0D13`), tiered surface containers (`surfaceContainerLowest` through `surfaceContainerHighest`), and high contrast ratios tailored for gaming rigs.
- **Dynamic Ambient Glows:** The ambient aura radiating behind the controller and header cards dynamically reacts in real-time to the color and brightness emitted by the DualSense Touchpad lightbar.
- **Expressive Shapes & Geometry:** Pill buttons and chips (`radius: 9999`), curved surface cards (`radius: 28px`), animated battery gauges, and pill sliders with floating numeric tooltip bubbles.
- **Spring & Elastic Micro-Interactions:** Smooth physics-based transitions (`Easing.OutBack` / `Easing.OutCubic`) on hover, button presses, mode changes, and trigger adjustments.

### 🕹 Interactive DualSense Visualizer
- **Real-Time Vector Controller Model:**
  - **RGB Lightbar Wings:** Dynamically illuminate with the exact RGB hue and brightness configured in the lighting studio.
  - **Player Number LEDs (1 to 5):** Centered white indicators beneath the touchpad synced with player assignment.
  - **Microphone Mute LED:** Illuminates in PlayStation official amber when the hardware microphone is muted.
  - **L2 / R2 Triggers:** Highlighted during trigger testing, actuation, and profile tuning.

### 📈 Live Adaptive Trigger Waveform Graph
- **Dynamic Force / Displacement Profile:** Plots the exact mechanical resistance curve in real time according to the active mode (firearm hammer break, elastic bow tension, machine recoil pulses, galloping rhythm, solid resistance wall) with an animated finger pressure probe.

---

## ⚡ Key Capabilities

1. **Central Dashboard:**
   - Real-time battery telemetry, animated charge indicator, and power status (`discharging`, `charging`, `full`).
   - Connection status badge (`Bluetooth` or `USB` with `/dev/hidraw*` interface path).
   - Instant quick actions: 1-click hardware mic mute, volume slider, lightbar toggle, and Bluetooth power-off.
   - Hardware & firmware diagnostics (`Firmware version`, `Build number`).

2. **Adaptive Triggers Studio:**
   - Flexible target selection: Left trigger (L2), Right trigger (R2), or Both (L2 + R2).
   - Gaming presets: *Semi-Auto Handgun, Heavy Shotgun, Sniper Resistance, Compound Bow, Heavy Machine Gun, Horse Gallop, Engine Vibration*.
   - **Exhaustive support for all 7 `dualsensectl` trigger modes:**
     - `off`: Free trigger travel with standard spring tension.
     - `feedback`: Solid resistance wall starting at a custom position with adjustable strength.
     - `weapon`: Firearm trigger simulation (take-up start, sudden wall resistance, and crisp break).
     - `bow`: Progressive tension ramp simulating a drawn bowstring with snap release force.
     - `machine`: Rapid burst recoil alternating between two strength levels at set frequencies and periods.
     - `galloping`: Rhythmic two-beat gallop cadence.
     - `vibration`: Continuous haptic oscillation around a defined travel position.

3. **RGB Lighting & Player LEDs Studio:**
   - **High-Performance HSV Color Wheel:** Real-time 60 FPS Canvas rendering with circular hue ring and saturation disk.
   - **Direct HEX Input:** Live color preview pill and hex string indicator (`#388BFF`, etc.).
   - **Official Sony Color Palettes:** *PS5 Blue, Neon Cyan, Cosmic Red, Nova Pink, Galactic Purple, Astro White, Emerald Green, Stealth Amber*.
   - **Master Lightbar Brightness Slider (0-255).**
   - **Player Number LEDs (0 to 5) and Dimming Controls (Bright, Medium, Dim).**

4. **Audio, Microphone & Haptics Control:**
   - Dedicated expressive card to toggle hardware microphone mute with glowing amber indicator.
   - Microphone LED state selector (`off`, `on`, `pulse`).
   - Microphone usage modes (`chat`, `asr`, `both`).
   - Speaker output routing (`headphone`, `internal`, `both`) and master volume slider (0-255).
   - **Haptic & Vibration Attenuation (0-7):** Independently attenuate voice-coil rumble motors and trigger vibrations.

5. **1-Click Gaming Profiles Manager:**
   - Pre-configured profiles ready to play:
     - 🎯 **Competitive FPS** (Hair-trigger break stop, attenuated rumble for aiming precision, mic muted).
     - 🏎 **Sim Racing Pro** (Firm brake pedal resistance on L2, progressive throttle tension on R2).
     - 🏹 **RPG Hunter & Bow** (Heavy bowstring draw with crisp snap release, emerald green aura).
     - 💥 **Heavy Gunner** (Continuous machine recoil, maximum haptics, cyber amber).
     - 🎬 **Cinematic Immersion** (Smooth triggers, cosmic violet ambient glow, headphone routing).
     - 🔋 **Stealth Battery Saver** (LEDs turned off, mic muted, triggers disengaged for maximum battery longevity).
   - Save custom user profiles with 1 click directly to `~/.config/dualsense-expressive/profiles.json`.

6. **Built-in Hardware Simulator (Demo Mode):**
   - Explore, test, and tune the interface immediately even when no physical controller is plugged in. Seamlessly switches to hardware mode as soon as a real DualSense is detected!

7. **System Tray Integration (FreeDesktop / SNI):**
   - System tray icon displaying live battery status in its tooltip.
   - Context menu: 1-click Mic Mute toggle, quick RGB color presets, game profile switcher, Bluetooth power-off, and Show/Hide.

---

## 🏗 Architecture Overview

```
dualsensectl-gui / DualSense Expressive
├── CMakeLists.txt                 # CMake build configuration (C++20, Qt6)
├── src/
│   ├── main.cpp                   # Qt Quick entry point, High-DPI, C++ type registration
│   ├── SystrayManager.cpp/.h      # Linux system tray integration (FreeDesktop / SNI)
│   └── core/
│       ├── DualSenseDevice.cpp/.h # QObject device data model exposed to QML
│       ├── DualSenseClient.cpp/.h # Non-blocking dualsensectl IPC engine & Demo Simulator
│       └── ProfileManager.cpp/.h  # JSON game profile manager
├── ui/
│   ├── App.qml                    # Root window, ambient lightbar aura, navigation bar
│   ├── theme/
│   │   └── ExpressiveTokens.qml   # Material 3 Expressive design tokens (colors, radiuses, motion)
│   ├── components/
│   │   ├── ExpressiveButton.qml   # Pill buttons with elastic bounce animations
│   │   ├── ExpressiveCard.qml     # Surface container cards with dynamic ambient glows
│   │   ├── ExpressiveSlider.qml   # Pill sliders with floating value tooltip bubbles
│   │   ├── ExpressiveSwitch.qml   # M3 toggle switches with morphing thumb
│   │   ├── ExpressiveChip.qml     # Filter chips and mode selectors
│   │   ├── StatusBadge.qml        # Telemetry badges with pulsing indicators
│   │   ├── ColorWheel.qml         # Real-time HSV Canvas color wheel
│   │   ├── InteractiveDualSense.qml # Vector DualSense visualizer (RGB wings, LEDs, Mute)
│   │   ├── TriggerVisualizer.qml  # Live force/displacement waveform curve
│   │   ├── ExpressiveFAB.qml      # Expandable floating action button
│   │   └── NotificationToast.qml  # Snackbar toast notifications
│   └── views/
│       ├── DashboardView.qml      # Main dashboard & telemetry
│       ├── TriggersView.qml       # Adaptive triggers studio
│       ├── LightingView.qml       # RGB lighting & player LEDs studio
│       ├── AudioView.qml          # Audio routing, mic mute & haptic attenuation
│       └── ProfilesView.qml       # Gaming profiles manager
├── resources/
│   ├── qml.qrc                    # Embedded QML and SVG resource bundle
│   └── icons/
│       ├── app-icon.svg           # High-resolution Material 3 Expressive squircle app icon
│       └── dualsense.svg          # DualSense vector silhouette
└── scripts/
    ├── build.sh                   # Automated CMake build script
    ├── run.sh                     # Application launcher
    ├── install_desktop.sh         # Desktop entry and icon installer
    └── setup_udev_rules.sh        # Udev rule script for rootless /dev/hidraw access
```

---

## 🚀 Installation & Running

### 1. Prerequisites
On Arch Linux / Fedora / Ubuntu / Debian:
- `cmake` (>= 3.20)
- `g++` or `clang++` (C++20 support)
- `qt6-base`, `qt6-declarative`, `qt6-svg`
- `dualsensectl` (v0.7.0 recommended)

On Arch Linux:
```bash
sudo pacman -S cmake qt6-base qt6-declarative qt6-svg gcc
```

### 2. Configure Udev Permissions (One-Time Setup)
To grant non-root permissions to write output feature reports to `/dev/hidraw*`:
```bash
sudo ./scripts/setup_udev_rules.sh
```

### 3. Build & Launch
Build and run the application with a single command:
```bash
./scripts/run.sh
```
Or build manually using CMake:
```bash
./scripts/build.sh
./build/dualsense-expressive
```

### 4. Install Application Launcher (Desktop Menu Entry)
To integrate DualSense Expressive into your Linux desktop application launcher (KDE Plasma, GNOME, etc.):
```bash
./scripts/install_desktop.sh
```

---

## 📋 CLI Command Matrix (`dualsensectl`)

| CLI Command | Hardware Capability | DualSense Expressive GUI Integration |
| :--- | :--- | :--- |
| `dualsensectl -l` | List connected controllers | Automatic discovery & device dropdown selector |
| `dualsensectl battery` | Query battery level & state | Animated gauge & telemetry badge on Dashboard |
| `dualsensectl info` | Query firmware info & build number | KERNEL FIRMWARE diagnostics card |
| `dualsensectl lightbar on / off` | Toggle touchpad lightbar | Expressive switch on Dashboard & Lighting Studio |
| `dualsensectl lightbar R G B [BR]` | Set RGB color & brightness (0-255) | 60 FPS HSV Color Wheel, Hex entry, brightness slider |
| `dualsensectl led-brightness LEVEL` | Set player & mic LED dimming (0-2) | Dimming chips (Bright, Medium, Dim) |
| `dualsensectl player-leds NUMBER` | Set player indicator LEDs (0-5) | Numbered player LED chips 0 to 5 |
| `dualsensectl microphone on / off` | Hardware mic mute toggle | Large mute toggle card & Floating Action Button |
| `dualsensectl microphone-led on/off/pulse`| Configure amber mic LED | On, Off, Pulse chips in Audio Studio |
| `dualsensectl microphone-mode STATE` | Toggle mic usage (chat/asr/both) | Mode chips in Audio Studio |
| `dualsensectl speaker STATE` | Route audio (headphone/internal/both)| Audio routing chips in Audio Studio |
| `dualsensectl volume VOLUME` | Master audio volume (0-255) | Pill slider with floating numeric tooltip |
| `dualsensectl attenuation RUMBLE TRIGGER` | Attenuate haptics & trigger vibrations (0-7)| Independent attenuation sliders (0 to 7) |
| `dualsensectl trigger <tgt> off` | Reset triggers to standard spring | Reset (Off) action button & mode chip |
| `dualsensectl trigger <tgt> feedback` | Position-based resistance wall | Position & Strength sliders + live curve visualizer |
| `dualsensectl trigger <tgt> weapon` | Firearm break emulation | Start, Stop, Strength sliders + live curve visualizer |
| `dualsensectl trigger <tgt> bow` | Bowstring draw & snap release | Start, Stop, Tension, Snap sliders + live curve visualizer |
| `dualsensectl trigger <tgt> galloping` | Two-beat gallop rhythm | Start, Stop, Foot 1, Foot 2, Cadence sliders |
| `dualsensectl trigger <tgt> machine` | Rapid burst recoil | Start, Stop, Strength A/B, Frequency, Period sliders |
| `dualsensectl trigger <tgt> vibration` | Motor arm vibration | Center Position, Amplitude, Frequency sliders |
| `dualsensectl power-off` | Power off controller (Bluetooth) | Power-off button on Dashboard & system tray menu |

---

## 📄 License

Distributed under the **MIT** License. See [LICENSE](LICENSE) for details.
