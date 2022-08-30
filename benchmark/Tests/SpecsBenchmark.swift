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
        try runScenarioBenchmark(name: "streets-munich-ttrc-warm")
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
        let createMap = CreateMapCommand(
            style: .streets,
            camera: CameraOptions(center: CLLocationCoordinate2D(latitude: 48.1386, longitude: 11.5736), zoom: 12)
        )
        let takeSnapshot = TakeSnapshotCommand()
        // record a shorter mixed use(pan, zoom, pitch) sequence with ``MapRecorder``
        let playSequence = PlaySequenceCommand(filename: "munich-zoom-in-out-z10-z20.json", playbackCount: 1)
        let scenario = Scenario(
            name: "Performance after taking a map view snapshot",
            commands: [createMap, takeSnapshot, playSequence]
        )

        // TODO: Add the FPSMetric here

        // create a way to start measuring up from a particular command(not the whole scenario)
        // ref. - https://github.com/mapbox/mapbox-maps-ios-internal/pull/1260/files#diff-5afb2d8af478c4462a7b6ad3f0607e36aacf53443442984fdc39f55fa5834693R25-R27
        try measureScenario(scenario, iterationCount: 1)
    }
}

extension SpecsBenchmark {
    func runScenarioBenchmark(name: String,
                              shouldSkipWarmupRun: Bool = false,
                              iterationCount: Int? = nil,
                              extraMetrics: [XCTMetric] = [],
                              timeout: TimeInterval = 60,
                              functionName: String = #function) throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: name, withExtension: "json"))
        let scenario = try Scenario(filePath: url)

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
                         extraMetrics: [XCTMetric] = [],
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

        scenario.onMapCreate = metrics.compactMap({ $0 as? FPSMetric }).first?.attach(mapView:)

        var runIndex = 0
        measure(metrics: metrics, options: options) {
            defer { runIndex += 1 }
            if shouldSkipWarmupRun && runIndex == 0 { return self.stopMeasuring() }

            let scenarioExpectation = expectation(description: "Scenario '\(name)' finished")
            Task {
                try await scenario.run()
                scenarioExpectation.fulfill()
                self.stopMeasuring()
            }

            waitForExpectations(timeout: timeout) { error in
                XCTAssertNil(error)
            }
        }
    }
}
