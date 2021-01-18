import UIKit
import MapboxCommon
import MapboxCoreMaps
#if canImport(Mapbox)
@testable import Mapbox
#else
@testable import MapboxMapsAnnotations
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
/**
 Mock class that flags true when `AnnotationSupportableMap` protocol methods
 have been called on it. For testing purposes, we're not concerned about the
 real `MBXExpected` values that are returned from these functions, but rather
 we're ensuring that the functions themselves are being called as they would
 on a real `MBXMap` object.
 */
class AnnotationsSupportableMapMock: AnnotationsSupportableMap {

    var addStyleSourceWasCalled: Bool = false
    var addStyleLayerWasCalled: Bool = false
    var addStyleImageWasCalled: Bool = false
    var setStyleLayerPropertyForLayerIdWasCalled: Bool = false
    var removeStyleImageWasCalled: Bool = false
    var removeStyleLayerWasCalled: Bool = false
    var removeStyleSourceWasCalled: Bool = false

    func addStyleSource(forSourceId sourceId: String, properties: Any) -> MBXExpected<AnyObject, AnyObject> {
        addStyleSourceWasCalled = true
        return MBXExpected(value: NSNumber(value: 0))
    }

    func addStyleLayer(forProperties properties: Any,
                       layerPosition: LayerPosition?) -> MBXExpected<AnyObject, AnyObject> {
        addStyleLayerWasCalled = true
        return MBXExpected(value: NSNumber(value: 0))
    }

    //swiftlint:disable function_parameter_count
    func addStyleImage(forImageId imageId: String,
                       scale: Float,
                       image: Image,
                       sdf: Bool,
                       stretchX: [ImageStretches],
                       stretchY: [ImageStretches],
                       content: ImageContent?) -> MBXExpected<AnyObject, AnyObject> {
        addStyleImageWasCalled = true
        return MBXExpected(value: NSNumber(value: 0))
    }

    func setStyleLayerPropertyForLayerId(_ layerId: String,
                                         property: String,
                                         value: Any) -> MBXExpected<AnyObject, AnyObject> {
        setStyleLayerPropertyForLayerIdWasCalled = true
        return MBXExpected(value: NSNumber(value: 0))
    }

    func removeStyleImage(forImageId: String) -> MBXExpected<AnyObject, AnyObject> {
        removeStyleImageWasCalled = true
        return MBXExpected(value: NSNumber(value: 0))
    }

    func removeStyleLayer(forLayerId: String) -> MBXExpected<AnyObject, AnyObject> {
        removeStyleLayerWasCalled = true
        return MBXExpected(value: NSNumber(value: 0))
    }

    func removeStyleSource(forSourceId: String) -> MBXExpected<AnyObject, AnyObject> {
        removeStyleSourceWasCalled = true
        return MBXExpected(value: NSNumber(value: 0))
    }
}
