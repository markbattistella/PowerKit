//
// Project: PowerKitExample
// Author: Mark Battistella
// Website: https://markbattistella.com
//


import SwiftUI
import PowerKit

struct EffectsView: View {
    @Environment(\.isLowPowerModeEnabled) private var isLowPowerModeEnabled

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    PowerModeIndicator()

                    // Adaptive background
                    VStack(spacing: 16) {
                        Text("Adaptive Background")
                            .font(.headline)

                        ZStack {
                            // Colourful content behind the card to show blur vs flat
                            HStack(spacing: 0) {
                                Color.red
                                Color.orange
                                Color.yellow
                                Color.green
                                Color.blue
                                Color.purple
                            }

                            VStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.primary)

                                Text(isLowPowerModeEnabled ? "Flat colour overlay" : "Blur material overlay")
                                    .font(.caption)
                                    .bold()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .adaptivePowerMode(
                                normalContent: {
                                    Color.clear.background(.ultraThinMaterial)
                                },
                                reducedContent: {
                                    #if os(iOS)
                                    Color(.systemBackground).opacity(0.85)
                                    #else
                                    Color(.windowBackgroundColor).opacity(0.85)
                                    #endif
                                }
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .clipShape(.rect(cornerRadius: 16))
                    }

                    Divider()
                        .padding(.horizontal)

                    // Adaptive shadow
                    VStack(spacing: 16) {
                        Text("Adaptive Shadow")
                            .font(.headline)

                        VStack {
                            Image(systemName: "shadow")
                                .font(.system(size: 40))
                                .foregroundStyle(.purple)

                            Text("Shadow Effect")
                                .font(.body)

                            Text(isLowPowerModeEnabled ? "No shadow" : "Heavy shadow")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background {
                            #if os(iOS)
                            Color(.secondarySystemBackground)
                            #else
                            Color(.secondarySystemFill)
                            #endif
                        }
                        .clipShape(.rect(cornerRadius: 16))
                        .shadow(
                            color: .primary.opacity(isLowPowerModeEnabled ? 0 : 0.3),
                            radius: isLowPowerModeEnabled ? 0 : 20,
                            y: isLowPowerModeEnabled ? 0 : 8
                        )
                    }
                    .padding(.horizontal, 4)

                    Divider()
                        .padding(.horizontal)

                    // Symbol effects
                    VStack(spacing: 16) {
                        Text("Symbol Effects")
                            .font(.headline)

                        HStack(spacing: 40) {
                            VStack(spacing: 8) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(isLowPowerModeEnabled ? .yellow : .green)
                                    .symbolEffect(.pulse, isActive: !isLowPowerModeEnabled)

                                Text("Pulse")
                                    .font(.caption)
                            }

                            VStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(isLowPowerModeEnabled ? .gray : .red)
                                    .symbolEffect(.bounce, isActive: !isLowPowerModeEnabled)

                                Text("Bounce")
                                    .font(.caption)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 16))

                        Text(isLowPowerModeEnabled ? "Effects disabled" : "Effects active")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider()
                        .padding(.horizontal)

                    // Info card
                    VStack(spacing: 12) {
                        Text("Visual Effects Status")
                            .font(.headline)

                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                EffectStatusRow(title: "Material Blurs", isActive: !isLowPowerModeEnabled)
                                EffectStatusRow(title: "Shadows", isActive: !isLowPowerModeEnabled)
                                EffectStatusRow(title: "Symbol Effects", isActive: !isLowPowerModeEnabled)
                            }

                            Spacer()
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 12))
                }
                .padding()
            }
            .navigationTitle("Visual Effects")
        }
    }
}

struct EffectStatusRow: View {
    let title: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isActive ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(isActive ? .green : .orange)

            Text(title)
                .font(.subheadline)
        }
    }
}

#Preview {
    EffectsView()
        .environment(\.isLowPowerModeEnabled, false)
}

#Preview("Low Power Mode") {
    EffectsView()
        .environment(\.isLowPowerModeEnabled, true)
}
