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
- Adaptive animation and visual effect modifiers
- Thermal state monitoring
- Battery level tracking (iOS only)

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
                .environment(powerMonitor)
                .environment(\.isLowPowerModeEnabled, powerMonitor.isLowPowerModeEnabled)
        }
    }
}
```

The first line (`.environment(powerMonitor)`) injects the monitor for PowerKit's built-in modifiers like `adaptiveAnimation` and `adaptivePowerMode`.

The second line (`.environment(\.isLowPowerModeEnabled, ...)`) bridges the value so views using `@Environment(\.isLowPowerModeEnabled)` also receive live updates. If your views only use `@Environment(PowerModeMonitor.self)` directly, you can omit the second line.

### Check Power State

Access Low Power Mode state in any view using the environment key (requires the bridge line shown in Basic Setup):

```swift
struct ContentView: View {
    @Environment(\.isLowPowerModeEnabled) private var isLowPowerModeEnabled

    var body: some View {
        VStack {
            if isLowPowerModeEnabled {
                Text("Low Power Mode Active")
            } else {
                Text("Normal Mode")
            }
        }
    }
}
```

Alternatively, access the monitor directly (no bridge line needed):

```swift
struct ContentView: View {
    @Environment(PowerModeMonitor.self) private var powerMonitor

    var body: some View {
        VStack {
            if powerMonitor.isLowPowerModeEnabled {
                Text("Low Power Mode Active")
            } else {
                Text("Normal Mode")
            }
        }
    }
}
```

### Adaptive Animations

Automatically reduce animations when Low Power Mode is enabled:

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

### Adaptive Visual Effects

Reduce expensive visual effects during Low Power Mode:

```swift
struct BackgroundView: View {
    var body: some View {
        VStack {
            Text("Content")
        }
        .adaptivePowerMode(
            normalContent: {
                Color.clear.background(.ultraThinMaterial)
            },
            reducedContent: {
                Color.gray.opacity(0.2)
            }
        )
    }
}
```

### Power Mode Indicator

Show users when your app is being battery-conscious:

```swift
struct DashboardView: View {
    var body: some View {
        VStack {
            PowerModeIndicator()

            // Your content
        }
    }
}
```

Custom message:

```swift
PowerModeIndicator(
    message: "Battery Saver Active",
    showIcon: true
)
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

### Thermal States

The package monitors four thermal states:

- `.nominal` - Normal operation
- `.fair` - Slight thermal pressure
- `.serious` - High thermal pressure, reduce performance
- `.critical` - Extreme thermal pressure, minimal operations

## Licence

`PowerKit` is released under the MIT licence.
