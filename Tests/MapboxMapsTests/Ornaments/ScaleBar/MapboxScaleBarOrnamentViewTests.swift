import XCTest
@testable import MapboxMaps

class MapboxScaleBarOrnamentViewTests: MapViewIntegrationTestCase {
    
    func testImperialScaleBar() throws {
        let mapView = try XCTUnwrap(self.mapView, "Map view could not be found")

        let initialSubviews = mapView.subviews.filter { $0 is MapboxScaleBarOrnamentView }

        let scaleBar = try XCTUnwrap(initialSubviews.first as? MapboxScaleBarOrnamentView, "The MapView should include a scale bar as a subview")
        
        if !scaleBar.isMetricLocale {
            let rows = MapboxScaleBarOrnamentView.Constants.imperialTable
            for row in rows {
                scaleBar.metersPerPoint = row.distance
                print("distance: \(row.distance), row: \(row), preferred row: \(scaleBar.row), mpp: \(scaleBar.metersPerPoint)")
                XCTAssertEqual(UInt(scaleBar.dynamicContainerView.subviews.count), row.numberOfBars, "The scale bars should be equal when the value for metersPerPoint is \(scaleBar.metersPerPoint)")
            }
        }
    }
}

extension MapboxScaleBarOrnamentView {
    
    // Reverses the conversions we do to get the distance in feet for the scale bar.
    func metersFromFeet(_ distance: Double) -> Double {
        let dividedByWidth = distance / Double(maximumWidth)
        let inMeters = dividedByWidth / Constants.feetPerMeter
        return inMeters
    }
}
