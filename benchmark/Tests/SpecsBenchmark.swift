import XCTest
import Foundation
import MapboxMaps

@MainActor
class SpecsBenchmark: XCTestCase {
    override class var defaultPerformanceMetrics: [XCTPerformanceMetric] {
        XCTPerformanceMetric.all
    }

    /// This value cannot be configured and depends on Xcode version.
    /// In next Xcode version this value might change.
    /// XCTest skips first 10 runs performance results and do not include it in XCResult bundle
    /// That's why we have to skip first N runs instead of skip runs at the end
    var numberOfPerformanceRepeats = 20

    func testBaselineMeasure() throws {
        let scenario = Scenario(name: "manual", commands: [
        ])

        // Assign actual number of repeats
        // to support changes over Xcode versions
        numberOfPerformanceRepeats = try measureScenario(scenario)
        print("Actual number of times Xcode run Performance test is \(numberOfPerformanceRepeats)")
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
        try runScenarioBenchmark(name: "nav-day-munich-zoom", timeout: 120)
    }

    func testNavDayMunichZoomTilepack() throws {
        try runScenarioBenchmark(name: "nav-day-munich-zoom-tilepack", timeout: 120)
    }
    
    func testNavDayMunichDriveTilePack() throws {
        try runScenarioBenchmark(name: "nav-day-munich-drive-tilepack",
                                 maxRepeatCount: 1,
                                 timeout: 1800)
    }
}

extension SpecsBenchmark {

    @discardableResult
    func runScenarioBenchmark(name: String,
                              maxRepeatCount: Int? = nil,
                              timeout: TimeInterval = 60,
                              functionName: String = #function) throws -> Int {
        let url = try XCTUnwrap(Bundle.main.url(forResource: name, withExtension: "json"))
        let scenario = try Scenario(filePath: url)

        return try measureScenario(scenario, maxRepeatCount: maxRepeatCount, timeout: timeout, functionName: functionName)
    }

    func measureScenario(_ scenario: Scenario,
                         maxRepeatCount: Int? = nil,
                         timeout: TimeInterval = 60,
                         functionName: String = #function) throws -> Int {
        let numberOfSkips = maxRepeatCount.map({ numberOfPerformanceRepeats - $0 }) ?? 0
        var counter = 0

        measure {
            defer {
                counter += 1
            }
            if counter < numberOfSkips {
                print("Skipping test '\(functionName)' #\(counter + 1)")
                return
            } else {
                print("Executing test '\(functionName)' #\(counter + 1)")
            }

            let scenarioExpectation = expectation(description: "Scenario '\(name)' finished")
            Task {
                try await scenario.run()
                scenarioExpectation.fulfill()
            }

            waitForExpectations(timeout: timeout) { error in
                XCTAssertNil(error)
                self.stopMeasuring()
            }
        }
        return counter
    }
}
