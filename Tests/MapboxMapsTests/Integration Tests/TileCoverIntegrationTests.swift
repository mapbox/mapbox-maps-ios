import XCTest
@_spi(Experimental) import MapboxMaps

class TileCoverIntegrationTests: MapViewIntegrationTestCase {
    func testTileCover() {
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: 5.5))
        let tileIds = mapView.mapboxMap.tileCover(for: TileCoverOptions(tileSize: 512, minZoom: 0, maxZoom: 22, roundZoom: false))
        XCTAssertFalse(tileIds.isEmpty)
        for tileId in tileIds {
            XCTAssertEqual(tileId.z, 5) // sanity check
        }
    }

    func testTileCoverDefaultParameters() throws {
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: 5.5))
        let tileIds = mapView.mapboxMap.tileCover(for: TileCoverOptions())
        XCTAssertFalse(tileIds.isEmpty)
        for tileId in tileIds {
            XCTAssertEqual(tileId.z, 5) // sanity check
        }
    }
}
