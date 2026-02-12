//
// Project: PowerKitExample
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI
import PowerKit

struct PowerModeIndicator: View {
    @Environment(\.isLowPowerModeEnabled) private var isLowPowerModeEnabled

    var body: some View {
        if isLowPowerModeEnabled {
            HStack(spacing: 8) {
                Image(systemName: "battery.25")
                Text("Low Power Mode — Reduced animations")
                    .font(.caption)
            }
            .foregroundStyle(.orange)
            .padding(8)
            .background(Color.orange.opacity(0.1))
            .clipShape(.rect(cornerRadius: 8))
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
