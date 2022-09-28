import XCTest
import Foundation
import MapboxMaps

@MainActor
class SpecsBenchmark: XCTestCase {
    func testBaselineMeasure() throws {
        let scenario = Scenario(name: "manual")

        // Assign actual number of repeats
        // to support changes over Xcode versions
        try measureScenario(scenario)
    }

    func testNavDayMunichTtrcCold() throws {
        try runScenarioBenchmark(name: "nav-day-munich-ttrc-cold")
    }

    func testNavDayMunichTtrcWarm() throws {
        try runScenarioBenchmark(name: "nav-day-munich-ttrc-warm")
    }

    func testStreetsMunichTtrcCold() throws {
        try runScenarioBenchmark(name: "streets-munich-ttrc-cold")
    }

    func testStreetsMunichTtrcWarm() throws {
        try runScenarioBenchmark(name: "streets-munich-ttrc-warm", measureFrom: { $0 is CreateMapCommand })
    }

    func testNavDayMunichZoom() throws {
        try runScenarioBenchmark(name: "nav-day-munich-zoom", extraMetrics: [FPSMetric(testCase: self)], timeout: 120)
    }

    func testNavDayMunichZoomTilepack() throws {
        try runScenarioBenchmark(name: "nav-day-munich-zoom-tilepack", extraMetrics: [FPSMetric(testCase: self)], timeout: 120)
    }

    func testNavDayMunichDriveTilePack() throws {
        try runScenarioBenchmark(name: "nav-day-munich-drive-tilepack",
                                 shouldSkipWarmupRun: true,
                                 iterationCount: 1,
                                 extraMetrics: [FPSMetric(testCase: self)],
                                 timeout: 1800)
    }

    func test1TapMunichRecording() throws {
        try runScenarioBenchmark(name: "1tap-munich",
                                 shouldSkipWarmupRun: true,
                                 iterationCount: 1,
                                 extraMetrics: [FPSMetric(testCase: self)],
                                 timeout: 1800)
    }

    func testPerformanceAfterSnapshot() throws {
        let createMap = CreateMapCommand(style: .streets, camera: CameraOptions())
        let takeSnapshot = TakeSnapshotCommand()
        let playSequence = try PlaySequenceCommand(filename: "pan-zoom-rotate-pitch.json", playbackCount: 1)
        let scenario = Scenario(
            name: "Performance after taking a map view snapshot",
            setupCommands: [createMap, takeSnapshot],
            benchmarkCommands: [playSequence]
        )

        try measureScenario(scenario, extraMetrics: [FPSMetric(testCase: self)])
    }
}

extension SpecsBenchmark {
    func runScenarioBenchmark(name: String,
                              shouldSkipWarmupRun: Bool = false,
                              iterationCount: Int? = nil,
                              extraMetrics: [Metric] = [],
                              measureFrom: ((AsyncCommand) -> Bool)? = nil,
                              timeout: TimeInterval = 60,
                              functionName: String = #function) throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: name, withExtension: "json"))
        let scenario = try Scenario(filePath: url, name: name, splitAt: measureFrom)

        try measureScenario(scenario,
                            shouldSkipWarmupRun: shouldSkipWarmupRun,
                            iterationCount: iterationCount,
                            extraMetrics: extraMetrics,
                            timeout: timeout,
                            functionName: functionName)
    }

    func measureScenario(_ scenario: Scenario,
                         shouldSkipWarmupRun: Bool = false,
                         iterationCount: Int? = nil,
                         extraMetrics: [Metric] = [],
                         timeout: TimeInterval = 60,
                         functionName: String = #function) throws {
        let metrics = extraMetrics + [
            XCTCPUMetric(),
            XCTMemoryMetric(),
            XCTStorageMetric(),
            XCTClockMetric(),
            ThermalStateMetric()
        ]

        let options = XCTMeasureOptions()
        options.invocationOptions = [.manuallyStart, .manuallyStop]

        if let iterationCount = iterationCount {
            options.iterationCount = iterationCount
        }

        var runIndex = 0
        measure(metrics: metrics, options: options) {
            defer { runIndex += 1 }
            if shouldSkipWarmupRun && runIndex == 0 {
                startMeasuring()
                stopMeasuring()
                return
            }


            let scenarioExpectation = expectation(description: "Scenario '\(name)' finished")

            Task {
                try await scenario.runSetup(for: metrics)

                self.startMeasuring()
                try await scenario.runBenchmark(for: metrics)
                self.stopMeasuring()

                scenarioExpectation.fulfill()
                scenario.cleanup()
            }

            waitForExpectations(timeout: timeout) { error in
                XCTAssertNil(error)
            }
        }
    }
}
