import UIKit

// swiftlint:disable identifier_name

/// "fly-to" interpolator object that implements an “optimal path” animation
internal struct FlyToInterpolator {

    /// Returns the visible span on the ground, measured in pixels with respect to the initial scale.
    /// Assumes an angular field of view of 2 arctan ½ ≈ 53°.
    fileprivate var w: (Double) -> Double

    /// Returns the distance along the flight path as projected onto the
    /// ground plane, measured in pixels from the world image origin at the
    /// initial scale.
    fileprivate var u: (Double) -> Double

    /// S: Total length of the flight path, measured in ρ-screenfuls.
    fileprivate var S: Double

    fileprivate let sourceZoom: CGFloat
    fileprivate let sourceScale: CGFloat

    fileprivate let sourcePoint: CGPoint
    fileprivate let destPoint: CGPoint

    internal let sourceBearing: Double
    internal var destBearing: Double

    internal let sourcePitch: CGFloat
    internal let destPitch: CGFloat

    internal let sourcePadding: UIEdgeInsets
    internal let destPadding: UIEdgeInsets

    // Default values
    fileprivate let defaultVelocity = 1.2

    // ρ: The relative amount of zooming that takes place along the flight
    // path. A high value maximizes zooming for an exaggerated animation, while
    // a low value minimizes zooming for something closer to easeTo().
    fileprivate static let rho = 1.42

