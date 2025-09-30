import XCTest
@testable import MapboxMaps

class MapboxScaleBarOrnamentViewTests: XCTestCase {

    func testImperialScaleBar() {
        let scaleBar = MockMapboxScaleBarOrnamentView()
        scaleBar.units = .imperial

        for row in ScaleBarTestValues.imperialValues {
            scaleBar.metersPerPoint = row.metersPerPoint

            let numberOfBars = scaleBar.preferredRow().numberOfBars
            XCTAssertEqual(Int(numberOfBars), row.numberOfBars, "The number of scale bars should be \(row.numberOfBars) when there are \(scaleBar.metersPerPoint) feet per point.")
        }
    }

    func testMetricScaleBar() {
        let scaleBar = MockMapboxScaleBarOrnamentView()
        scaleBar.units = .metric

        for row in ScaleBarTestValues.metricValues {
            scaleBar.metersPerPoint = row.metersPerPoint

            let numberOfBars = scaleBar.preferredRow().numberOfBars
            XCTAssertEqual(Int(numberOfBars), row.numberOfBars, "The number of scale bars should be \(row.numberOfBars) when there are \(row.metersPerPoint) meters per point.")
        }
    }

    func testImperialVisibleBars() {
            let scaleBar = MockMapboxScaleBarOrnamentView()
            scaleBar.units = .imperial

            for row in ScaleBarTestValues.imperialValues {
                scaleBar.metersPerPoint = row.metersPerPoint

                scaleBar.layoutSubviews()

                let numberOfBars = row.numberOfBars
                let visibleBars = scaleBar.dynamicContainerView.subviews
                XCTAssertEqual(visibleBars.count, Int(numberOfBars), "\(numberOfBars) should be visible at \(row.metersPerPoint), distance: \(scaleBar.row.distance).")
            }
        }

        func testMetricVisibleBars() {
            let scaleBar = MockMapboxScaleBarOrnamentView()
            scaleBar.units = .metric

            for row in ScaleBarTestValues.metricValues {
                scaleBar.metersPerPoint = row.metersPerPoint

                scaleBar.layoutSubviews()

                let numberOfBars = row.numberOfBars
                let visibleBars = scaleBar.dynamicContainerView.subviews
                XCTAssertEqual(visibleBars.count, Int(numberOfBars), "\(numberOfBars) should be visible at \(row.metersPerPoint), distance: \(scaleBar.row.distance).")
            }
        }

    func testNauticalScaleBar() {
        let scaleBar = MockMapboxScaleBarOrnamentView()
        scaleBar.units = .nautical

        for row in ScaleBarTestValues.nauticalValues {
            scaleBar.metersPerPoint = row.metersPerPoint

            let numberOfBars = scaleBar.preferredRow().numberOfBars
            XCTAssertEqual(Int(numberOfBars), row.numberOfBars, "The number of scale bars should be \(row.numberOfBars) when there are \(scaleBar.metersPerPoint) feet per point.")
        }
    }

    func testNauticalVisibleBars() {
        let scaleBar = MockMapboxScaleBarOrnamentView()
        scaleBar.units = .nautical

        for row in ScaleBarTestValues.nauticalValues {
            scaleBar.metersPerPoint = row.metersPerPoint

            scaleBar.layoutSubviews()

            let numberOfBars = row.numberOfBars
            let visibleBars = scaleBar.dynamicContainerView.subviews
            XCTAssertEqual(visibleBars.count, Int(numberOfBars), "\(numberOfBars) should be visible at \(row.metersPerPoint), distance: \(scaleBar.row.distance).")
        }
    }

    func testMetricScaleBarLessThanOneMeter() {
        let scaleBar = MockMapboxScaleBarOrnamentView()
        scaleBar.units = .metric

        scaleBar.metersPerPoint = 0.004
        let preferredRow = scaleBar.preferredRow()

        XCTAssertEqual(preferredRow.numberOfBars, 1, "Number of bar when max distance is less than 1m should be 1")
        // Distance to displayed should be the nearest 0.25-
        XCTAssertEqual(preferredRow.distance.remainder(dividingBy: 0.25), 0)
        XCTAssertLessThanOrEqual(preferredRow.distance, scaleBar.maximumWidth * scaleBar.metersPerPoint)

        scaleBar.metersPerPoint = 0.001
        XCTAssertEqual(scaleBar.preferredRow().distance, 0, "Distance less than 0.25m should not be rendered")
    }
}

