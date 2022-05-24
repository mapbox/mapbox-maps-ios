import XCTest
import Foundation
import MapboxMaps

@MainActor
class SpecsBenchmark: XCTestCase {
    override class var defaultPerformanceMetrics: [XCTPerformanceMetric] {
        XCTPerformanceMetric.all
    }

    func testBaselineMeasure() throws {
        let scenario = Scenario(name: "manual", commands: [
        ])

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

}

extension SpecsBenchmark {
    func runScenarioBenchmark(name: String, timeout: TimeInterval = 60) throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: name, withExtension: "json"))
        let scenario = try Scenario(filePath: url)

        try measureScenario(scenario, timeout: timeout)
    }

    func measureScenario(_ scenario: Scenario, timeout: TimeInterval = 60) throws {
        measure {
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
    }
}
