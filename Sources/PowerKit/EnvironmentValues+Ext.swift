//
// Project: PowerKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

// MARK: - Environment Keys

private struct LowPowerModeKey: EnvironmentKey {
    static let defaultValue = false
}

private struct ThermalStateKey: EnvironmentKey {
    static let defaultValue: ProcessInfo.ThermalState = .nominal
}

private struct LowBatteryStateKey: EnvironmentKey {
    static let defaultValue = false
}

private struct ShouldReducePerformanceKey: EnvironmentKey {
    static let defaultValue = false
}

// MARK: - Environment Values

extension EnvironmentValues {

    /// Indicates whether Low Power Mode is currently enabled.
    ///
    /// Use this environment value to read Low Power Mode state without
    /// importing PowerKit or accessing the full ``PowerModeMonitor``.
    ///
    /// This value is automatically bridged when using ``SwiftUICore/View/powerKitEnvironment(_:)``,
    /// or can be set manually:
    ///
    /// ```swift
    /// .environment(\.isLowPowerModeEnabled, true)
    /// ```
    ///
    /// Read it in any view:
    ///
    /// ```swift
    /// @Environment(\.isLowPowerModeEnabled) private var isLowPowerModeEnabled
    /// ```
    public var isLowPowerModeEnabled: Bool {
        get { self[LowPowerModeKey.self] }
        set { self[LowPowerModeKey.self] = newValue }
    }

    /// The current thermal state of the device.
    ///
    /// Use this environment value to read the thermal state without
    /// importing PowerKit or accessing the full ``PowerModeMonitor``.
    ///
    /// Defaults to `.nominal` when not explicitly set.
    ///
    /// This value is automatically bridged when using ``SwiftUICore/View/powerKitEnvironment(_:)``,
    /// or can be set manually:
    ///
    /// ```swift
    /// .environment(\.thermalState, .serious)
    /// ```
    ///
    /// Read it in any view:
    ///
    /// ```swift
    /// @Environment(\.thermalState) private var thermalState
    /// ```
    public var thermalState: ProcessInfo.ThermalState {
        get { self[ThermalStateKey.self] }
        set { self[ThermalStateKey.self] = newValue }
    }

    /// Indicates whether the battery is in a low state (below 20%).
    ///
    /// Use this environment value to read the low battery state without
    /// importing PowerKit or accessing the full ``PowerModeMonitor``.
    ///
    /// Only meaningful on iOS. Defaults to `false` when not explicitly set.
    ///
    /// This value is automatically bridged when using ``SwiftUICore/View/powerKitEnvironment(_:)``,
    /// or can be set manually:
    ///
    /// ```swift
    /// .environment(\.isLowBatteryState, true)
    /// ```
    ///
    /// Read it in any view:
    ///
    /// ```swift
    /// @Environment(\.isLowBatteryState) private var isLowBatteryState
    /// ```
    public var isLowBatteryState: Bool {
        get { self[LowBatteryStateKey.self] }
        set { self[LowBatteryStateKey.self] = newValue }
    }

    /// Indicates whether the app should reduce performance-intensive operations.
    ///
    /// Use this environment value to read the combined power constraint state without
    /// importing PowerKit or accessing the full ``PowerModeMonitor``.
    ///
    /// When bridged from ``PowerModeMonitor``, this returns `true` if any of the following
    /// conditions are met:
    /// - Low Power Mode is enabled
    /// - Thermal state is serious or critical
    /// - Battery level is below 20% (iOS only)
    ///
    /// Defaults to `false` when not explicitly set.
    ///
    /// This value is automatically bridged when using ``SwiftUICore/View/powerKitEnvironment(_:)``,
    /// or can be set manually:
    ///
    /// ```swift
    /// .environment(\.shouldReducePerformance, true)
    /// ```
    ///
    /// Read it in any view:
    ///
    /// ```swift
    /// @Environment(\.shouldReducePerformance) private var shouldReducePerformance
    /// ```
    public var shouldReducePerformance: Bool {
        get { self[ShouldReducePerformanceKey.self] }
        set { self[ShouldReducePerformanceKey.self] = newValue }
    }
}

// MARK: - Convenience View Extension

extension View {

    /// Injects the ``PowerModeMonitor`` and bridges all its properties into the SwiftUI environment.
    ///
    /// This is the recommended way to set up PowerKit. It injects the monitor instance
    /// for PowerKit's built-in modifiers and bridges all properties as individual
    /// environment values for views that prefer key-path access.
    ///
    /// ```swift
    /// @main
    /// struct MyApp: App {
    ///     @State private var powerMonitor = PowerModeMonitor()
    ///
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             ContentView()
    ///                 .powerKitEnvironment(powerMonitor)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// This is equivalent to calling each environment injection individually:
    ///
    /// ```swift
    /// .environment(powerMonitor)
    /// .environment(\.isLowPowerModeEnabled, powerMonitor.isLowPowerModeEnabled)
    /// .environment(\.thermalState, powerMonitor.thermalState)
    /// .environment(\.isLowBatteryState, powerMonitor.isLowBatteryState)
    /// .environment(\.shouldReducePerformance, powerMonitor.shouldReducePerformance)
    /// ```
    ///
    /// - Parameter monitor: The ``PowerModeMonitor`` instance to inject.
    /// - Returns: A view with the monitor and all power state values available in the environment.
    public func powerKitEnvironment(_ monitor: PowerModeMonitor) -> some View {
        self
            .environment(monitor)
            .environment(\.isLowPowerModeEnabled, monitor.isLowPowerModeEnabled)
            .environment(\.thermalState, monitor.thermalState)
            .environment(\.isLowBatteryState, monitor.isLowBatteryState)
            .environment(\.shouldReducePerformance, monitor.shouldReducePerformance)
    }
}
