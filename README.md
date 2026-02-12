<!-- markdownlint-disable MD033 MD041 -->
<div align="center">

# PowerKit

![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarkbattistella%2FPowerKit%2Fbadge%3Ftype%3Dswift-versions)

![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarkbattistella%2FPowerKit%2Fbadge%3Ftype%3Dplatforms)

![Licence](https://img.shields.io/badge/Licence-MIT-white?labelColor=blue&style=flat)

</div>

`PowerKit` is a Swift package that helps your app respect Low Power Mode and device thermal states by providing reactive power state monitoring and adaptive UI components for SwiftUI.

It solves the challenge of making iOS apps battery-conscious by offering:

- An observable `PowerModeMonitor` for tracking power states
- Reactive SwiftUI environment integration
- Adaptive animation and visual effect view modifiers
- Thermal state monitoring
- Battery level tracking (iOS only)
- Built-in logging via [SimpleLogger](https://github.com/markbattistella/SimpleLogger)

The goal is to provide a lightweight, well-documented way to make your SwiftUI apps respectful of device constraints without boilerplate.

## Installation

Add `PowerKit` to your Swift project using Swift Package Manager.

```swift
dependencies: [
  .package(url: "https://github.com/markbattistella/PowerKit", from: "1.0.0")
]
```

Alternatively, you can add `PowerKit` using Xcode by navigating to `File > Add Packages` and entering the package repository URL.

## Usage

### Basic Setup

Inject the power monitor into your app's environment:

```swift
import SwiftUI
import PowerKit

@main
struct MyApp: App {
    @State private var powerMonitor = PowerModeMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .powerKitEnvironment(powerMonitor)
        }
    }
}
```

The `.powerKitEnvironment(_:)` modifier injects the monitor and bridges all its properties as individual environment values. This lets views access power state via `@Environment(PowerModeMonitor.self)` for the full monitor, or via key-path access like `@Environment(\.isLowPowerModeEnabled)` for individual values.

<details>
<summary>Manual setup (if you only need specific values)</summary>

You can also inject values individually:

```swift
ContentView()
    .environment(powerMonitor)
    .environment(\.isLowPowerModeEnabled, powerMonitor.isLowPowerModeEnabled)
    .environment(\.thermalState, powerMonitor.thermalState)
    .environment(\.isLowBatteryState, powerMonitor.isLowBatteryState)
    .environment(\.shouldReducePerformance, powerMonitor.shouldReducePerformance)
```

</details>

### Check Power State

Access individual power state values in any view using environment key-paths:

```swift
struct ContentView: View {
    @Environment(\.isLowPowerModeEnabled) private var isLowPowerModeEnabled
    @Environment(\.thermalState) private var thermalState
    @Environment(\.isLowBatteryState) private var isLowBatteryState
    @Environment(\.shouldReducePerformance) private var shouldReducePerformance

    var body: some View {
        VStack {
            if shouldReducePerformance {
                Text("Reducing Performance")
            } else {
                Text("Normal Mode")
            }
        }
    }
}
```

Alternatively, access the full monitor directly:

```swift
struct ContentView: View {
    @Environment(PowerModeMonitor.self) private var powerMonitor

    var body: some View {
        VStack {
            if powerMonitor.shouldReducePerformance {
                Text("Reducing Performance")
            } else {
                Text("Normal Mode")
            }
        }
    }
}
```

### Adaptive Animations

Automatically reduce animations when the device is under power constraints:

```swift
struct AnimatedView: View {
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .scaleEffect(scale)
            .adaptiveAnimation(value: scale)
            .onTapGesture {
                scale = scale == 1.0 ? 1.5 : 1.0
            }
    }
}
```

Custom animation configuration:

```swift
Circle()
    .scaleEffect(scale)
    .adaptiveAnimation(
        normal: .spring(response: 0.6, dampingFraction: 0.8),
        reduced: .linear(duration: 0.1),
        value: scale
    )
```

### Adaptive Content

Use `AdaptivePowerContent` to switch between two content variants based on power state. It works anywhere — inline, as a background, as an overlay:

```swift
// As a background
Text("Content")
    .background {
        AdaptivePowerContent(
            normal: { Color.clear.background(.ultraThinMaterial) },
            reduced: { Color.gray.opacity(0.2) }
        )
    }

// As inline content
AdaptivePowerContent(
    normal: { FancyAnimatedChart() },
    reduced: { StaticChart() }
)

// As an overlay
Image("photo")
    .overlay {
        AdaptivePowerContent(
            normal: { GlowEffect() },
            reduced: { EmptyView() }
        )
    }
```

### Advanced Power Monitoring

Access comprehensive power state information:

```swift
struct AdvancedView: View {
    @Environment(PowerModeMonitor.self) private var powerMonitor

    private var thermalStateLabel: String {
        switch powerMonitor.thermalState {
        case .nominal: "Nominal"
        case .fair: "Fair"
        case .serious: "Serious"
        case .critical: "Critical"
        @unknown default: "Unknown"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Low Power Mode: \(powerMonitor.isLowPowerModeEnabled ? "Yes" : "No")")
            Text("Thermal State: \(thermalStateLabel)")

            #if os(iOS)
            Text("Low Battery: \(powerMonitor.isLowBatteryState ? "Yes" : "No")")
            #endif

            if powerMonitor.shouldReducePerformance {
                Text("Reducing Performance")
                    .foregroundStyle(.orange)
            }
        }
    }
}
```

### Adaptive Refresh Rates

Adjust update frequencies based on power state:

```swift
struct LiveDataView: View {
    @Environment(\.isLowPowerModeEnabled) private var isLowPowerModeEnabled
    @State private var data: String = "Loading..."

    var refreshInterval: TimeInterval {
        isLowPowerModeEnabled ? 30.0 : 5.0
    }

    var body: some View {
        VStack {
            Text(data)
            Text("Refreshing every \(Int(refreshInterval))s")
                .font(.caption)
        }
        .task {
            await refreshData()
        }
    }

    func refreshData() async {
        while !Task.isCancelled {
            data = "Updated at \(Date().formatted(date: .omitted, time: .standard))"
            try? await Task.sleep(for: .seconds(refreshInterval))
        }
    }
}
```

### Conditional Symbol Effects

Disable symbol effects during Low Power Mode:

```swift
struct SymbolView: View {
    @Environment(\.isLowPowerModeEnabled) private var isLowPowerModeEnabled

    var body: some View {
        Image(systemName: "bolt.fill")
            .font(.system(size: 60))
            .foregroundStyle(isLowPowerModeEnabled ? .yellow : .green)
            .symbolEffect(.pulse, isActive: !isLowPowerModeEnabled)
    }
}
```

## Power State Properties

### PowerModeMonitor

The `PowerModeMonitor` provides access to:

- `isLowPowerModeEnabled: Bool` - Whether Low Power Mode is active
- `thermalState: ProcessInfo.ThermalState` - Current thermal state (nominal, fair, serious, critical)
- `isLowBatteryState: Bool` - Whether battery is below 20% (iOS only)
- `shouldReducePerformance: Bool` - Combined check for any power constraint

### Environment Keys

All monitor properties are available as SwiftUI environment values when using `.powerKitEnvironment(_:)`:

| Environment Key Path | Type | Default |
| --- | --- | --- |
| `\.isLowPowerModeEnabled` | `Bool` | `false` |
| `\.thermalState` | `ProcessInfo.ThermalState` | `.nominal` |
| `\.isLowBatteryState` | `Bool` | `false` |
| `\.shouldReducePerformance` | `Bool` | `false` |

These can also be set manually without a monitor, which is useful for SwiftUI previews and testing:

```swift
#Preview("Low Power Mode") {
    MyView()
        .environment(\.isLowPowerModeEnabled, true)
        .environment(\.thermalState, .serious)
}
```

### Thermal States

The package monitors four thermal states:

- `.nominal` - Normal operation
- `.fair` - Slight thermal pressure
- `.serious` - High thermal pressure, reduce performance
- `.critical` - Extreme thermal pressure, minimal operations

## Licence

`PowerKit` is released under the MIT licence.
