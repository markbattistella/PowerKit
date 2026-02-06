//
// Project: PowerKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A view that displays the current power mode status to users.
///
/// This indicator appears when Low Power Mode is enabled, informing users
/// that the app is adapting its behaviour to conserve battery.
public struct PowerModeIndicator: View {
    
    @Environment(PowerModeMonitor.self) private var powerMonitor: PowerModeMonitor?
    @Environment(\.isLowPowerModeEnabled) private var environmentIsLowPowerMode

    private var isLowPowerModeEnabled: Bool {
        powerMonitor?.isLowPowerModeEnabled ?? environmentIsLowPowerMode
    }
    
    /// The message to display when Low Power Mode is active.
    private let message: String
    
    /// Whether to show a battery icon alongside the message.
    private let showIcon: Bool
    
    /// Creates a power mode indicator.
    ///
    /// - Parameters:
    ///   - message: The message to display. Defaults to "Low Power Mode - Reduced animations".
    ///   - showIcon: Whether to show a battery icon. Defaults to `true`.
    public init(
        message: String = "Low Power Mode - Reduced animations",
        showIcon: Bool = true
    ) {
        self.message = message
        self.showIcon = showIcon
    }
    
    public var body: some View {
        VStack {
            if isLowPowerModeEnabled {
                HStack(spacing: 8) {
                    if showIcon {
                        Image(systemName: "battery.25")
                    }
                    Text(message)
                        .font(.caption)
                }
                .foregroundStyle(.orange)
                .padding(8)
                .background(Color.orange.opacity(0.1))
                .clipShape(.rect(cornerRadius: 8))
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: isLowPowerModeEnabled)
    }
}

#Preview("Power Mode Indicator - Enabled") {
    PowerModeIndicator()
        .environment(\.isLowPowerModeEnabled, true)
}

#Preview("Power Mode Indicator - Disabled") {
    PowerModeIndicator()
        .environment(\.isLowPowerModeEnabled, false)
}

#Preview("Power Mode Indicator - Custom Message") {
    PowerModeIndicator(message: "Battery Saver Active")
        .environment(\.isLowPowerModeEnabled, true)
}