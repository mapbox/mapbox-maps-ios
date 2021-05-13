import Foundation
import CoreLocation

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

#if canImport(MapboxMapsStyle)
import MapboxMapsStyle
#endif

public protocol LocationSupportableMapView: UIView {

    /// Returns the screen coordinate for a given location coordinate (lat-long)
    func screenCoordinate(for locationCoordinate: CLLocationCoordinate2D) -> ScreenCoordinate

    /// Allows the `LocationSupportableMapView` to subscribe to a delegate
    func subscribeRenderFrameHandler(_ handler: @escaping (MapboxCoreMaps.Event) -> Void)

    /// Allows the `LocationSupportableMapView` to subscrive to a delegate function and handle style change events
    func subscribeStyleChangeHandler(_ handler: @escaping (MapboxCoreMaps.Event) -> Void)

    /// Gets meters per point at latitude for calculating accuracy ring
    func metersPerPointAtLatitude(latitude: CLLocationDegrees) -> CLLocationDistance
}

internal protocol LocationStyleDelegate: AnyObject {
    func addLayer(_ layer: Layer, layerPosition: LayerPosition?) throws
    func removeLayer(withId id: String) throws
    func layerExists(withId id: String) -> Bool
    func setLayerProperties(for layerId: String, properties: [String: Any]) throws
    func addSource(_ source: Source, id: String) throws
    func removeSource(withId id: String) throws 
    func setSourceProperty(for sourceId: String, property: String, value: Any) throws
    func addImage(_ image: UIImage, id: String, sdf: Bool, stretchX: [ImageStretches], stretchY: [ImageStretches], content: ImageContent?) throws
}

extension LocationStyleDelegate {
    internal func addLayer(_ layer: Layer, layerPosition: LayerPosition? = nil) throws {
        try addLayer(layer, layerPosition: layerPosition)
    }

    internal func addImage(_ image: UIImage, id: String, sdf: Bool = false, stretchX: [ImageStretches] = [], stretchY: [ImageStretches] = [], content: ImageContent? = nil) throws {
        try addImage(image, id: id, sdf: sdf, stretchX: stretchX, stretchY: stretchY, content: content)
    }
}

