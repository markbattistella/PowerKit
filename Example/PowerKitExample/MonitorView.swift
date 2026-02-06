//
// Project: PowerKitExample
// Author: Mark Battistella
// Website: https://markbattistella.com
//


import SwiftUI
import PowerKit

struct MonitorView: View {
    @Environment(PowerModeMonitor.self) private var powerMonitor
    @State private var updateCount = 0
    @State private var lastUpdate = Date()

    var refreshInterval: TimeInterval {
        powerMonitor.shouldReducePerformance ? 10.0 : 2.0
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Power State") {
                    StatusRow(
                        label: "Low Power Mode",
                        value: powerMonitor.isLowPowerModeEnabled ? "Enabled" : "Disabled",
                        colour: powerMonitor.isLowPowerModeEnabled ? .orange : .green,
                        icon: powerMonitor.isLowPowerModeEnabled ? "battery.25" : "battery.100"
                    )

                    StatusRow(
                        label: "Thermal State",
                        value: thermalStateDescription(powerMonitor.thermalState),
                        colour: thermalStateColour(powerMonitor.thermalState),
                        icon: thermalStateIcon(powerMonitor.thermalState)
                    )

                    #if os(iOS)
                    StatusRow(
                        label: "Low Battery",
                        value: powerMonitor.isLowBatteryState ? "Yes" : "No",
                        colour: powerMonitor.isLowBatteryState ? .red : .green,
                        icon: powerMonitor.isLowBatteryState ? "exclamationmark.triangle.fill" : "checkmark.circle.fill"
                    )
                    #endif
                }

                Section("Performance") {
                    StatusRow(
                        label: "Reduce Performance",
                        value: powerMonitor.shouldReducePerformance ? "Yes" : "No",
                        colour: powerMonitor.shouldReducePerformance ? .orange : .green,
                        icon: powerMonitor.shouldReducePerformance ? "tortoise.fill" : "hare.fill"
                    )
                }

                Section("Adaptive Behaviour") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(.blue)
                            Text("Refresh Interval")
                                .font(.headline)
                        }

                        Text("Updates every \(Int(refreshInterval)) seconds")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(.blue)
                            Text("Update Statistics")
                                .font(.headline)
                        }

                        Text("Updates: \(updateCount)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Last: \(lastUpdate.formatted(date: .omitted, time: .standard))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About Power Monitoring")
                            .font(.headline)

                        Text("PowerKit continuously monitors your device's power state and adjusts app behaviour to conserve battery and reduce thermal pressure.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        #if os(iOS)
                        Text("To test: Enable Low Power Mode in Settings > Battery")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .padding(.top, 4)
                        #elseif os(macOS)
                        Text("To test: Enable Low Power Mode in System Settings > Battery")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .padding(.top, 4)
                        #endif
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Power Monitor")
            .task {
                await startMonitoring()
            }
        }
    }

    func startMonitoring() async {
        while !Task.isCancelled {
            updateCount += 1
            lastUpdate = Date()
            try? await Task.sleep(for: .seconds(refreshInterval))
        }
    }

    func thermalStateDescription(_ state: ProcessInfo.ThermalState) -> String {
        switch state {
        case .nominal: "Nominal"
        case .fair: "Fair"
        case .serious: "Serious"
        case .critical: "Critical"
        @unknown default: "Unknown"
        }
    }

    func thermalStateColour(_ state: ProcessInfo.ThermalState) -> Color {
        switch state {
        case .nominal: .green
        case .fair: .yellow
        case .serious: .orange
        case .critical: .red
        @unknown default: .gray
        }
    }

    func thermalStateIcon(_ state: ProcessInfo.ThermalState) -> String {
        switch state {
        case .nominal: "thermometer.low"
        case .fair: "thermometer.medium"
        case .serious: "thermometer.high"
        case .critical: "flame.fill"
        @unknown default: "thermometer"
        }
    }
}

struct StatusRow: View {
    let label: String
    let value: String
    let colour: Color
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(colour)
                .frame(width: 24)

            Text(label)

            Spacer()

            Text(value)
                .foregroundStyle(colour)
                .bold()
        }
    }
}

#Preview {
    MonitorView()
        .environment(PowerModeMonitor())
}