    /// Interpolator object that implements an “optimal path” animation, as detailed in:
    ///
    /// Van Wijk, Jarke J.; Nuij, Wim A. A. “Smooth and efficient zooming and panning.”
    /// INFOVIS ’03. pp. 15–22. https://www.win.tue.nl/~vanwijk/zoompan.pdf#page=5
    ///
    /// Where applicable, local variable documentation begins with the associated
    /// variable or function in van Wijk (2003).
    ///
    /// - Parameters:
    ///   - source: Start camera (parameters are NOT clamped to properties from MapCameraOptions)
    ///   - dest: End camera (parameters ARE clamped to properties from MapCameraOptions)
    ///   - mapCameraOptions: Camera-specific capabilities of the map, for example, min-zoom, max-pitch
    ///   - size: Map View size in points
    internal init(from source: CameraState, to dest: CameraOptions, cameraBounds: CameraBounds, size: CGSize) {
        //swiftlint:disable:previous function_body_length
        // Initial conditions
        let sourcePaddingParam   = source.padding
        let sourceCoord          = source.center
        let sourceZoomParam      = CGFloat(source.zoom)
        let sourcePitchParam     = CGFloat(source.pitch)
        let sourceBearingParam   = CLLocationDirection(source.bearing)

        sourceZoom  = sourceZoomParam
        sourceScale = pow(2, sourceZoom)

        sourcePadding = sourcePaddingParam
        sourcePitch = sourcePitchParam

        // Dest conditions
        destPadding = dest.padding ?? sourcePaddingParam
        let destCoord = dest.center ?? sourceCoord

        // Note that the source arguments are NOT clamped - these are assumed to be valid parameters
        let compilerWorkaround = sourceZoom
        let destZoom = (dest.zoom ?? compilerWorkaround).clamped(to: CGFloat(cameraBounds.minZoom)...CGFloat(cameraBounds.maxZoom))
        destPitch = (dest.pitch ?? sourcePitchParam).clamped(to: CGFloat(cameraBounds.minPitch)...CGFloat(cameraBounds.maxPitch))
        destBearing = dest.bearing ?? sourceBearingParam

        // Unwrap
        let sourceCoordUnwrapped = sourceCoord.unwrapForShortestPath(destCoord)

        let sourcePointTemp = Projection.project(sourceCoordUnwrapped, zoomScale: sourceScale)
        let destPointTemp   = Projection.project(destCoord, zoomScale: sourceScale)
        sourcePoint         = CGPoint(x: sourcePointTemp.x, y: sourcePointTemp.y)
        destPoint           = CGPoint(x: destPointTemp.x, y: destPointTemp.y)

        // Minimize rotation by taking the shorter path around the circle.
        destBearing = -Utils.normalize(angle: -destBearing.toRadians(), anchorAngle: sourceBearingParam.toRadians()).toDegrees()
        sourceBearing = Utils.normalize(angle: sourceBearingParam.toRadians(), anchorAngle: destBearing.toRadians()).toDegrees()

        // w₀: Initial visible span, measured in pixels at the initial scale.
        // Known henceforth as a <i>screenful</i>.

        let w0 = Double(max(size.width - destPadding.left - destPadding.right,
                            size.height - destPadding.top - destPadding.bottom))

        // w₁: Final visible span, measured in pixels with respect to the initial
        // scale.
        let w1 = w0 / pow(2.0, Double(destZoom - sourceZoom))

        // Length of the flight path as projected onto the ground plane, measured
        // in pixels from the world image origin at the initial scale.
        let u1 = Double(hypot( (destPoint.x - sourcePoint.x), (destPoint.y - sourcePoint.y)))

        /** ρ: The relative amount of zooming that takes place along the flight
            path. A high value maximizes zooming for an exaggerated animation, while
            a low value minimizes zooming for something closer to easeTo().

            1.42 is the average value selected by participants in the user study in
            van Wijk (2003). A value of 6<sup>¼</sup> would be equivalent to the
            root mean squared average velocity, V<sub>RMS</sub>. A value of 1
            produces a circular motion. */
        let rho = Self.rho

        // TODO: Support min-zoom, which was exposed as peakAltitude pre v10
        /*
        if (animation.minZoom || linearZoomInterpolation) {
            double minZoom = util::min(animation.minZoom.value_or(startZoom), startZoom, zoom);
            minZoom = util::clamp(minZoom, state.getMinZoom(), state.getMaxZoom());
            /// w<sub>m</sub>: Maximum visible span, measured in pixels with respect
            /// to the initial scale.
            double wMax = w0 / state.zoomScale(minZoom - startZoom);
            rho = u1 != 0 ? std::sqrt(wMax / u1 * 2) : 1.0;
        }
        */

        /// ρ²
        let rho2 = rho * rho

        /**
         * rᵢ: Returns the zoom-out factor at one end of the animation.
         *
         * @param i ∈ {0, 1}
         */
        let r: (Int) -> Double = { (i: Int) in

            // // bᵢ
            // val b = (w1 * w1 - w0 * w0 + (if (i == 0) 1 else -1) * rho2 * rho2 * u1 * u1) /
            //     (2 * (if (i == 0) w0 else w1) * rho2 * u1)
            // return ln(sqrt(b * b + 1) - b)

            // bᵢ
            // Split into sub-expressions to "type-check in reasonable time" error
            let w2        = (w1 * w1) - (w0 * w0)
            let numMult   = (i == 0 ? 1.0 : -1.0)
            let rho4      = rho2 * rho2 * u1 * u1

            let denomMult = (i == 0) ? w0 : w1
            let denom     = 2.0 * denomMult * rho2 * u1

            let b = (w2 + numMult * rho4) / denom
            return log(sqrt(b * b + 1) - b) // log is natural log
        }

        // r₀: Zoom-out factor during ascent.
        let r0 = (u1 != 0.0) ? r(0) : .infinity
        let r1 = (u1 != 0.0) ? r(1) : .infinity

        // When u₀ = u₁, the optimal path doesn’t require both ascent and descent.
        let isClose = (fabs(u1) < 0.000001) || r0.isInfinite || r1.isInfinite

        /** w(s): Returns the visible span on the ground, measured in pixels with respect to the initial scale.
         * Assumes an angular field of view of 2 arctan ½ ≈ 53°.
         */

        let wMult = w1 < w0 ? -1.0 : 1.0
        w = { s in
            if isClose {
                return exp(wMult * rho * s)
            } else {
                return cosh(r0) / cosh(r0 + rho * s)
            }
        }

        // u(s): Returns the distance along the flight path as projected onto the
        // ground plane, measured in pixels from the world image origin at the
        // initial scale.

        // auto u = [=](double s) {
        //     return (isClose ? 0.
        //             : (w0 * (std::cosh(r0) * std::tanh(r0 + rho * s) - std::sinh(r0)) / rho2 / u1));
        // };

        u = { s in
            if isClose {
                return 0.0
            } else {
                return (w0 * (cosh(r0) * tanh(r0 + rho * s) - sinh(r0)) / rho2 / u1)
            }
        }

        // S: Total length of the flight path, measured in ρ-screenfuls.
        S = (isClose) ?
            (abs(log(w1 / w0)) / rho) :
            ((r1 - r0) / rho)
    }

