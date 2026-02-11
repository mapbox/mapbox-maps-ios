import Foundation
import UIKit

/// Controls how map symbols scale in response to system text size settings.
///
/// Use factory methods to create instances:
/// - `.system` - Automatic scaling with default or custom mapping
/// - `.fixed(scaleFactor:)` - Fixed scale factor, no dynamic updates
@_spi(Experimental)
public struct SymbolScaleBehavior: Equatable {
    internal enum Mode {
        case system
        case systemCustom((Double) -> Double)
        case fixed(Double)
    }

    internal let mode: Mode
    internal let mappingFunction: ((Double) -> Double)?
    internal let scaleFactor: Double?

    private init(mode: Mode, mappingFunction: ((Double) -> Double)? = nil, scaleFactor: Double? = nil) {
        self.mode = mode
        self.mappingFunction = mappingFunction
        self.scaleFactor = scaleFactor
    }

    /// Automatic scaling based on system text size.
    /// Scales symbols from 0.8x (small) to 2.0x (accessibility sizes).
    public static let system = SymbolScaleBehavior(mode: .system)

    /// Automatic scaling with custom mapping function.
    ///
    /// - Parameter mapping: Transforms system text size scale (Double) to symbol scale (Double).
    ///
    /// Example: `SymbolScaleBehavior.system { min($0 * 1.2, 1.5) }`
    public static func system(mapping: @escaping (Double) -> Double) -> SymbolScaleBehavior {
        return SymbolScaleBehavior(mode: .systemCustom(mapping), mappingFunction: mapping)
    }

    /// Fixed scale factor (no system text scaling).
    ///
    /// - Parameter scaleFactor: Scale value (recommended: 0.8-2.0)
    public static func fixed(scaleFactor: Double) -> SymbolScaleBehavior {
        return SymbolScaleBehavior(mode: .fixed(scaleFactor), scaleFactor: scaleFactor)
    }

    /// Indicates whether two SymbolScaleBehavior instances are equal.
    ///
    /// Note: Mapping functions are compared by reference, not by behavior.
    /// Two System instances with different mapping functions may be considered unequal
    /// even if they produce identical results.
    public static func == (lhs: SymbolScaleBehavior, rhs: SymbolScaleBehavior) -> Bool {
        switch (lhs.mode, rhs.mode) {
        case (.system, .system):
            return true
        case (.fixed(let lhsScale), .fixed(let rhsScale)):
            return lhsScale == rhsScale
        case (.systemCustom, .systemCustom):
            // Functions can't be compared, compare by reference if available
            return lhs.mappingFunction.map { ObjectIdentifier($0 as AnyObject) } ==
                   rhs.mappingFunction.map { ObjectIdentifier($0 as AnyObject) }
        default:
            return false
        }
    }

    // MARK: - Internal Utilities

    /// Returns true if this is System mode.
    internal var isSystem: Bool {
        switch mode {
        case .system, .systemCustom:
            return true
        case .fixed:
            return false
        }
    }

    /// Returns true if this is Fixed mode.
    internal var isFixed: Bool {
        switch mode {
        case .fixed:
            return true
        case .system, .systemCustom:
            return false
        }
    }

    /// Default mapping function that maps UIContentSizeCategory to map scale factor (0.8-2.0).
    /// Used internally by `.system` mode.
    internal static let defaultMapping: (UIContentSizeCategory) -> Float = { category in
        let mapping: [UIContentSizeCategory: Float] = [
            .extraSmall: 0.80,
            .small: 0.85,
            .medium: 0.90,
            .large: 1.00,
            .extraLarge: 1.10,
            .extraExtraLarge: 1.25,
            .extraExtraExtraLarge: 1.50,
            .accessibilityMedium: 1.60,
            .accessibilityLarge: 1.75,
            .accessibilityExtraLarge: 1.90,
            .accessibilityExtraExtraLarge: 2.00,
            .accessibilityExtraExtraExtraLarge: 2.00
        ]
        return mapping[category] ?? 1.0
    }

    /// Converts UIContentSizeCategory to a normalized scale value (0.8-2.0).
    internal static func normalizedScale(for category: UIContentSizeCategory) -> Double {
        return Double(defaultMapping(category))
    }
}
