import Foundation

/// Defines the reload policy for map styles.
///
/// Use this policy to control whether a style should reload when the URI or JSON
/// matches the currently loaded style.
///
/// ```swift
/// // Default behavior: only reload if style URI/JSON changes
/// mapboxMap.loadStyle(.standard)
///
/// // Always reload even if style URI/JSON is the same
/// mapboxMap.loadStyle(.standard, reloadPolicy: .always) { error in
///     // Style reloaded, events triggered
/// }
/// ```
public struct StyleReloadPolicy: Equatable, Sendable {
    let rawValue: String

    /// Reload the style only if the URI or JSON differs from the currently loaded style.
    ///
    /// This is the default and provides optimal performance.
    public static let onlyIfChanged = StyleReloadPolicy(rawValue: "onlyIfChanged")

    /// Always reload the style even if the URI or JSON matches the currently loaded style.
    ///
    /// Use this when you need style load events to trigger for the same style.
    ///
    /// - Note: Pending style loads will be cancelled when reloading.
    public static let always = StyleReloadPolicy(rawValue: "always")
}
