//
// Project: PowerKitExample
// Author: Mark Battistella
// Website: https://markbattistella.com
//


import SwiftUI
import PowerKit

struct OverviewView: View {
    @Environment(\.isLowPowerModeEnabled) private var isLowPowerModeEnabled

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    PowerModeIndicator()

                    VStack(spacing: 16) {
                        Image(systemName: isLowPowerModeEnabled ? "battery.25" : "bolt.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(isLowPowerModeEnabled ? .orange : .green)
                            .symbolEffect(.pulse, isActive: !isLowPowerModeEnabled)

                        Text(isLowPowerModeEnabled ? "Low Power Mode Active" : "Normal Operation")
                            .font(.title2)
                            .bold()

                        Text("This demo shows how PowerKit helps your app adapt to device constraints")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()

                    Divider()
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(
                            icon: "gauge.with.dots.needle.bottom.50percent",
                            title: "Adaptive Animations",
                            description: "Automatically reduce animation complexity"
                        )

                        FeatureRow(
                            icon: "eye.slash",
                            title: "Visual Effects",
                            description: "Disable expensive blurs and shadows"
                        )

                        FeatureRow(
                            icon: "clock.arrow.circlepath",
                            title: "Refresh Rates",
                            description: "Adjust update frequencies intelligently"
                        )

                        FeatureRow(
                            icon: "thermometer.medium",
                            title: "Thermal Monitoring",
                            description: "Respond to device temperature changes"
                        )
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("PowerKit Demo")
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    OverviewView()
        .environment(\.isLowPowerModeEnabled, false)
}

#Preview("Low Power Mode") {
    OverviewView()
        .environment(\.isLowPowerModeEnabled, true)
}
