@_implementationOnly import MapboxCommon_Private
import Foundation

internal final class Puck2D: NSObject, Puck {

    internal var isActive = false {
        didSet {
            guard isActive != oldValue else {
                return
            }
            if isActive {
                locationProducer.add(self)
                updateLayer(location: latestLocation)
            } else {
                locationProducer.remove(self)
                try? style.removeLayer(withId: Self.layerID)
                try? style.removeImage(withId: Self.topImageId)
                try? style.removeImage(withId: Self.bearingImageId)
                try? style.removeImage(withId: Self.shadowImageId)
                previouslySetLayerPropertyKeys.removeAll()
            }
        }
    }

    internal var puckBearingSource: PuckBearingSource = .heading {
        didSet {
            updateLayer(location: latestLocation)
        }
    }

    private let configuration: Puck2DConfiguration
    private let style: StyleProtocol
    private let locationProducer: LocationProducerProtocol

    /// The keys of the style properties that were set during the previous sync.
    /// Used to identify which styles need to be restored to their default values in
    /// the subsequent sync.
    private var previouslySetLayerPropertyKeys: Set<String> = []

    private static let layerID = "puck"
    private static let topImageId = "locationIndicatorLayerTopImage"
    private static let bearingImageId = "locationIndicatorLayerBearingImage"
    private static let shadowImageId = "locationIndicatorLayerShadowImage"

    internal init(configuration: Puck2DConfiguration,
                  style: StyleProtocol,
                  locationProducer: LocationProducerProtocol) {
        self.configuration = configuration
        self.style = style
        self.locationProducer = locationProducer
        super.init()
        self.internalLocationUpdaterEngine(herz: 30)
    }

    private func addImages() {
        try! style.addImage(
            configuration.resolvedTopImage,
            id: Self.topImageId,
            sdf: false,
            stretchX: [],
            stretchY: [],
            content: nil)
        try! style.addImage(
            configuration.resolvedBearingImage,
            id: Self.bearingImageId,
            sdf: false,
            stretchX: [],
            stretchY: [],
            content: nil)
        if let shadowImage = configuration.shadowImage {
            try! style.addImage(
                shadowImage,
                id: Self.shadowImageId,
                sdf: false,
                stretchX: [],
                stretchY: [],
                content: nil)
        }
    }

    
    private func updateLayer(location: Location?) {
        guard isActive, let location = location else {
            return
        }
        var layer = LocationIndicatorLayer(id: Self.layerID)
        switch location.accuracyAuthorization {
        case .fullAccuracy:
            layer.topImage = .constant(.name(Self.topImageId))
            layer.bearingImage = .constant(.name(Self.bearingImageId))
            if configuration.shadowImage != nil {
                layer.shadowImage = .constant(.name(Self.shadowImageId))
            }
            layer.location = .constant([
                location.coordinate.latitude,
                location.coordinate.longitude,
                location.location.altitude
            ])
            
            layer.locationTransition = StyleTransition(duration: 1.0, delay: 0)
            layer.topImageSize = configuration.resolvedScale
            layer.bearingImageSize = configuration.resolvedScale
            layer.shadowImageSize = configuration.resolvedScale
            layer.emphasisCircleRadiusTransition = StyleTransition(duration: 0, delay: 0)
            layer.bearingTransition = StyleTransition(duration: 0, delay: 0)
            if configuration.showsAccuracyRing {
                layer.accuracyRadius = .constant(location.horizontalAccuracy)
                layer.accuracyRadiusColor = .constant(StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
                layer.accuracyRadiusBorderColor = .constant(StyleColor(.lightGray))
            }
            switch puckBearingSource {
            case .heading:
                layer.bearing = .constant(location.headingDirection ?? 0)
            case .course:
                layer.bearing = .constant(location.course)
            }
        case .reducedAccuracy:
            fallthrough
        @unknown default:
            layer.accuracyRadius = .expression(Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                0
                400000
                4
                200000
                8
                5000
            })
            layer.accuracyRadiusColor = .constant(StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
            layer.accuracyRadiusBorderColor = .constant(StyleColor(.lightGray))
        }

        // LocationIndicatorLayer is a struct, and by default, most of its properties are nil. When it gets
        // converted to JSON, only the non-nil key-value pairs are included in the dictionary. When an existing
        // layer is updated with setLayerProperties(for:properties:) as is done below, only the specified keys
        // are modified, so if other properties were customized previously, they will keep their existing values.
        // In this case, we actually want to reset any "unused" properties to their default values, so we keep
        // track of which ones were used in the previous update and on subsequent updates identify which keys
        // need to be reset to their default values. We look up the default values for those keys and create a
        // combined update dictionary that contains the new property values that we're setting and the default
        // values for the properties we were using before but no longer want to customize.

        // Create the properties dictionary for the updated layer
        let newLayerProperties = try! layer.jsonObject()
        // Construct the properties dictionary to reset any properties that are no longer used
        let unusedPropertyKeys = previouslySetLayerPropertyKeys.subtracting(newLayerProperties.keys)
        let unusedProperties = Dictionary(uniqueKeysWithValues: unusedPropertyKeys.map { (key) -> (String, Any) in
            (key, Style.layerPropertyDefaultValue(for: .locationIndicator, property: key).value)
        })
        // Merge the new and unused properties
        let allLayerProperties = newLayerProperties.merging(unusedProperties, uniquingKeysWith: { $1 })
        // Store the new set of property keys
        previouslySetLayerPropertyKeys = Set(newLayerProperties.keys)

        // Update or add the layer
        if style.layerExists(withId: Self.layerID) {
            try! style.setLayerProperties(for: Self.layerID, properties: allLayerProperties)
        } else {
            // add the images at the same time as adding the layer. doing it earlier results
            // in the images getting removed if the style reloads in between when the images
            // were added and when the persistent layer is added. The presence of a persistent
            // layer causes MapboxCoreMaps to skip clearing images when the style reloads.
            // https://github.com/mapbox/mapbox-maps-ios/issues/860
            addImages()
            try! style.addPersistentLayer(with: allLayerProperties, layerPosition: nil)
        }
    }
    var latestLocation: Location?
    var segmentationTimer: Timer?
    
    var lastLocationUpdateInterval: Double = 1.0 //TODO: time between location updates
    var lastLocationUpdate: Date = Date()
    
    let frameUpdateFrequency = 20 //TODO: config parameter in option; if 0, default to default implemenation?
}

extension Puck2D: LocationConsumer {
    