final class MockMapboxScaleBarOrnamentView: MapboxScaleBarOrnamentView {
    override var maximumWidth: CGFloat {
        return 200
    }
}

internal struct ScaleBarTestValues {
    // Provide test values where the metersPerPoint results in a distance slightly greater than the distance in MapboxScaleBarOrnamentView.Constants.imperialTable
    static let imperialValues = [
        (metersPerPoint: 0.001608057543912218, numberOfBars: 1),
        (metersPerPoint: 0.006267938260964437, numberOfBars: 2),
        (metersPerPoint: 0.009394092007081363, numberOfBars: 2),
        (metersPerPoint: 0.015646399499315216, numberOfBars: 2),
        (metersPerPoint: 0.03127716822989985, numberOfBars: 2),
        (metersPerPoint: 0.04690793696048448, numberOfBars: 2),
        (metersPerPoint: 0.07816947442165374, numberOfBars: 2),
        (metersPerPoint: 0.11724639624811534, numberOfBars: 3),
        (metersPerPoint: 0.15632331807457692, numberOfBars: 2),
        (metersPerPoint: 0.3126310053804232, numberOfBars: 2),
        (metersPerPoint: 0.46893869268626953, numberOfBars: 3),
        (metersPerPoint: 0.6252463799921159, numberOfBars: 2),
        (metersPerPoint: 0.9378617546038085, numberOfBars: 3),
        (metersPerPoint: 1.2504771292155012, numberOfBars: 2),
        (metersPerPoint: 1.563092503827194, numberOfBars: 2),
        (metersPerPoint: 2.063277103205902, numberOfBars: 2),
        (metersPerPoint: 4.126538575643074, numberOfBars: 2),
        (metersPerPoint: 8.253061520517416, numberOfBars: 2),
        (metersPerPoint: 16.5061074102661, numberOfBars: 2),
        (metersPerPoint: 24.759153300014788, numberOfBars: 3),
        (metersPerPoint: 33.01219918976347, numberOfBars: 2),
        (metersPerPoint: 66.02438274875821, numberOfBars: 2),
        (metersPerPoint: 99.03656630775295, numberOfBars: 2),
        (metersPerPoint: 123.79570397699901, numberOfBars: 3),
        (metersPerPoint: 165.06093342574243, numberOfBars: 2),
        (metersPerPoint: 247.5913923232293, numberOfBars: 3),
        (metersPerPoint: 330.12185122071617, numberOfBars: 2),
        (metersPerPoint: 660.2436868106636, numberOfBars: 2),
        (metersPerPoint: 990.365522400611, numberOfBars: 2),
        (metersPerPoint: 1650.609193580506, numberOfBars: 2),
        (metersPerPoint: 2475.9137825553744, numberOfBars: 3),
        (metersPerPoint: 3301.218371530242, numberOfBars: 2)
    ]

    // Provide test values where the metersPerPoint results in a distance slightly greater than the distance in MapboxScaleBarOrnamentView.Constants.metricTable
    static let metricValues = [
        (metersPerPoint: 0.00126, numberOfBars: 1),
        (metersPerPoint: 0.00505, numberOfBars: 2),
        (metersPerPoint: 0.010049999999999998, numberOfBars: 2),
        (metersPerPoint: 0.02005, numberOfBars: 2),
        (metersPerPoint: 0.05005, numberOfBars: 2),
        (metersPerPoint: 0.10005000000000001, numberOfBars: 2),
        (metersPerPoint: 0.25005, numberOfBars: 2),
        (metersPerPoint: 0.37505000000000005, numberOfBars: 3),
        (metersPerPoint: 0.50005, numberOfBars: 2),
        (metersPerPoint: 0.75005, numberOfBars: 2),
        (metersPerPoint: 1.0000499999999999, numberOfBars: 2),
        (metersPerPoint: 1.5000499999999999, numberOfBars: 3),
        (metersPerPoint: 2.50005, numberOfBars: 2),
        (metersPerPoint: 5.00005, numberOfBars: 2),
        (metersPerPoint: 7.50005, numberOfBars: 2),
        (metersPerPoint: 15.000050000000002, numberOfBars: 3),
        (metersPerPoint: 25.00005, numberOfBars: 2),
        (metersPerPoint: 50.00005, numberOfBars: 2),
        (metersPerPoint: 100.00004999999999, numberOfBars: 2),
        (metersPerPoint: 150.00005, numberOfBars: 3),
        (metersPerPoint: 250.00005000000002, numberOfBars: 2),
        (metersPerPoint: 500.00005, numberOfBars: 2),
        (metersPerPoint: 1000.0000500000001, numberOfBars: 2),
        (metersPerPoint: 1500.00005, numberOfBars: 3),
        (metersPerPoint: 2000.00005, numberOfBars: 2),
        (metersPerPoint: 2500.00005, numberOfBars: 2),
        (metersPerPoint: 3000.00005, numberOfBars: 3),
        (metersPerPoint: 4000.00005, numberOfBars: 2)
    ]

