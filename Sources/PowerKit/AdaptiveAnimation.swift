//
// Project: PowerKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A view modifier that adapts animations based on device power state.
///
/// This modifier automatically switches between normal and reduced animations
/// when the device is under power constraints (Low Power Mode, thermal pressure,
/// or low battery), helping preserve battery life.
public struct AdaptiveAnimation<V: Equatable>: ViewModifier {

    @Environment(PowerModeMonitor.self)
    private var powerMonitor: PowerModeMonitor?

    @Environment(\.shouldReducePerformance)
    private var environmentShouldReduce

    private var shouldReducePerformance: Bool {
        powerMonitor?.shouldReducePerformance ?? environmentShouldReduce
    }

    /// The animation to use during normal operation.
    public let normalAnimation: Animation

    /// The animation to use when performance should be reduced. Use `nil` to disable animation.
    public let reducedAnimation: Animation?

    /// The value to animate.
    public let animatedValue: V

    /// Creates an adaptive animation modifier.
    ///
    /// - Parameters:
    ///   - normalAnimation: The animation to use under normal conditions.
    ///   - reducedAnimation: The animation to use when performance should be reduced.
    ///   - value: The value to observe for animation triggers.
    public init(
        normalAnimation: Animation,
        reducedAnimation: Animation?,
        value: V
    ) {
        self.normalAnimation = normalAnimation
        self.reducedAnimation = reducedAnimation
        self.animatedValue = value
    }

    public func body(content: Content) -> some View {
        content
            .animation(
                shouldReducePerformance ? reducedAnimation : normalAnimation,
                value: animatedValue
            )
    }
}

extension View {

    /// Applies adaptive animations based on device power state.
    ///
    /// When the device is under power constraints (Low Power Mode, thermal pressure,
    /// or low battery), the view uses a reduced animation. Otherwise, it uses the
    /// normal animation.
    ///
    /// - Parameters:
    ///   - normal: The animation to use during normal operation. Defaults to `.spring()`.
    ///   - reduced: The animation to use when performance should be reduced.
    ///     Defaults to `.linear(duration: 0.2)`. Pass `nil` to disable animation entirely.
    ///   - value: The value to observe for animation triggers.
    ///
    /// - Returns: A view with adaptive animation behaviour.
    ///
    /// Usage:
    /// ```swift
    /// Circle()
    ///     .scaleEffect(scale)
    ///     .adaptiveAnimation(value: scale)
    ///     .onTapGesture {
    ///         scale = scale == 1.0 ? 1.5 : 1.0
    ///     }
    /// ```
    public func adaptiveAnimation<V: Equatable>(
        normal: Animation = .spring(),
        reduced: Animation? = .linear(duration: 0.2),
        value: V
    ) -> some View {
        modifier(AdaptiveAnimation(
            normalAnimation: normal,
            reducedAnimation: reduced,
            value: value
        ))
    }
}
