import UIKit
@_implementationOnly import MapboxCommon_Private

protocol OffsetGeometryCalculator {
    associatedtype GeometryType: GeometryConvertible
    static func projection(of geometry: GeometryType, for translation: CGPoint, in mapboxMap: MapboxMapProtocol) -> GeometryType
}

extension Point: OffsetGeometryCalculator {
    typealias GeometryType = Point

    static func projection(of geometry: Point, for translation: CGPoint, in mapboxMap: MapboxMapProtocol) -> Point {
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
            return geometry
        }
        return Point(targetPoint.coordinates)
    }
}

extension LineString: OffsetGeometryCalculator {
    typealias GeometryType = LineString

    static func projection(of geometry: LineString, for translation: CGPoint, in mapboxMap: MapboxMapProtocol) -> LineString {
        let startPoints = geometry.coordinates

        if startPoints.isEmpty {
            return geometry
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
            return geometry
        }

        guard Projection.latitudeRange.contains(targetPointLatitude) else {
            return geometry
        }
        return LineString(.init(coordinates: targetPoints.map {$0.coordinates}))
    }
}

extension Polygon: OffsetGeometryCalculator {
    typealias GeometryType = Polygon

    // swiftlint:disable:next function_body_length
    static func projection(of geometry: Polygon, for translation: CGPoint, in mapboxMap: MapboxMapProtocol) -> Polygon {
        var outerRing = [CLLocationCoordinate2D]()
        var innerRing: [CLLocationCoordinate2D]?
        let startPoints = geometry.outerRing.coordinates
        if startPoints.isEmpty {
            return geometry
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
            return geometry
        }

        guard Projection.latitudeRange.contains(targetPointLatitude) else {
            return geometry
        }

        outerRing = targetPoints.map {$0.coordinates}

        if !geometry.innerRings.isEmpty {

            var innerRings = [Ring]()
            for ring in geometry.innerRings {
                let startPoints = ring.coordinates
                if startPoints.isEmpty {
                    return geometry
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
                    return geometry
                }

                guard Projection.latitudeRange.contains(targetPointLatitude) else {
                    return geometry
                }

                innerRing = targetPoints.map {$0.coordinates}
                guard let innerRing = innerRing else { return geometry }
                innerRings.append(.init(coordinates: innerRing))

            }
            return Polygon(outerRing: .init(coordinates: outerRing), innerRings: innerRings)
        }
        return Polygon(outerRing: .init(coordinates: outerRing))
    }
}
