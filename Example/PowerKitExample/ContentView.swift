//
// Project: PowerKitExample
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI
import PowerKit

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Overview", systemImage: "info.circle") {
                OverviewView()
            }

            Tab("Animations", systemImage: "sparkles") {
                AnimationsView()
            }

            Tab("Effects", systemImage: "paintbrush") {
                EffectsView()
            }

            Tab("Monitor", systemImage: "chart.xyaxis.line") {
                MonitorView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(PowerModeMonitor())
}
