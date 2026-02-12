//
// Project: PowerKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A view that switches between two content variants based on device power state.
///
/// `AdaptivePowerContent` renders either its normal or reduced content depending on
/// whether the device is under power constraints (Low Power Mode, thermal pressure,
/// or low battery).
///
/// Use it anywhere you need power-aware content — as inline content, a background,
/// an overlay, or a full view replacement:
///
/// ```swift
/// // Inline content switch
/// AdaptivePowerContent(
///     normal: { FancyAnimatedChart() },
///     reduced: { StaticChart() }
/// )
///
/// // As a background
/// Text("Content")
///     .background {
///         AdaptivePowerContent(
///             normal: { Color.clear.background(.ultraThinMaterial) },
///             reduced: { Color.gray.opacity(0.2) }
///         )
///     }
///
/// // As an overlay
/// Image("photo")
///     .overlay {
///         AdaptivePowerContent(
///             normal: { GlowEffect() },
///             reduced: { EmptyView() }
///         )
///     }
/// ```
public struct AdaptivePowerContent<NormalContent: View, ReducedContent: View>: View {

    @Environment(PowerModeMonitor.self)
    private var powerMonitor: PowerModeMonitor?

    @Environment(\.shouldReducePerformance)
    private var environmentShouldReduce

    private var shouldReducePerformance: Bool {
        powerMonitor?.shouldReducePerformance ?? environmentShouldReduce
    }

    /// Content to display during normal operation.
    private let normalContent: () -> NormalContent

    /// Content to display when performance should be reduced.
    private let reducedContent: () -> ReducedContent

    /// Creates an adaptive power content view.
    ///
    /// - Parameters:
    ///   - normal: A closure that returns the content for normal operation.
    ///   - reduced: A closure that returns the content when performance should be reduced.
    public init(
        @ViewBuilder normal: @escaping () -> NormalContent,
        @ViewBuilder reduced: @escaping () -> ReducedContent
    ) {
        self.normalContent = normal
        self.reducedContent = reduced
    }

    public var body: some View {
        if shouldReducePerformance {
            reducedContent()
        } else {
            normalContent()
        }
    }
}0
