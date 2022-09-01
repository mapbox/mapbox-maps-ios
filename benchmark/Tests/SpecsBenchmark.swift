import XCTest
import Foundation
import MapboxMaps

@MainActor
class SpecsBenchmark: XCTestCase {
    func testBaselineMeasure() throws {
        let scenario = Scenario(name: "manual", commands: [
        ])

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
        try runScenarioBenchmark(name: "nav-day-munich-zoom-tilepack", timeout: 120)
    }

    func testNavDayMunichDriveTilePack() throws {
        try runScenarioBenchmark(name: "nav-day-munich-drive-tilepack",
                                 shouldSkipWarmupRun: true,
                                 iterationCount: 1,
                                 extraMetrics: [FPSMetric(testCase: self)],
                                 timeout: 1800)
    }

    func testPerformanceAfterSnapshot() throws {
        let createMap = CreateMapCommand(style: .streets, camera: CameraOptions())
        let takeSnapshot = TakeSnapshotCommand()
        let playSequence = PlaySequenceCommand(filename: "pan-zoom-rotate-pitch.json", playbackCount: 1)
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
        let scenario = try Scenario(filePath: url, splitAt: measureFrom)

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
        options.invocationOptions = [.manuallyStop]

        if let iterationCount = iterationCount {
            options.iterationCount = iterationCount
        }

        let setupExpectation = expectation(description: "Setup for '\(name)' finished")
        Task {
            try await scenario.runSetup(for: metrics)
            setupExpectation.fulfill()
        }

        wait(for: [setupExpectation], timeout: timeout)

        var runIndex = 0
        measure(metrics: metrics, options: options) {
            defer { runIndex += 1 }
            if shouldSkipWarmupRun && runIndex == 0 { return self.stopMeasuring() }

            let scenarioExpectation = expectation(description: "Scenario '\(name)' finished")
            Task {
                try await scenario.runBenchmark(for: metrics)
                scenarioExpectation.fulfill()
                self.stopMeasuring()
                scenario.cleanupBenchmark()
            }

            waitForExpectations(timeout: timeout) { error in
                XCTAssertNil(error)
            }

            if runIndex == options.iterationCount {
                scenario.cleanupSetup()
            }
        }
    }
}
