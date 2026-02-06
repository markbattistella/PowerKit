//
// Project: PowerKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

private struct LowPowerModeKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    
    /// Indicates whether Low Power Mode is currently enabled.
    ///
    /// This value can be set manually using a custom environment key,
    /// or automatically by injecting a `PowerModeMonitor` into the environment.
    ///
    /// Usage with custom key:
    /// ```swift
    /// .environment(\.isLowPowerModeEnabled, true)
    /// ```
    ///
    /// Usage with monitor (recommended):
    /// ```swift
    /// @State private var powerMonitor = PowerModeMonitor()
    ///
    /// ContentView()
    ///     .environment(powerMonitor)
    ///     .environment(\.isLowPowerModeEnabled, powerMonitor.isLowPowerModeEnabled)
    /// ```
    ///
    /// The first line injects the monitor for PowerKit's built-in modifiers.
    /// The second line bridges the value so views reading this environment key
    /// receive the live value. Without the bridge, this key returns the default (`false`).
    public var isLowPowerModeEnabled: Bool {
        get { self[LowPowerModeKey.self] }
        set { self[LowPowerModeKey.self] = newValue }
    }
}
