import Foundation
import UIKit
import Turf

#if canImport(MapboxMapsStyle)
import MapboxMapsStyle
#endif

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

internal protocol AnnotationSupportableMap: UIView {
    func visibleFeatures(in rect: CGRect,
                         styleLayers: Set<String>?,
                         filter: Expression?,
                         completion: @escaping (Result<[QueriedFeature], BaseMapView.QueryRenderedFeaturesError>) -> Void)
    func on(_ eventType: MapEvents.EventKind, handler: @escaping (MapboxCoreMaps.Event) -> Void)
}

extension BaseMapView: AnnotationSupportableMap {

    public var observable: Observable? {
        return __map
    }

    public enum QueryRenderedFeaturesError: Error {
        case invalidFilter(Error)
        case queryfailed(String?)
        case unknown
    }

    /// Asynchronous query for a list of rendered map features that intersect with the given rect.
    /// - Parameters:
    ///   - rect: The rect at which we should query for features
    ///   - styleLayers: An optional set of style layer identifiers to query for. If not specified, the query will search for features in all layers belonging to the map's style.
    ///   - filter: An optional expression to use in order to filter features from the result.
    ///   - completion: A closure that receives and operates on `Result<[Feature], QueryRenderedFeaturesError>`
    public func visibleFeatures(in rect: CGRect,
                                styleLayers: Set<String>? = nil,
                                filter: Expression? = nil,
                                completion: @escaping (Result<[QueriedFeature], QueryRenderedFeaturesError>) -> Void) {

        var styleLayerIdentifiers: [String]?
        var jsonExpression: Any?

        if let styleLayers = styleLayers {
            styleLayerIdentifiers = Array(styleLayers)
        }

        if let exp = filter {
            do {
                jsonExpression = try jsonObject(exp: exp)
            } catch {
                completion(.failure(.invalidFilter(error)))
                return
            }
        }

        let queryOptions = RenderedQueryOptions(layerIds: styleLayerIdentifiers, filter: jsonExpression)

        let screenBox = ScreenBox(min: ScreenCoordinate(x: Double(rect.minX), y: Double(rect.minY)),
                                  max: ScreenCoordinate(x: Double(rect.maxX), y: Double(rect.maxY)))

        __map.queryRenderedFeatures(for: screenBox, options: queryOptions, callback: { (expected: MBXExpected?) in

            guard let validExpected = expected else {
                completion(.failure(.unknown))
                return
            }

            guard validExpected.isValue() else {
                completion(.failure(.queryfailed(validExpected.error as? String)))
                return
            }

            if let mbxFeatures = validExpected.value as? [QueriedFeature] {
                completion(.success(mbxFeatures))
                return
            }
        })
    }

    /// Asynchronous query for a list of rendered map features that intersect with the given point.
    /// - Parameters:
    ///   - point: The point at which we should query for features
    ///   - styleLayers: An optional set of style layer identifiers to query for. If not specified, the query will search for features in all layers belonging to the map's style.
    ///   - filter: An optional expression to use in order to filter features from the result.
    ///   - completion: A closure that receives and operates on `Result<[Feature], QueryRenderedFeaturesError>`
    public func visibleFeatures(at point: CGPoint,
                                styleLayers: Set<String>? = nil,
                                filter: Expression? = nil,
                                completion: @escaping (Result<[QueriedFeature], QueryRenderedFeaturesError>) -> Void) {

        var styleLayerIdentifiers: [String]?
        var jsonExpression: Any?

        if let styleLayers = styleLayers {
            styleLayerIdentifiers = Array(styleLayers)
        }

        if let exp = filter {
            do {
                jsonExpression = try jsonObject(exp: exp)
            } catch {
                completion(.failure(.invalidFilter(error)))
                return
            }
        }

        let queryOptions = RenderedQueryOptions(layerIds: styleLayerIdentifiers, filter: jsonExpression)

        let screenPoint = ScreenCoordinate(x: Double(point.x),
                                           y: Double(point.y))

        __map.queryRenderedFeatures(forPixel: screenPoint, options: queryOptions, callback: { (expected: MBXExpected?) in

            guard let validExpected = expected else {
                completion(.failure(.unknown))
                return
            }

            guard validExpected.isValue() else {
                completion(.failure(.queryfailed(validExpected.error as? String)))
                return
            }

            if let mbxFeatures = validExpected.value as? [QueriedFeature] {
                completion(.success(mbxFeatures))
                return
            }
        })
    }

    private func jsonObject(exp: Expression) throws -> Any {
        let data = try JSONEncoder().encode(exp.self)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        return jsonObject
    }
}
