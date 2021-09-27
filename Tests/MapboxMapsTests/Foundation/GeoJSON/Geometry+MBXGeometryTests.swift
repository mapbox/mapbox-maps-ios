import XCTest
import CoreLocation
@testable import MapboxMaps

internal class GeometryMBXGeometryTests: XCTestCase {

    // MARK: - Geometry → Turf Geometry
    func testMBXGeometryToTurfGeometry_Point() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 40, longitude: 40)
        let mbxGeometry = MapboxCommon.Geometry(geometry: .point(Point(coordinate)))

        // When
        let turfGeometry = Geometry(mbxGeometry)

        // Then
        guard let expectedTurfPoint = turfGeometry?.value as? Point else {
            XCTFail("Could not convert Geometry to Turf Point geometry")
            return
        }

        XCTAssertEqual(expectedTurfPoint.coordinates, coordinate)
    }

    func testMBXGeometryToTurfGeometry_Line() {
        // Given
        let lineCoordinates = [
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            CLLocationCoordinate2D(latitude: 0, longitude: 1),
            CLLocationCoordinate2D(latitude: 0, longitude: 2)
        ]

        let mbxGeometry = MapboxCommon.Geometry(geometry: .lineString(LineString(lineCoordinates)))

        // When
        let turfGeometry = Geometry(mbxGeometry)

        // Then
        guard let expectedTurfLineString = turfGeometry?.value as? LineString else {
            XCTFail("Could not convert Geometry to Turf LineString geometry")
            return
        }

        XCTAssertEqual(lineCoordinates, expectedTurfLineString.coordinates)
    }

    func testMBXGeometryToTurfGeometry_Polygon() {
        // Given
        let polygonCoordinates = [
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            CLLocationCoordinate2D(latitude: 1, longitude: 0),
            CLLocationCoordinate2D(latitude: 1, longitude: 1),
            CLLocationCoordinate2D(latitude: 0, longitude: 0)
        ]

        let mbxGeometry = MapboxCommon.Geometry(geometry: .polygon(Polygon([polygonCoordinates])))

        // When
        let turfGeometry = Geometry(mbxGeometry)

        // Then
        guard let expectedTurfPolygon = turfGeometry?.value as? Polygon else {
            XCTFail("Could not convert Geometry to Turf Polygon geometry.")
            return
        }

        XCTAssertEqual([polygonCoordinates], expectedTurfPolygon.coordinates)
    }

    func testMBXGeometryToTurfGeometry_MultiPoint() {
        // Given
        let coordinate1 = CLLocationCoordinate2D(latitude: -44, longitude: 30)
        let coordinate2 = CLLocationCoordinate2D(latitude: -50, longitude: 40)

        let mbxGeometry = MapboxCommon.Geometry(geometry: .multiPoint(MultiPoint([coordinate1, coordinate2])))

        // When
        let turfGeometry = Geometry(mbxGeometry)

        // Then
        guard let expectedTurfMultiPoint = turfGeometry?.value as? MultiPoint else {
            XCTFail("Could not convert Geometry to Turf Multipoint geometry")
            return
        }

        XCTAssertEqual([coordinate1, coordinate2], expectedTurfMultiPoint.coordinates)
    }

    func testMBXGeometryToTurfGeometry_MultiLineString() {
        // Given
        let line1 = [
            CLLocationCoordinate2D(latitude: 10, longitude: 11),
            CLLocationCoordinate2D(latitude: 10, longitude: 12)
        ]

        let line2 = [
            CLLocationCoordinate2D(latitude: 20, longitude: 30),
            CLLocationCoordinate2D(latitude: 20, longitude: 31)
        ]

        let mbxGeometry = MapboxCommon.Geometry(geometry: .multiLineString(MultiLineString([line1, line2])))

        // When
        let turfGeometry = Geometry(mbxGeometry)

        // Then
        guard let expectedTurfMultiLineString = turfGeometry?.value as? MultiLineString else {
            XCTFail("Could not convert Geometry to Turf MultiLineString geometry")
            return
        }

        let expectedCoordinates = [line1, line2]

        XCTAssertEqual(expectedCoordinates, expectedTurfMultiLineString.coordinates)
    }

    func testMBXGeometryToTurfGeometry_GeometryCollection() {
        // Given
        let polygon1 = [
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            CLLocationCoordinate2D(latitude: 1, longitude: 0),
            CLLocationCoordinate2D(latitude: 1, longitude: 1),
            CLLocationCoordinate2D(latitude: 0, longitude: 0)
        ]

        let polygon2 = [
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            CLLocationCoordinate2D(latitude: -1, longitude: 0),
            CLLocationCoordinate2D(latitude: -1, longitude: -1),
            CLLocationCoordinate2D(latitude: 0, longitude: 0)
        ]

        let mbxGeometry = MapboxCommon.Geometry(geometry: .multiPolygon(MultiPolygon([[polygon1], [polygon2]])))

        // When
        let turfGeometry = Geometry(mbxGeometry)

        // Then
        guard let expectedTurfMultiPolygon = turfGeometry?.value as? MultiPolygon else {
            XCTFail("Could not convert Geometry to Turf MultiPolygon")
            return
        }

        let expectedMultiPolygonCoordinates = [[polygon1], [polygon2]]

        XCTAssertEqual(expectedMultiPolygonCoordinates,
                       expectedTurfMultiPolygon.coordinates)
    }

    // // MARK: - Turf Geometry → Geometry
    func testGeometryToMBXGeometry_Point() {
        // Given
        let point = Point(CLLocationCoordinate2D(latitude: -10, longitude: 10))
        let geometry = Geometry.point(point)

        // When
        let mbxGeometry = MapboxCommon.Geometry(geometry: geometry)

        // Then
        guard let mbxLocationValue = mbxGeometry.extractLocations()?.coordinateValue() else {
            XCTFail("Could not extract NSValues from Geometry")
            return
        }

        XCTAssertEqual(point.coordinates, mbxLocationValue)
    }

    func testGeometryToMBXGeometry_Line() {
        // Given
        let coordinates = [
            CLLocationCoordinate2D(latitude: -12, longitude: -12),
            CLLocationCoordinate2D(latitude: -12, longitude: -18)
        ]

        let line = LineString(coordinates)
        let geometry = Geometry.lineString(line)

        // When
        let mbxGeometry = MapboxCommon.Geometry(geometry: geometry)

        // Then
        guard let mbxLocationValues = mbxGeometry.extractLocationsArray() else {
            XCTFail("Could not extract NSValues from Geometry")
            return
        }

        let mbxGeometryCoordinates = NSValue.toCoordinates(array: mbxLocationValues)

        XCTAssertEqual(line.coordinates, mbxGeometryCoordinates)
    }

    func testGeometryToMBXGeometry_Polygon() {
        // Given
        let coordinates = [
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            CLLocationCoordinate2D(latitude: 1, longitude: 0),
            CLLocationCoordinate2D(latitude: 1, longitude: 1),
            CLLocationCoordinate2D(latitude: 0, longitude: 0)
        ]

        let polygon = Polygon([coordinates])
        let geometry = Geometry.polygon(polygon)

        // When
        let mbxGeometry = MapboxCommon.Geometry(geometry: geometry)

        // Then
        guard let mbxLocationValues = mbxGeometry.extractLocations2DArray() else {
            XCTFail("Could not extract NSValues from Geometry")
            return
        }

        let mbxGeometryCoordinates = NSValue.toCoordinates2D(array: mbxLocationValues)

        XCTAssertEqual(polygon.coordinates, mbxGeometryCoordinates)
    }

    func testGeometryToMBXGeometry_MultiPoint() {
        // Given
        let coordinate1 = CLLocationCoordinate2D(latitude: -44, longitude: 30)
        let coordinate2 = CLLocationCoordinate2D(latitude: -50, longitude: 40)
        let multiPoint = MultiPoint([coordinate1, coordinate2])
        let geometry = Geometry.multiPoint(multiPoint)

        // When
        let mbxGeometry = MapboxCommon.Geometry(geometry: geometry)

        // Then
        guard let mbxLocationValues = mbxGeometry.extractLocationsArray() else {
            XCTFail("Could not extract NSValues from Geometry")
            return
        }

        let mbxGeometryCoordinates = NSValue.toCoordinates(array: mbxLocationValues)

        XCTAssertEqual(multiPoint.coordinates, mbxGeometryCoordinates)
    }

    func testGeometryToMBXGeometry_MultiLineString() {
        // Given
        let line1 = [
            CLLocationCoordinate2D(latitude: 10, longitude: 11),
            CLLocationCoordinate2D(latitude: 10, longitude: 12)
        ]

        let line2 = [
            CLLocationCoordinate2D(latitude: 20, longitude: 30),
            CLLocationCoordinate2D(latitude: 20, longitude: 31)
        ]

        let multiLineString = MultiLineString([line1, line2])
        let geometry = Geometry.multiLineString(multiLineString)

        // When
        let mbxGeometry = MapboxCommon.Geometry(geometry: geometry)

        // Then
        guard let mbxLocationValues = mbxGeometry.extractLocations2DArray() else {
            XCTFail("Could not extract NSValues from Geometry")
            return
        }

        let mbxGeometryCoordinates = NSValue.toCoordinates2D(array: mbxLocationValues)

        XCTAssertEqual(multiLineString.coordinates, mbxGeometryCoordinates)
    }

    func testGeometryToMBXGeometry_MultiPolygon() {
        // Given
        let polygon1 = [
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            CLLocationCoordinate2D(latitude: 1, longitude: 0),
            CLLocationCoordinate2D(latitude: 1, longitude: 1),
            CLLocationCoordinate2D(latitude: 0, longitude: 0)
        ]

        let polygon2 = [
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            CLLocationCoordinate2D(latitude: -1, longitude: 0),
            CLLocationCoordinate2D(latitude: -1, longitude: -1),
            CLLocationCoordinate2D(latitude: 0, longitude: 0)
        ]

        let multiPolygon = MultiPolygon([[polygon1, polygon2]])
        let geometry = Geometry.multiPolygon(multiPolygon)

        // When
        let mbxGeometry = MapboxCommon.Geometry(geometry: geometry)

        // Then
        guard let mbxLocationValues = mbxGeometry.extractLocations3DArray() else {
            XCTFail("Could not extract NSValues from Geometry")
            return
        }

        let mbxGeometryCoordinates = NSValue.toCoordinates3D(array: mbxLocationValues)

        XCTAssertEqual(multiPolygon.coordinates, mbxGeometryCoordinates)
    }

    func testGeometryToMBXGeometry_GeometryCollection() {
        // Given
        let pointCoordinate = CLLocationCoordinate2D(latitude: 8, longitude: 8)

        let polygonCoordinates = [
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            CLLocationCoordinate2D(latitude: 1, longitude: 0),
            CLLocationCoordinate2D(latitude: 1, longitude: 1),
            CLLocationCoordinate2D(latitude: 0, longitude: 0)
        ]

        let point = Geometry.point(Point(pointCoordinate))
        let polygon = Geometry.polygon(Polygon([polygonCoordinates]))
        let geometries = GeometryCollection(geometries: [point, polygon])
        let geometryCollection = Geometry.geometryCollection(geometries)

        // When
        let mbxGeometry = MapboxCommon.Geometry(geometry: geometryCollection)

        // Then
        guard let mbxLocationValues = mbxGeometry.extractGeometriesArray() else {
            XCTFail("Could not extract NSValues from Geometry collection")
            return
        }

        guard let mbxPointGeometryValue = mbxLocationValues[0].extractLocations() else {
            XCTFail("Could not extract NSValues from point within Geometry collection")
            return
        }

        guard let mbxPolygonGeometryValues = mbxLocationValues[1].extractLocations2DArray() else {
            XCTFail("Could not extract NSValues from polygon within Geometry collection")
            return
        }

        let geometryCollectionPointCoordinate = mbxPointGeometryValue.coordinateValue()
        let geometryCollectionPolygonCoordinates = NSValue.toCoordinates2D(array: mbxPolygonGeometryValues)

        XCTAssertEqual(geometryCollectionPointCoordinate, pointCoordinate)
        XCTAssertEqual(geometryCollectionPolygonCoordinates, [polygonCoordinates])
    }
}