    // Provide test values where the metersPerPoint results in a distance slightly greater than the distance in MapboxScaleBarOrnamentView.Constants.nauticalTable
    // These values are taken from real app zooming behavior
    static let nauticalValues = [
        (metersPerPoint: 0.018685636340834897, numberOfBars: 2),    // 1 fathom
        (metersPerPoint: 0.01886784553979305, numberOfBars: 2),     // 2 fathoms
        (metersPerPoint: 0.027432, numberOfBars: 3),                // 3 fathoms
        (metersPerPoint: 0.04572, numberOfBars: 2),                 // 5 fathoms
        (metersPerPoint: 0.09144, numberOfBars: 2),                 // 10 fathoms
        (metersPerPoint: 0.18288, numberOfBars: 2),                 // 20 fathoms
        (metersPerPoint: 0.43559919516501105, numberOfBars: 3),     // 30 fathoms
        (metersPerPoint: 0.7195031862129788, numberOfBars: 2),      // 50 fathoms
        (metersPerPoint: 1.4520311785905264, numberOfBars: 2),      // 100 fathoms
        (metersPerPoint: 2.8168278728450895, numberOfBars: 2),      // 200 fathoms
        (metersPerPoint: 11.267246571706606, numberOfBars: 2),      // 1/10 nautical mile
        (metersPerPoint: 27.190774311218263, numberOfBars: 2),      // 1/4 nautical mile
        (metersPerPoint: 54.8725889678557, numberOfBars: 2),        // 1/2 nautical mile
        (metersPerPoint: 109.05781223148568, numberOfBars: 2),      // 1 nautical mile
        (metersPerPoint: 219.45896415877314, numberOfBars: 2),      // 2 nautical miles
        (metersPerPoint: 328.47806658042924, numberOfBars: 3),      // 3 nautical miles
        (metersPerPoint: 547.722366413288, numberOfBars: 2),        // 5 nautical miles
        (metersPerPoint: 1091.565564603607, numberOfBars: 2),       // 10 nautical miles
        (metersPerPoint: 2178.148958008645, numberOfBars: 2),       // 20 nautical miles
        (metersPerPoint: 3279.1430167603594, numberOfBars: 3),      // 30 nautical miles
        (metersPerPoint: 5502.079305391572, numberOfBars: 2),       // 50 nautical miles
        (metersPerPoint: 11048.75430961533, numberOfBars: 2),       // 100 nautical miles
        (metersPerPoint: 22060.258424033687, numberOfBars: 2),      // 200 nautical miles
        (metersPerPoint: 33191.391942996976, numberOfBars: 3),      // 300 nautical miles
        (metersPerPoint: 52810.3283431027, numberOfBars: 2),        // 500 nautical miles
        (metersPerPoint: 9710, numberOfBars: 2),                // 1000 nautical miles (estimated)
        (metersPerPoint: 19144.0, numberOfBars: 2),                // 2000 nautical miles (estimated)
        (metersPerPoint: 28976.0, numberOfBars: 3),                // 3000 nautical miles (estimated)
        (metersPerPoint: 46546.0, numberOfBars: 2)                 // 5000 nautical miles (estimated)
    ]
}