    // MARK: - Interpolated coordinate parameters

    /// Calculates the coordinate given a fraction in [0,1].
    ///
    /// - Parameter fraction: Parameter between 0 and 1. 0 represents the start position, 1 the end position.
    /// - Returns: coordinate
    internal func coordinate(at fraction: Double) -> CLLocationCoordinate2D {
        // s: The distance traveled along the flight path, measured in
        // ρ-screenfuls.
        let s = fraction * S
        let us = (fraction >= 1.0) ? 1.0 : u(s)

        let interpolated: CGPoint = CGPoint.interpolate(origin: sourcePoint,
                                                        destination: destPoint,
                                                        fraction: CGFloat(us))

        let position = MercatorCoordinate(x: Double(interpolated.x), y: Double(interpolated.y))

        return Projection.unproject(position, zoomScale: sourceScale)
    }

    /// Calculates the zoom level given a fraction in [0,1].
    ///
    /// - Parameter fraction: Parameter between 0 and 1. 0 represents the start position, 1 the end position.
    /// - Returns: zoom level
    internal func zoom(at fraction: Double) -> Double {
        let s = fraction * S
        return Double(sourceZoom) + log2(1.0 / w(s))
    }

    /// Calculates the bearing given a fraction in [0,1].
    /// This is a linear interpolation.
    ///
    /// - Parameter fraction: Parameter between 0 and 1. 0 represents the start position, 1 the end position.
    /// - Returns: bearing
    internal func bearing(at fraction: Double) -> Double {
        return (1.0 - fraction) * sourceBearing + fraction * destBearing
    }

    /// Calculates the bearing given a fraction in [0,1].
    /// This is a linear interpolation.
    ///
    /// - Parameter fraction: Parameter between 0 and 1. 0 represents the start position, 1 the end position.
    /// - Returns: bearing
    internal func pitch(at fraction: Double) -> Double {
        return (1.0 - fraction) * Double(sourcePitch) + fraction * Double(destPitch)
    }

    /// Calculates the padding given a fraction in [0,1].
    /// This is a linear interpolation.
    ///
    /// - Parameter fraction: Parameter between 0 and 1. 0 represents the start position, 1 the end position.
    /// - Returns: padding
    internal func padding(at fraction: Double) -> UIEdgeInsets {
        let t = CGFloat(fraction)

        // TODO: Consider working on with the __padding (EdgeInsets) parameter.
        let top    = ((1.0 - t) * sourcePadding.top)    + (t * destPadding.top)
        let bottom = ((1.0 - t) * sourcePadding.bottom) + (t * destPadding.bottom)
        let left   = ((1.0 - t) * sourcePadding.left)   + (t * destPadding.left)
        let right  = ((1.0 - t) * sourcePadding.right)  + (t * destPadding.right)

        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    // MARK: - Animation properties

    /// Calculate an ideal animation duration given a velocity.
    ///
    /// - Parameter velocity: Average velocity, measured in ρ-screenfuls per second. If nil,
    /// a default value is used.
    /// - Returns: a suitable duration for the animation.
    internal func duration(with velocity: Double? = nil) -> TimeInterval {
        /// V: Average velocity, measured in ρ-screenfuls per second.
        if let velocity = velocity {
            return (S * Self.rho) / velocity
        } else {
            return S / defaultVelocity
        }
    }
}
// swiftlint:enable identifier_name
