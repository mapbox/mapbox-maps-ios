import XCTest

/// A performance benchmark that tracks the SDK initialization time.
final class InitSDKBenchmark: BaseBenchmark {

    func test_sla_SDKInitializationTime() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip()
        }

        measure(options: .default) {
            onMapReady { _ in } // sets up the map and does nothing else
        }
    }
}
