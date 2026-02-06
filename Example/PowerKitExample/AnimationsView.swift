//
// Project: PowerKitExample
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI
import PowerKit

struct AnimationsView: View {
    @Environment(\.isLowPowerModeEnabled) private var isLowPowerModeEnabled
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var offset: CGFloat = 0.0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    PowerModeIndicator()

                    // Scale animation
                    VStack(spacing: 16) {
                        Text("Scale Animation")
                            .font(.headline)

                        Text(isLowPowerModeEnabled ? "Linear — no bounce" : "Spring — watch it bounce")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Circle()
                            .fill(.blue.gradient)
                            .frame(width: 80, height: 80)
                            .scaleEffect(scale)
                            .adaptiveAnimation(
                                normal: .spring(response: 0.5, dampingFraction: 0.3),
                                reduced: .linear(duration: 0.3),
                                value: scale
                            )
                            .onTapGesture {
                                scale = scale == 1.0 ? 2.0 : 1.0
                            }

                        Text("Tap to animate")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider()
                        .padding(.horizontal)

                    // Rotation animation
                    VStack(spacing: 16) {
                        Text("Rotation Animation")
                            .font(.headline)

                        Text(isLowPowerModeEnabled ? "Linear — snaps into place" : "Spring — overshoots and settles")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        RoundedRectangle(cornerRadius: 20)
                            .fill(.purple.gradient)
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(rotation))
                            .adaptiveAnimation(
                                normal: .spring(response: 0.5, dampingFraction: 0.3),
                                reduced: .linear(duration: 0.3),
                                value: rotation
                            )
                            .onTapGesture {
                                rotation += 90
                            }

                        Text("Tap to rotate")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider()
                        .padding(.horizontal)

                    // Offset animation
                    VStack(spacing: 16) {
                        Text("Offset Animation")
                            .font(.headline)

                        Text(isLowPowerModeEnabled ? "Linear — constant speed" : "Spring — elastic movement")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Capsule()
                            .fill(.green.gradient)
                            .frame(width: 100, height: 60)
                            .offset(x: offset)
                            .adaptiveAnimation(
                                normal: .spring(response: 0.5, dampingFraction: 0.3),
                                reduced: .linear(duration: 0.3),
                                value: offset
                            )
                            .onTapGesture {
                                offset = offset == 0 ? 100 : 0
                            }

                        Text("Tap to move")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider()
                        .padding(.horizontal)

                    // Animation info
                    VStack(spacing: 8) {
                        Text("Current Animation Mode")
                            .font(.headline)

                        Text(isLowPowerModeEnabled ? "Reduced (Linear)" : "Normal (Spring)")
                            .font(.body)
                            .foregroundStyle(isLowPowerModeEnabled ? .orange : .green)
                            .bold()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 12))
                }
                .padding()
            }
            .navigationTitle("Adaptive Animations")
        }
    }
}

#Preview {
    AnimationsView()
        .environment(\.isLowPowerModeEnabled, false)
}

#Preview("Low Power Mode") {
    AnimationsView()
        .environment(\.isLowPowerModeEnabled, true)
}
