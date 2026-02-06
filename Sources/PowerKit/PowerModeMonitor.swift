//
// Project: PowerKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// A monitor that tracks device power state and thermal conditions.
///
/// `PowerModeMonitor` observes system notifications for Low Power Mode changes,
/// thermal state changes, and battery level changes (iOS only). It provides
/// a reactive way to adapt your app's behaviour based on device constraints.
///
/// Usage:
/// ```swift
/// @main
/// struct MyApp: App {
///     @State private var powerMonitor = PowerModeMonitor()
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(powerMonitor)
///                 .environment(\.isLowPowerModeEnabled, powerMonitor.isLowPowerModeEnabled)
///         }
///     }
/// }
/// ```
///
/// The `.environment(powerMonitor)` line allows PowerKit's built-in modifiers
/// (like ``AdaptiveAnimation`` and ``AdaptivePowerMode``) to read the monitor directly.
/// The `.environment(\.isLowPowerModeEnabled, ...)` line bridges the value so that
/// views using `@Environment(\.isLowPowerModeEnabled)` also receive updates.
/// Alternatively, views can use `@Environment(PowerModeMonitor.self)` directly.
@MainActor
@Observable
public final class PowerModeMonitor {
    
    // MARK: - Properties
    
    /// Indicates whether Low Power Mode is currently enabled.
    public private(set) var isLowPowerModeEnabled: Bool
    
    /// The current thermal state of the device.
    public private(set) var thermalState: ProcessInfo.ThermalState
    
    /// Indicates whether the battery is in a low state (below 20%).
    ///
    /// Only available on iOS. Always `false` on other platforms.
    public private(set) var isLowBatteryState: Bool = false
    
    // MARK: - Computed Properties
    
    /// Indicates whether the app should reduce performance-intensive operations.
    ///
    /// Returns `true` if any of the following conditions are met:
    /// - Low Power Mode is enabled
    /// - Thermal state is serious or critical
    /// - Battery level is below 20% (iOS only)
    public var shouldReducePerformance: Bool {
        let isThermalConstrained = thermalState == .serious || thermalState == .critical
        return isLowPowerModeEnabled || isThermalConstrained || isLowBatteryState
    }
    
    // MARK: - Initialisation
    
    /// Creates a new power mode monitor.
    ///
    /// The monitor immediately begins observing system notifications for
    /// power state changes, thermal state changes, and battery level changes.
    public init() {
        self.isLowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
        self.thermalState = ProcessInfo.processInfo.thermalState
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(powerStateDidChange),
            name: Notification.Name.NSProcessInfoPowerStateDidChange,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(thermalStateDidChange),
            name: ProcessInfo.thermalStateDidChangeNotification,
            object: nil
        )
        
        #if os(iOS)
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelDidChange),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
        updateBatteryState()
        #endif
    }
    
    // MARK: - Notification Handlers
    
    @objc private func powerStateDidChange() {
        isLowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
    }
    
    @objc private func thermalStateDidChange() {
        thermalState = ProcessInfo.processInfo.thermalState
    }
    
    #if os(iOS)
    @objc private func batteryLevelDidChange() {
        updateBatteryState()
    }
    
    private func updateBatteryState() {
        let level = UIDevice.current.batteryLevel
        isLowBatteryState = level > 0 && level < 0.2
    }
    #endif
    
    // MARK: - Cleanup
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
