import XCTest

/// A performance benchmark that tracks the SDK initialization time.
final class InitSDKBenchmark: BaseBenchmark {

    func test_sla_SDKInitializationTime() throws {
        benchmark {
            onMapReady { _ in
                self.stopBenchmark()
            }
        }
    }
}