    //TODO: move this out into a extension for Puck2D & 3D
    internal func locationUpdate(newLocation: Location) {
//        updateLayer(location: newLocation)
        print("------------")
        lastLocationUpdateInterval = Date().timeIntervalSince(lastLocationUpdate)
        lastLocationUpdate = Date()
        internalLocationUpdates(newLocation: newLocation, herz: (Double(frameUpdateFrequency) * lastLocationUpdateInterval))
    }
    
    internal func internalLocationUpdates(newLocation: Location?, herz: Double) {
        if latestLocation == nil {
            latestLocation = newLocation
            return
        }
        guard let newLocation = newLocation else {
            return
        }

        let subLat = latestLocation!.coordinate.latitude - newLocation.coordinate.latitude
        let subLong = latestLocation!.coordinate.longitude - newLocation.coordinate.longitude
        
        let distLat = subLat / herz
        let distLong = subLong / herz
        
        
        //TODO: how to apply segementation to heading?
//        let distHeadAcc = (latestLocation!.heading!.headingAccuracy - newLocation.heading!.headingAccuracy) / Double(herz)
//        let distHeadTrue = (latestLocation!.heading!.trueHeading - newLocation.heading!.trueHeading) / Double(herz)
//        let distHeadMag = (latestLocation!.heading!.magneticHeading - newLocation.heading!.magneticHeading) / Double(herz)
        
        segmentationTimer?.invalidate()
        //TODO: possibly just one temp timer triggered by update instead of the engine setup?
        var runCount = 0
        let interval = lastLocationUpdateInterval/herz
        segmentationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self] timer in
            
            let location = CLLocation(latitude: self!.latestLocation!.coordinate.latitude - distLat, longitude: self!.latestLocation!.coordinate.longitude - distLong)
            self!.latestLocation = Location(location: location, heading: newLocation.heading , accuracyAuthorization: newLocation.accuracyAuthorization)
            
            runCount += 1
            let df = DateFormatter()
            df.dateFormat = "y-MM-dd H:mm:ss.SSSS"
            print(df.string(from: Date()) + " - \(self!.latestLocation) - \(runCount)")
            
            if runCount >= Int(herz) {
                timer.invalidate()
            }
        })
    }
    
    internal func internalLocationUpdaterEngine(herz: Int) {
//        return
        var latestUpdatedLocation: Location?
        _ = Timer.scheduledTimer(withTimeInterval: lastLocationUpdateInterval/Double(herz), repeats: true) { [weak self] timer in

            guard let self = self else { return }
            
            if self.latestLocation == nil || latestUpdatedLocation == self.latestLocation { return }
            
            self.updateLayer(location: self.latestLocation)
            latestUpdatedLocation = self.latestLocation
        }
    }
}

private extension Puck2DConfiguration {
    var resolvedTopImage: UIImage {
        topImage ?? UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)!
    }

    var resolvedBearingImage: UIImage {
        bearingImage ?? UIImage(named: "location-dot-outer", in: .mapboxMaps, compatibleWith: nil)!
    }

    var resolvedScale: Value<Double> {
        scale ?? .constant(1.0)
    }
}
