//
// Project: PowerKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A view modifier that adapts animations based on device power state.
///
/// This modifier automatically switches between normal and reduced animations
/// when Low Power Mode is enabled, helping preserve battery life.
public struct AdaptiveAnimation<V: Equatable>: ViewModifier {

    @Environment(PowerModeMonitor.self) private var powerMonitor: PowerModeMonitor?
    @Environment(\.isLowPowerModeEnabled) private var environmentIsLowPowerMode

    private var isLowPowerModeEnabled: Bool {
        powerMonitor?.isLowPowerModeEnabled ?? environmentIsLowPowerMode
    }

    /// The animation to use during normal operation.
    public let normalAnimation: Animation

    /// The animation to use during Low Power Mode. Use `nil` to disable animation.
    public let reducedAnimation: Animation?

    /// The value to animate.
    public let animatedValue: V

    /// Creates an adaptive animation modifier.
    ///
    /// - Parameters:
    ///   - normalAnimation: The animation to use when Low Power Mode is disabled.
    ///   - reducedAnimation: The animation to use when Low Power Mode is enabled.
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
                isLowPowerModeEnabled ? reducedAnimation : normalAnimation,
                value: animatedValue
            )
    }
}

extension View {

    /// Applies adaptive animations based on Low Power Mode state.
    ///
    /// When Low Power Mode is enabled, the view uses a reduced animation.
    /// Otherwise, it uses the normal animation.
    ///
    /// - Parameters:
    ///   - normal: The animation to use during normal operation. Defaults to `.spring()`.
    ///   - reduced: The animation to use during Low Power Mode. Defaults to `.linear(duration: 0.2)`.
    ///     Pass `nil` to disable animation entirely.
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
