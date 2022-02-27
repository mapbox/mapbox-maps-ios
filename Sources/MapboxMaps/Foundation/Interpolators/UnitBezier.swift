/*
 * The contents of this file are ported from an implementation with the
 * following license:
 *
 * Copyright (C) 2008 Apple Inc. All Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import CoreGraphics

internal struct UnitBezier {
    private let ax: Double
    private let bx: Double
    private let cx: Double

    private let ay: Double
    private let by: Double
    private let cy: Double

    internal init(p1: CGPoint, p2: CGPoint) {
        // Calculate the polynomial coefficients, implicit first and last
        // control points are (0,0) and (1,1).
        cx = 3 * Double(p1.x)
        bx = 3 * (Double(p2.x) - Double(p1.x)) - cx
        ax = 1 - cx - bx

        cy = 3 * Double(p1.y)
        by = 3 * (Double(p2.y) - Double(p1.y)) - cy
        ay = 1 - cy - by
    }

    private func sampleCurveX(_ t: Double) -> Double {
        // `ax t^3 + bx t^2 + cx t' expanded using Horner's rule.
        return ((ax * t + bx) * t + cx) * t
    }

    private func sampleCurveY(_ t: Double) -> Double {
        return ((ay * t + by) * t + cy) * t
    }

    private func sampleCurveDerivativeX(_ t: Double) -> Double {
        return (3 * ax * t + 2 * bx) * t + cx
    }

    // Given an x value, find a parametric value it came from.
    private func solveCurveX(_ x: Double, _ epsilon: Double) -> Double {
        var x2: Double

        // First try a few iterations of Newton's method -- normally very fast.
        var t2 = x
        for _ in 0..<8 {
            x2 = sampleCurveX(t2) - x
            if fabs(x2) < epsilon {
                return t2
            }
            let d2 = sampleCurveDerivativeX(t2)
            if fabs(d2) < 1e-6 {
                break
            }
            t2 = t2 - x2 / d2
        }

        // Fall back to the bisection method for reliability.
        var t0 = 0.0
        var t1 = 1.0
        t2 = x

        if t2 < t0 {
            return t0
        }
        if t2 > t1 {
            return t1
        }

        while t0 < t1 {
            x2 = sampleCurveX(t2)
            if fabs(x2 - x) < epsilon {
                return t2
            }
            if x > x2 {
                t0 = t2
            } else {
                t1 = t2
            }
            t2 = (t1 - t0) * 0.5 + t0
        }

        // Failure.
        return t2
    }

    internal func solve(_ x: Double, _ epsilon: Double) -> Double {
        return sampleCurveY(solveCurveX(x, epsilon))
    }
}
