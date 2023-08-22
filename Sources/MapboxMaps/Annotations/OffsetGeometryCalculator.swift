import UIKit
@_implementationOnly import MapboxCommon_Private

internal protocol OffsetGeometryCalculator {
    associatedtype GeometryType: GeometryConvertible
    func geometry(for translation: CGPoint, from geometry: GeometryType) -> GeometryType?
}

internal struct OffsetPointCalculator: OffsetGeometryCalculator {
    private let mapboxMap: MapboxMapProtocol

    internal init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    func geometry(for translation: CGPoint, from geometry: Point) -> Point? {
        let point = geometry.coordinates

        let pointScreenCoordinate = mapboxMap.point(for: point)

        let targetCoordinates = mapboxMap.coordinate(for: CGPoint(
            x: pointScreenCoordinate.x - translation.x,
            y: pointScreenCoordinate.y - translation.y
        ))

        let shiftMercatorCoordinate = Projection.calculateMercatorCoordinateShift(
            startPoint: Point(point),
            endPoint: Point(targetCoordinates),
            zoomLevel: mapboxMap.cameraState.zoom)

        let targetPoint = Projection.shiftPointWithMercatorCoordinate(
            point: Point(point),
            shiftMercatorCoordinate: shiftMercatorCoordinate,
            zoomLevel: mapboxMap.cameraState.zoom)

        guard Projection.latitudeRange.contains(targetPoint.coordinates.latitude) else {
            return nil
        }
        return Point(targetPoint.coordinates)
    }
}

internal struct OffsetLineStringCalculator: OffsetGeometryCalculator {
    private let mapboxMap: MapboxMapProtocol

    internal init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    func geometry(for translation: CGPoint, from geometry: LineString) -> LineString? {
        let startPoints = geometry.coordinates

        if startPoints.isEmpty {
            return nil
        }
        let latitudeSum = startPoints.map(\.latitude).reduce(0, +)
        let longitudeSum = startPoints.map(\.longitude).reduce(0, +)
        let latitudeAverage = latitudeSum / CGFloat(startPoints.count)
        let longitudeAverage = longitudeSum / CGFloat(startPoints.count)

        let averageCoordinates = CLLocationCoordinate2D(latitude: latitudeAverage, longitude: longitudeAverage)

        let centerPoint = Point(averageCoordinates)

        let centerScreenCoordinate = mapboxMap.point(for: centerPoint.coordinates)

        let targetCoordinates =  mapboxMap.coordinate(for: CGPoint(
            x: centerScreenCoordinate.x - translation.x,
            y: centerScreenCoordinate.y - translation.y
        ))

        let targetPoint = Point(targetCoordinates)

        let shiftMercatorCoordinate = Projection.calculateMercatorCoordinateShift(startPoint: centerPoint, endPoint: targetPoint, zoomLevel: mapboxMap.cameraState.zoom)

        let targetPoints = startPoints.map {
            Projection.shiftPointWithMercatorCoordinate(
                point: Point($0),
                shiftMercatorCoordinate: shiftMercatorCoordinate,
                zoomLevel: mapboxMap.cameraState.zoom)
        }

        guard let targetPointLatitude = targetPoints.first?.coordinates.latitude else {
            return nil
        }

        guard Projection.latitudeRange.contains(targetPointLatitude) else {
            return nil
        }
        return LineString(.init(coordinates: targetPoints.map {$0.coordinates}))
    }
}

internal struct OffsetPolygonCalculator: OffsetGeometryCalculator {
    private let mapboxMap: MapboxMapProtocol

    internal init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    // swiftlint:disable:next function_body_length
    func geometry(for translation: CGPoint, from geometry: Polygon) -> Polygon? {
        var outerRing = [CLLocationCoordinate2D]()
        var innerRing: [CLLocationCoordinate2D]?
        let startPoints = geometry.outerRing.coordinates
        if startPoints.isEmpty {
            return nil
        }

        let latitudeSum = startPoints.map { $0.latitude }.reduce(0, +)
        let longitudeSum = startPoints.map { $0.longitude }.reduce(0, +)
        let latitudeAverage = latitudeSum / CGFloat(startPoints.count)
        let longitudeAverage = longitudeSum / CGFloat(startPoints.count)

        let averageCoordinates = CLLocationCoordinate2D(latitude: latitudeAverage, longitude: longitudeAverage)

        let centerPoint = Point(averageCoordinates)

        let centerScreenCoordinate = mapboxMap.point(for: centerPoint.coordinates)

        let targetCoordinates =  mapboxMap.coordinate(for: CGPoint(
            x: centerScreenCoordinate.x - translation.x,
            y: centerScreenCoordinate.y - translation.y
        ))

        let targetPoint = Point(targetCoordinates)

        let shiftMercatorCoordinate = Projection.calculateMercatorCoordinateShift(
            startPoint: centerPoint,
            endPoint: targetPoint,
            zoomLevel: mapboxMap.cameraState.zoom)

        let targetPoints = startPoints.map {
            Projection.shiftPointWithMercatorCoordinate(
            point: Point($0),
            shiftMercatorCoordinate: shiftMercatorCoordinate,
            zoomLevel: mapboxMap.cameraState.zoom)
        }

        guard let targetPointLatitude = targetPoints.first?.coordinates.latitude else {
            return nil
        }

        guard Projection.latitudeRange.contains(targetPointLatitude) else {
            return nil
        }

        outerRing = targetPoints.map {$0.coordinates}

        if !geometry.innerRings.isEmpty {

            var innerRings = [Ring]()
            for ring in geometry.innerRings {
                let startPoints = ring.coordinates
                if startPoints.isEmpty {
                    return nil
                }

                let latitudeSum = startPoints.map { $0.latitude }.reduce(0, +)
                let longitudeSum = startPoints.map { $0.longitude }.reduce(0, +)
                let latitudeAverage = latitudeSum / CGFloat(startPoints.count)
                let longitudeAverage = longitudeSum / CGFloat(startPoints.count)

                let averageCoordinates = CLLocationCoordinate2D(latitude: latitudeAverage, longitude: longitudeAverage)

                let centerPoint = Point(averageCoordinates)

                let centerScreenCoordinate = mapboxMap.point(for: centerPoint.coordinates)

                let targetCoordinates =  mapboxMap.coordinate(for: CGPoint(
                    x: centerScreenCoordinate.x - translation.x,
                    y: centerScreenCoordinate.y - translation.y
                ))

                let targetPoint = Point(targetCoordinates)

                let shiftMercatorCoordinate = Projection.calculateMercatorCoordinateShift(
                    startPoint: centerPoint,
                    endPoint: targetPoint,
                    zoomLevel: mapboxMap.cameraState.zoom)

                let targetPoints = startPoints.map {Projection.shiftPointWithMercatorCoordinate(
                    point: Point($0),
                    shiftMercatorCoordinate: shiftMercatorCoordinate,
                    zoomLevel: mapboxMap.cameraState.zoom)}

                guard let targetPointLatitude = targetPoints.first?.coordinates.latitude else {
                    return nil
                }

                guard Projection.latitudeRange.contains(targetPointLatitude) else {
                    return nil
                }

                innerRing = targetPoints.map {$0.coordinates}
                guard let innerRing = innerRing else { return nil }
                innerRings.append(.init(coordinates: innerRing))

            }
            return Polygon(outerRing: .init(coordinates: outerRing), innerRings: innerRings)
        }
        return Polygon(outerRing: .init(coordinates: outerRing))
    }
}
