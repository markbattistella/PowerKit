//
// Project: PowerKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI
import Testing

@testable import PowerKit

#if os(iOS)
  import UIKit
#endif

@Suite("PowerKit", .serialized)
@MainActor
struct PowerModeMonitorTests {

  @Test("Monitor starts with current system state")
  func monitorStartsWithCurrentSystemState() {
    let monitor = PowerModeMonitor()

    #expect(monitor.isLowPowerModeEnabled == ProcessInfo.processInfo.isLowPowerModeEnabled)
    #expect(monitor.thermalState == ProcessInfo.processInfo.thermalState)
  }

  @Test("Performance reduction matches active constraints")
  func performanceReductionMatchesActiveConstraints() {
    let monitor = PowerModeMonitor()
    let isThermallyConstrained =
      monitor.thermalState == .serious || monitor.thermalState == .critical
    let expected =
      monitor.isLowPowerModeEnabled || isThermallyConstrained || monitor.isLowBatteryState

    #expect(monitor.shouldReducePerformance == expected)
  }

  @Test("Thermal states include all public cases")
  func thermalStatesIncludeAllPublicCases() {
    let states: [ProcessInfo.ThermalState] = [.nominal, .fair, .serious, .critical]

    #expect(states.count == 4)
    #expect(states.contains(.nominal))
    #expect(states.contains(.fair))
    #expect(states.contains(.serious))
    #expect(states.contains(.critical))
  }

  @Test("Observable properties are readable")
  func observablePropertiesAreReadable() {
    let monitor = PowerModeMonitor()

    _ = monitor.isLowPowerModeEnabled
    _ = monitor.thermalState
    _ = monitor.isLowBatteryState
    _ = monitor.shouldReducePerformance
  }

  @Test("Environment values use safe defaults")
  func environmentValuesUseSafeDefaults() {
    let environment = EnvironmentValues()

    #expect(!environment.isLowPowerModeEnabled)
    #expect(environment.thermalState == .nominal)
    #expect(!environment.isLowBatteryState)
    #expect(!environment.shouldReducePerformance)
  }

  @Test("Environment values support overrides")
  func environmentValuesSupportOverrides() {
    var environment = EnvironmentValues()

    environment.isLowPowerModeEnabled = true
    environment.thermalState = .serious
    environment.isLowBatteryState = true
    environment.shouldReducePerformance = true

    #expect(environment.isLowPowerModeEnabled)
    #expect(environment.thermalState == .serious)
    #expect(environment.isLowBatteryState)
    #expect(environment.shouldReducePerformance)
  }

  @Test("Environment thermal value supports every thermal state")
  func environmentThermalValueSupportsEveryThermalState() {
    var environment = EnvironmentValues()
    let states: [ProcessInfo.ThermalState] = [.nominal, .fair, .serious, .critical]

    for state in states {
      environment.thermalState = state
      #expect(environment.thermalState == state)
    }
  }

  #if os(iOS)
    @Test("Low battery state mirrors current known battery level")
    func lowBatteryStateMirrorsCurrentKnownBatteryLevel() {
      let monitor = PowerModeMonitor()
      let batteryLevel = UIDevice.current.batteryLevel

      guard batteryLevel >= 0 else {
        return
      }

      #expect(monitor.isLowBatteryState == (batteryLevel < 0.2))
    }
  #endif
}
