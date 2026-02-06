//
// Project: PowerKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A view modifier that provides content adaptation based on power state.
///
/// This modifier allows you to provide different view configurations for
/// normal and low power modes, enabling fine-grained control over your UI.
public struct AdaptivePowerMode<NormalContent: View, ReducedContent: View>: ViewModifier {
    
    @Environment(PowerModeMonitor.self) private var powerMonitor: PowerModeMonitor?
    @Environment(\.isLowPowerModeEnabled) private var environmentIsLowPowerMode

    private var isLowPowerModeEnabled: Bool {
        powerMonitor?.isLowPowerModeEnabled ?? environmentIsLowPowerMode
    }

    /// Content to display during normal operation.
    public let normalContent: () -> NormalContent
    
    /// Content to display during Low Power Mode.
    public let reducedContent: () -> ReducedContent
    
    /// Creates an adaptive power mode modifier.
    ///
    /// - Parameters:
    ///   - normalContent: A closure that returns the content for normal operation.
    ///   - reducedContent: A closure that returns the content for Low Power Mode.
    public init(
        @ViewBuilder normalContent: @escaping () -> NormalContent,
        @ViewBuilder reducedContent: @escaping () -> ReducedContent
    ) {
        self.normalContent = normalContent
        self.reducedContent = reducedContent
    }
    
    public func body(content: Content) -> some View {
        content
            .background {
                if isLowPowerModeEnabled {
                    reducedContent()
                } else {
                    normalContent()
                }
            }
    }
}

extension View {
    
    /// Adapts the view's appearance based on Low Power Mode state.
    ///
    /// This modifier allows you to specify different content for normal
    /// and low power modes, useful for expensive visual effects.
    ///
    /// - Parameters:
    ///   - normalContent: Content to display during normal operation.
    ///   - reducedContent: Content to display during Low Power Mode.
    ///
    /// - Returns: A view that adapts based on power state.
    ///
    /// Usage:
    /// ```swift
    /// VStack {
    ///     Text("Content")
    /// }
    /// .adaptivePowerMode(
    ///     normalContent: {
    ///         Color.clear.background(.ultraThinMaterial)
    ///     },
    ///     reducedContent: {
    ///         Color.gray.opacity(0.2)
    ///     }
    /// )
    /// ```
    public func adaptivePowerMode<NormalContent: View, ReducedContent: View>(
        @ViewBuilder normalContent: @escaping () -> NormalContent,
        @ViewBuilder reducedContent: @escaping () -> ReducedContent
    ) -> some View {
        modifier(AdaptivePowerMode(
            normalContent: normalContent,
            reducedContent: reducedContent
        ))
    }
}
