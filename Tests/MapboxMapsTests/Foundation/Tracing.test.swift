import XCTest
import os
@_spi(Experimental) @testable import MapboxMaps
@_implementationOnly import MapboxCoreMaps_Private.Tracing_Internal

final class TracingTests: XCTestCase {
    static var defaultTracing: TracingBackendType?

    override static func setUp() {
        super.setUp()

        defaultTracing = CoreTracing.getBackendType()
    }

    override static func tearDown() {
        super.tearDown()

        // Restore CoreMaps default tracing to prevent side-effects
        defaultTracing.map(CoreTracing.setTracingBackendTypeFor)
    }

    func testEmptyEnvValue() {
        let tracing = parseTracingEnv("")

        XCTAssertEqual(tracing, .enabled)
    }

    func testMissingEnvValue() {
        let tracing = parseTracingEnv(nil)

        XCTAssertEqual(tracing, .disabled)
    }

    func testDisabledTracing() {
        let tracing = parseTracingEnv("disabled")

        XCTAssertEqual(tracing, .disabled)
    }

    func testEnabledTracingWithEnabledWord() {
        let tracing = parseTracingEnv("enabled")

        XCTAssertEqual(tracing, .enabled)
    }

    func testEnabledTracingWithValue1() {
        let tracing = parseTracingEnv("1")

        XCTAssertEqual(tracing, .enabled)
    }

    func testMultipleComponents() {
        let tracing = parseTracingEnv("core,platform")

        XCTAssertTrue(tracing.contains(.core))
        XCTAssertTrue(tracing.contains(.platform))
    }

    func testSingleComponent() {
        let tracing = parseTracingEnv("platform")

        XCTAssertFalse(tracing.contains(.core))
        XCTAssertTrue(tracing.contains(.platform))
    }

    func testSingleComponentUPPERCASE() {
        let tracing = parseTracingEnv("PLATFORM")

        XCTAssertFalse(tracing.contains(.core))
        XCTAssertTrue(tracing.contains(.platform))
    }

    func testMultipleComponentsWithEmptyComponents() {
        let tracing = parseTracingEnv(" , core, ,,platform,")

        XCTAssertEqual(tracing, [.core, .platform])
    }

    func testIncorrectComponent() {
        let tracing = parseTracingEnv("abc")

        XCTAssertEqual(tracing, [])
    }

    func testRuntimeSetterPlatform() {
        let tracing = Tracing.runtimeValue(provider: envProvider("platform"))

        XCTAssertEqual(tracing, .platform)
        XCTAssertFalse(tracing.contains(.core))

        XCTAssertEqual(CoreTracing.getBackendType(), .noop)
    }

    func testRuntimeSetterCore() {
        let tracing = Tracing.runtimeValue(provider: envProvider("core"))

        XCTAssertEqual(tracing, .core)
        XCTAssertFalse(tracing.contains(.platform))

        XCTAssertEqual(CoreTracing.getBackendType(), .platform)
    }

    func testCoreAssignment() {
        CoreTracing.setTracingBackendTypeFor(.noop)

        Tracing.status = .core

        XCTAssertEqual(Tracing.getBackendType(), .platform)
    }

    func testPlatformAssignment() {
        CoreTracing.setTracingBackendTypeFor(.noop)

        Tracing.status = .platform

        XCTAssertEqual(Tracing.getBackendType(), .noop)
    }

    func testDisabledOSLog() {
        Tracing.status = .disabled

        XCTAssertEqual(OSLog.platform, .disabled)
        XCTAssertEqual(OSLog.poi, .disabled)
    }

    func testEnabledCoreOSLog() {
        Tracing.status = .core

        XCTAssertEqual(OSLog.platform, .disabled)
        XCTAssertEqual(OSLog.poi, .disabled)
    }

    func testEnabledPlatformOSLog() {
        Tracing.status = .platform

        XCTAssertNotEqual(OSLog.platform, .disabled)
        XCTAssertNotEqual(OSLog.poi, .disabled)
    }

    func parseTracingEnv(_ value: String?) -> MapboxMaps.Tracing {
        Tracing.calculateRuntimeValue(provider: envProvider(value))
    }

    func envProvider(_ value: String?) -> MapboxMaps.Tracing.EnvironmentVariableProvider {
        return { $0 == Tracing.environmentVariableName ? value : nil }
    }
}
