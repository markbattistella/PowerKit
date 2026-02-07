//
// Project: PowerKitExample
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI
import PowerKit

@main
struct PowerKitExample: App {
    @State private var powerMonitor = PowerModeMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .powerKitEnvironment(powerMonitor)
        }
    }
}
