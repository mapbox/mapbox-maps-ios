@_spi(Experimental) @testable import MapboxMaps
import SwiftUI
import XCTest

/// Tests for Marker functionality and animations.
final class MarkerTests: XCTestCase {

    private let testCoordinate = CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384)

    // MARK: - Basic Functionality Tests

    func testMarkerWithoutModifier() {
        // Verify marker can be created without any modifiers
        let marker = Marker(coordinate: testCoordinate)

        XCTAssertNotNil(marker)
        XCTAssertEqual(marker.coordinate.latitude, testCoordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(marker.coordinate.longitude, testCoordinate.longitude, accuracy: 0.0001)
    }

    func testDefaultMarkerProperties() {
        // Verify marker has correct default values
        let marker = Marker(coordinate: testCoordinate)

        XCTAssertEqual(marker.innerColor, Color(red: 1, green: 1, blue: 1, opacity: 1.0))
        XCTAssertEqual(marker.outerColor, Color(red: 207/255, green: 218/255, blue: 247/255, opacity: 1.0))
        XCTAssertEqual(marker.strokeColor, Color(red: 58/255, green: 89/255, blue: 250/255, opacity: 1.0))
        XCTAssertEqual(marker.coordinate.latitude, testCoordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(marker.coordinate.longitude, testCoordinate.longitude, accuracy: 0.0001)
        XCTAssertNil(marker.text)
    }

    func testSettingMarkerProperties() {
        // Verify marker properties can be set
        let marker = Marker(coordinate: testCoordinate)
            .color(.blue)
            .innerColor(.orange)
            .stroke(.green)
            .text("Test Marker")

        XCTAssertEqual(marker.outerColor, .blue)
        XCTAssertEqual(marker.innerColor, .orange)
        XCTAssertEqual(marker.strokeColor, .green)
        XCTAssertEqual(marker.coordinate.latitude, testCoordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(marker.coordinate.longitude, testCoordinate.longitude, accuracy: 0.0001)
        XCTAssertEqual(marker.text, "Test Marker")
    }

    // MARK: - Animation Effects

    func testMarkerWithWiggleAppear() {
        let marker = Marker(coordinate: testCoordinate)
            .animation(.wiggle, when: .appear)

        XCTAssertNotNil(marker)
        XCTAssertNotNil(marker.animations?.value[.appear])
        if case .wiggle = marker.animations?.value[.appear]?.first {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected wiggle effect")
        }
    }

    func testMarkerWithScaleAppear() {
        let marker = Marker(coordinate: testCoordinate)
            .animation(.scale, when: .appear)

        XCTAssertNotNil(marker)
        XCTAssertNotNil(marker.animations?.value[.appear])
        if case .scale(let from, let to) = marker.animations?.value[.appear]?.first {
            XCTAssertEqual(from, 0.0)
            XCTAssertEqual(to, 1.0)
        } else {
            XCTFail("Expected scale effect")
        }
    }

    func testMarkerWithFadeAppear() {
        let marker = Marker(coordinate: testCoordinate)
            .animation(.fadeIn, when: .appear)

        XCTAssertNotNil(marker)
        XCTAssertNotNil(marker.animations?.value[.appear])
        if case .fade(let from, let to) = marker.animations?.value[.appear]?.first {
            XCTAssertEqual(from, 0.0)
            XCTAssertEqual(to, 1.0)
        } else {
            XCTFail("Expected fade effect")
        }
    }

    func testMarkerWithDisappearAnimation() {
        let marker = Marker(coordinate: testCoordinate)
            .animation(.fadeOut, when: .disappear)

        XCTAssertNotNil(marker)
        XCTAssertNotNil(marker.animations?.value[.disappear])
    }

    // MARK: - Multiple Triggers

    func testMarkerWithAppearAndDisappearTriggers() {
        // Developers write: Marker with appear and disappear animations
        let marker = Marker(coordinate: testCoordinate)
            .animation(.scale, when: .appear)
            .animation(.fadeOut, when: .disappear)

        XCTAssertNotNil(marker.animations?.value[.appear])
        XCTAssertNotNil(marker.animations?.value[.disappear])

        if case .scale = marker.animations?.value[.appear]?.first {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected scale effect for appear")
        }

        if case .fade = marker.animations?.value[.disappear]?.first {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected fade effect for disappear")
        }
    }

    func testMarkerWithStylingAndAnimation() {
        let marker = Marker(coordinate: testCoordinate)
            .color(.red)
            .text("Animated")
            .animation(.wiggle, when: .appear)

        XCTAssertNotNil(marker)
        XCTAssertEqual(marker.outerColor, .red)
        XCTAssertEqual(marker.text, "Animated")
        XCTAssertNotNil(marker.animations?.value[.appear])
    }

    func testMarkerWithChainingOrder() {
        let marker1 = Marker(coordinate: testCoordinate)
            .animation(.wiggle, when: .appear)
            .text("Test")
            .color(.blue)

        let marker2 = Marker(coordinate: testCoordinate)
            .text("Test")
            .color(.blue)
            .animation(.wiggle, when: .appear)

        XCTAssertNotNil(marker1.animations?.value[.appear])
        XCTAssertNotNil(marker2.animations?.value[.appear])
    }

    // MARK: - Combined Effects

    func testCombinedAnimationWithOperator() {
        let marker = Marker(coordinate: testCoordinate)
            .animation(.wiggle, .scale, when: .appear)

        let config = marker.animations?.value[.appear]
        XCTAssertNotNil(config)
        XCTAssertEqual(config?.count, 2)
        let hasWiggle = config?.contains { if case .wiggle = $0 { return true }; return false }
        let hasScale = config?.contains { if case .scale = $0 { return true }; return false }
        XCTAssertEqual(hasWiggle, true)
        XCTAssertEqual(hasScale, true)
    }

    func testCombinedAnimationMultipleEffects() {
        let marker = Marker(coordinate: testCoordinate)
            .animation(.wiggle, .scale, .fadeIn, when: .appear)

        let config = marker.animations?.value[.appear]
        XCTAssertNotNil(config)
        XCTAssertEqual(config?.count, 3)
    }

    func testCombinedScaleAndFade() {
        let marker = Marker(coordinate: testCoordinate)
            .animation(.scale(from: 0.5, to: 1.0), .fade(from: 0.2, to: 1.0), when: .appear)

        let config = marker.animations?.value[.appear]
        XCTAssertNotNil(config)
        XCTAssertEqual(config?.count, 2)

        var foundScale = false
        var foundFade = false
        for effect in config ?? [] {
            if case let .scale(from, to) = effect {
                XCTAssertEqual(from, 0.5)
                XCTAssertEqual(to, 1.0)
                foundScale = true
            }
            if case let .fade(from, to) = effect {
                XCTAssertEqual(from, 0.2)
                XCTAssertEqual(to, 1.0)
                foundFade = true
            }
        }
        XCTAssertTrue(foundScale)
        XCTAssertTrue(foundFade)
    }

    func testCombinedAnimationOnBothTriggers() {
        let marker = Marker(coordinate: testCoordinate)
            .animation(.wiggle, .scale, when: .appear)
            .animation(.scale, .fadeOut, when: .disappear)

        XCTAssertNotNil(marker.animations?.value[.appear])
        XCTAssertNotNil(marker.animations?.value[.disappear])

        XCTAssertEqual(marker.animations?.value[.appear]?.count, 2)
        XCTAssertEqual(marker.animations?.value[.disappear]?.count, 2)
    }

    // MARK: - Custom Parameters

    func testScaleEffectCustomParameters() {
        let marker = Marker(coordinate: testCoordinate)
            .animation(.scale(from: 0.5, to: 1.5), when: .appear)

        let config = marker.animations?.value[.appear]
        XCTAssertNotNil(config)
        if case let .scale(from, to) = config?.first {
            XCTAssertEqual(from, 0.5)
            XCTAssertEqual(to, 1.5)
        } else {
            XCTFail("Expected scale effect with from: 0.5, to: 1.5")
        }
    }

    func testFadeEffectCustomParameters() {
        let marker = Marker(coordinate: testCoordinate)
            .animation(.fade(from: 0.2, to: 0.8), when: .appear)

        let config = marker.animations?.value[.appear]
        XCTAssertNotNil(config)
        if case let .fade(from, to) = config?.first {
            XCTAssertEqual(from, 0.2)
            XCTAssertEqual(to, 0.8)
        } else {
            XCTFail("Expected fade effect with from: 0.2, to: 0.8")
        }
    }

    func testDefaultScaleParameters() {
        let marker = Marker(coordinate: testCoordinate)
            .animation(.scale, when: .appear)

        let config = marker.animations?.value[.appear]
        XCTAssertNotNil(config)
        if case let .scale(from, to) = config?.first {
            XCTAssertEqual(from, 0.0)
            XCTAssertEqual(to, 1.0)
        } else {
            XCTFail("Expected scale effect with from: 0.0, to: 1.0")
        }
    }

    func testDefaultFadeParameters() {
        let marker = Marker(coordinate: testCoordinate)
            .animation(.fadeIn, when: .appear)

        let config = marker.animations?.value[.appear]
        XCTAssertNotNil(config)
        if case let .fade(from, to) = config?.first {
            XCTAssertEqual(from, 0.0)
            XCTAssertEqual(to, 1.0)
        } else {
            XCTFail("Expected fade effect with from: 0.0, to: 1.0")
        }
    }

    func testScaleWithInvertedRange() {
        // Zoom out effect: scale from larger to smaller
        let marker = Marker(coordinate: testCoordinate)
            .animation(.scale(from: 1.5, to: 0.5), when: .disappear)

        let config = marker.animations?.value[.disappear]
        if case let .scale(from, to) = config?.first {
            XCTAssertEqual(from, 1.5)
            XCTAssertEqual(to, 0.5)
        } else {
            XCTFail("Expected scale effect with inverted range")
        }
    }

    func testScaleToZero() {
        // Disappear by scaling to zero
        let marker = Marker(coordinate: testCoordinate)
            .animation(.scale(from: 1, to: 0), when: .disappear)

        let config = marker.animations?.value[.disappear]
        if case let .scale(from, to) = config?.first {
            XCTAssertEqual(from, 1.0)
            XCTAssertEqual(to, 0.0)
        } else {
            XCTFail("Expected scale to zero")
        }
    }

    // MARK: - Implementation Details

    func testWiggleSequenceStructure() {
        let sequence = MarkerWiggleSequence()

        // Verify the sequence: 20° → -20° → 8° → -8° → 0°
        XCTAssertEqual(sequence.initialAngle, 20.0)
        XCTAssertEqual(sequence.keyframes.count, 4)

        XCTAssertEqual(sequence.keyframes[0].angle, -20.0)
        XCTAssertEqual(sequence.keyframes[1].angle, 8.0)
        XCTAssertEqual(sequence.keyframes[2].angle, -8.0)
        XCTAssertEqual(sequence.keyframes[3].angle, 0.0)
    }

    func testWiggleSequenceTiming() {
        let sequence = MarkerWiggleSequence()

        // Verify individual durations (time to wait before each keyframe)
        XCTAssertEqual(sequence.keyframes[0].duration, 0.0)   // Start immediately
        XCTAssertEqual(sequence.keyframes[1].duration, 0.35)  // Wait 0.35s
        XCTAssertEqual(sequence.keyframes[2].duration, 0.30)  // Wait 0.30s
        XCTAssertEqual(sequence.keyframes[3].duration, 0.25)  // Wait 0.25s

        // Verify cumulative timing adds up correctly
        let totalDuration = sequence.keyframes.reduce(0.0) { $0 + $1.duration }
        XCTAssertEqual(totalDuration, 0.9, accuracy: 0.001)
    }

    func testWiggleSequenceEndsAtZero() {
        let sequence = MarkerWiggleSequence()
        let finalAngle = sequence.keyframes.last?.angle

        XCTAssertEqual(finalAngle, 0.0)
    }

    func testWiggleSequenceTotalDuration() {
        let sequence = MarkerWiggleSequence()

        XCTAssertEqual(sequence.totalDuration, 1.2)

        // Calculate cumulative time from durations
        let cumulativeTime = sequence.keyframes.reduce(0.0) { $0 + $1.duration }

        // Cumulative time should be 0.9 (within the 1.2 total duration budget)
        XCTAssertEqual(cumulativeTime, 0.9, accuracy: 0.001)
        XCTAssertLessThanOrEqual(cumulativeTime, sequence.totalDuration)
    }
}
