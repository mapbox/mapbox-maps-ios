import Turf
@_implementationOnly import MapboxCoreMaps_Private

public protocol MapFeatureQueryable: AnyObject {
    // String errors
    func queryRenderedFeatures(for shape: [CGPoint],
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedFeature], Error>) -> Void)

    func queryRenderedFeatures(in rect: CGRect,
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedFeature], Error>) -> Void)

    func queryRenderedFeatures(at point: CGPoint,
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedFeature], Error>) -> Void)

    func querySourceFeatures(for sourceId: String,
                             options: SourceQueryOptions,
                             completion: @escaping (Result<[QueriedFeature], Error>) -> Void)

    //swiftlint:disable function_parameter_count
    func queryFeatureExtension(for sourceId: String,
                               feature: Feature,
                               extension: String,
                               extensionField: String,
                               args: [String: Any]?,
                               completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void)
    //swiftlint:enable function_parameter_count
}

/// Type of errors thrown by the `MapFeatureQueryProtocol` APIs.
public struct MapError: LocalizedError, CoreErrorRepresentable {
    /// :nodoc:
    internal typealias CoreErrorType = NSString

    /// Error message
    public private(set) var errorDescription: String

    internal init(coreError: NSString) {
        errorDescription = coreError as String
    }
}

// TODO: Turf feature property of QueriedFeature

extension MapboxMap: MapFeatureQueryable {
    public func queryRenderedFeatures(for shape: [CGPoint], options: RenderedQueryOptions? = nil, completion: @escaping (Result<[QueriedFeature], Error>) -> Void) {
        __map.queryRenderedFeatures(forShape: shape.map { $0.screenCoordinate },
                                    options: options ?? RenderedQueryOptions(layerIds: nil, filter: nil),
                                    callback: coreAPIClosureAdapter(for: completion,
                                                                    type: NSArray.self,
                                                                    concreteErrorType: MapError.self))
    }

    public func queryRenderedFeatures(in rect: CGRect, options: RenderedQueryOptions? = nil, completion: @escaping (Result<[QueriedFeature], Error>) -> Void) {
        __map.queryRenderedFeatures(for: ScreenBox(rect),
                                    options: options ?? RenderedQueryOptions(layerIds: nil, filter: nil),
                                    callback: coreAPIClosureAdapter(for: completion,
                                                                    type: NSArray.self,
                                                                    concreteErrorType: MapError.self))
    }

    public func queryRenderedFeatures(at point: CGPoint, options: RenderedQueryOptions? = nil, completion: @escaping (Result<[QueriedFeature], Error>) -> Void) {
        __map.queryRenderedFeatures(forPixel: point.screenCoordinate,
                                    options: options ?? RenderedQueryOptions(layerIds: nil, filter: nil),
                                    callback: coreAPIClosureAdapter(for: completion,
                                                                    type: NSArray.self,
                                                                    concreteErrorType: MapError.self))
    }

    public func querySourceFeatures(for sourceId: String,
                                    options: SourceQueryOptions,
                                    completion: @escaping (Result<[QueriedFeature], Error>) -> Void) {
        __map.querySourceFeatures(forSourceId: sourceId,
                                  options: options,
                                  callback: coreAPIClosureAdapter(for: completion,
                                                                  type: NSArray.self,
                                                                  concreteErrorType: MapError.self))
    }

    public func queryFeatureExtension(for sourceId: String,
                                      feature: Feature,
                                      extension: String,
                                      extensionField: String,
                                      args: [String: Any]? = nil,
                                      completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) {

        guard let feature = MBXFeature(feature) else {
            completion(.failure(TypeConversionError.unexpectedType))
            return
        }

        __map.queryFeatureExtensions(forSourceIdentifier: sourceId,
                                     feature: feature,
                                     extension: `extension`,
                                     extensionField: extensionField,
                                     args: args,
                                     callback: coreAPIClosureAdapter(for: completion,
                                                                     type: FeatureExtensionValue.self,
                                                                     concreteErrorType: MapError.self))
    }
}
