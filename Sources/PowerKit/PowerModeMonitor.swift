//
// Project: PowerKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation
import SimpleLogger

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
///                 .powerKitEnvironment(powerMonitor)
///         }
///     }
/// }
/// ```
///
/// The ``SwiftUICore/View/powerKitEnvironment(_:)`` modifier injects the monitor and bridges all
/// properties as individual environment values. Views can then access values via
/// `@Environment(PowerModeMonitor.self)` for the full monitor, or via key-path access
/// like `@Environment(\.isLowPowerModeEnabled)` for individual properties.
@MainActor
@Observable
public final class PowerModeMonitor {
    
    // MARK: - Properties

    @ObservationIgnored
    private let logger = SimpleLogger(category: .package)

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

        logger.info("PowerModeMonitor started — lowPower: \(self.isLowPowerModeEnabled), thermal: \(self.thermalState.label)")

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
        logger.info("Low Power Mode changed: \(self.isLowPowerModeEnabled ? "enabled" : "disabled")")
    }
    
    @objc private func thermalStateDidChange() {
        thermalState = ProcessInfo.processInfo.thermalState
        logger.info("Thermal state changed: \(self.thermalState.label)")
    }
    
    #if os(iOS)
    @objc private func batteryLevelDidChange() {
        updateBatteryState()
    }
    
    private func updateBatteryState() {
        let level = UIDevice.current.batteryLevel
        let wasLow = isLowBatteryState
        isLowBatteryState = level > 0 && level < 0.2
        if isLowBatteryState != wasLow {
            logger.info("Battery state changed: \(self.isLowBatteryState ? "low" : "normal") (level: \(Int(level * 100))%)")
        }
    }
    #endif
    
    // MARK: - Cleanup
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

/// Provides a human-readable label for each thermal state, used for logging output.
fileprivate extension ProcessInfo.ThermalState {

    /// A short, human-readable description of the thermal state.
    var label: String {
        switch self {
            case .nominal:  "nominal"
            case .fair:     "fair"
            case .serious:  "serious"
            case .critical: "critical"
            @unknown default: "unknown"
        }
    }
}

/// Defines the logging category used by PowerKit.
fileprivate extension LoggerCategory {

    /// The shared logging category for all PowerKit log output.
    static let package = LoggerCategory("Package.PowerKit")
}
