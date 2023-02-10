import Foundation
import MapboxCoreMaps

// MARK: - Utils

internal struct Utils {
    /// Converts the given angle (in radians) to be numerically close to the anchor angle, allowing it to be
    /// interpolated properly without sudden jumps.
    /// - Parameters:
    ///   - sourceAngle: Angle in radians.
    ///   - anchorAngle: Angle in radians.
    /// - Returns: Normalized angle.
    internal static func normalize(angle sourceAngle: Double, anchorAngle: Double) -> Double {
        if sourceAngle.isNaN || anchorAngle.isNaN {
            return 0
        }

        var angle = Utils.wrap(forValue: sourceAngle, min: -Double.pi, max: Double.pi)
        if angle == -Double.pi {
            angle = Double.pi
        }

        let diff = fabs(angle - anchorAngle)

        if fabs(angle - (Double.pi * 2) - anchorAngle) < diff {
            angle -= (Double.pi * 2)
        } else if fabs(angle + (Double.pi * 2) - anchorAngle) < diff {
            angle += (Double.pi * 2)
        }

        return angle
    }

    internal static func wrap(forValue value: Double, min minValue: Double, max maxValue: Double) -> Double {

        if value >= minValue && value < maxValue {
            return value
        } else if value == maxValue {
            return minValue
        }

        let delta = maxValue - minValue
        let wrapped = minValue + ((value - minValue).truncatingRemainder(dividingBy: delta))
        return value < minValue ? wrapped + delta : wrapped
    }
}
