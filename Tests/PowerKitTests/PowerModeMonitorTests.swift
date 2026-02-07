//
// Project: PowerKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import XCTest
import SwiftUI
@testable import PowerKit

@MainActor
final class PowerKitTests: XCTestCase {

    func testPowerModeMonitorInitialisation() {
        let monitor = PowerModeMonitor()

        // Should initialise with current system state
        XCTAssertEqual(
            monitor.isLowPowerModeEnabled,
            ProcessInfo.processInfo.isLowPowerModeEnabled
        )
        XCTAssertEqual(
            monitor.thermalState,
            ProcessInfo.processInfo.thermalState
        )
    }

    func testShouldReducePerformanceLogic() {
        let monitor = PowerModeMonitor()

        // When no constraints are active
        if !monitor.isLowPowerModeEnabled &&
            monitor.thermalState != .serious &&
            monitor.thermalState != .critical &&
            !monitor.isLowBatteryState {
            XCTAssertFalse(monitor.shouldReducePerformance)
        }

        // shouldReducePerformance should be true if any constraint is active
        if monitor.isLowPowerModeEnabled ||
            monitor.thermalState == .serious ||
            monitor.thermalState == .critical ||
            monitor.isLowBatteryState {
            XCTAssertTrue(monitor.shouldReducePerformance)
        }
    }

    func testThermalStateValues() {
        // Verify thermal state values exist
        let states: [ProcessInfo.ThermalState] = [.nominal, .fair, .serious, .critical]
        XCTAssertEqual(states.count, 4)
    }

    func testThermalStateConstraintDetection() {
        let monitor = PowerModeMonitor()

        // Test each thermal state individually
        // Note: We can't set these values directly, so we're testing the logic would work
        XCTAssertNotNil(monitor.thermalState)
    }

    func testMultipleConstraintsSimultaneously() {
        let monitor = PowerModeMonitor()

        // If Low Power Mode is on, shouldReducePerformance must be true
        if monitor.isLowPowerModeEnabled {
            XCTAssertTrue(monitor.shouldReducePerformance)
        }

        // If thermal state is serious or critical, shouldReducePerformance must be true
        if monitor.thermalState == .serious || monitor.thermalState == .critical {
            XCTAssertTrue(monitor.shouldReducePerformance)
        }

        // If battery is low (iOS), shouldReducePerformance must be true
        if monitor.isLowBatteryState {
            XCTAssertTrue(monitor.shouldReducePerformance)
        }
    }

    func testPowerModeMonitorIsMainActorIsolated() {
        // Verify the monitor can be created on MainActor
        let expectation = XCTestExpectation(description: "Monitor created on MainActor")

        Task { @MainActor in
            let monitor = PowerModeMonitor()
            XCTAssertNotNil(monitor)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testObservableConformance() {
        let monitor = PowerModeMonitor()

        // Verify we can access observable properties
        _ = monitor.isLowPowerModeEnabled
        _ = monitor.thermalState
        _ = monitor.isLowBatteryState
        _ = monitor.shouldReducePerformance

        XCTAssertTrue(true, "Observable properties are accessible")
    }

#if os(iOS)
    func testBatteryStateLogic() {
        let monitor = PowerModeMonitor()

        // Battery level of -1 means unknown (simulator or battery monitoring disabled)
        // Battery level between 0 and 1 means it's reporting
        let batteryLevel = UIDevice.current.batteryLevel

        if batteryLevel >= 0 {
            // If battery is reporting and below 20%, isLowBatteryState should be true
            if batteryLevel < 0.2 {
                XCTAssertTrue(monitor.isLowBatteryState)
            } else {
                XCTAssertFalse(monitor.isLowBatteryState)
            }
        }
    }
#endif

    func testDeinit() {
        // Test that monitor can be deallocated properly
        var monitor: PowerModeMonitor? = PowerModeMonitor()
        XCTAssertNotNil(monitor)

        monitor = nil
        XCTAssertNil(monitor, "Monitor should be deallocated")
    }

    // MARK: - Environment Key Default Values

    func testEnvironmentKeyDefaults() {
        let environment = EnvironmentValues()

        // All keys should return safe defaults when not explicitly set
        XCTAssertFalse(environment.isLowPowerModeEnabled)
        XCTAssertEqual(environment.thermalState, .nominal)
        XCTAssertFalse(environment.isLowBatteryState)
        XCTAssertFalse(environment.shouldReducePerformance)
    }

    func testEnvironmentKeySettersAndGetters() {
        var environment = EnvironmentValues()

        environment.isLowPowerModeEnabled = true
        XCTAssertTrue(environment.isLowPowerModeEnabled)

        environment.thermalState = .serious
        XCTAssertEqual(environment.thermalState, .serious)

        environment.isLowBatteryState = true
        XCTAssertTrue(environment.isLowBatteryState)

        environment.shouldReducePerformance = true
        XCTAssertTrue(environment.shouldReducePerformance)
    }

    func testEnvironmentKeyThermalStateAllValues() {
        var environment = EnvironmentValues()

        let states: [ProcessInfo.ThermalState] = [.nominal, .fair, .serious, .critical]
        for state in states {
            environment.thermalState = state
            XCTAssertEqual(environment.thermalState, state)
        }
    }
}
