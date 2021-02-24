import Foundation
import MapboxMaps

public struct Example {
    public static let finishNotificationName = "com.mapbox.Examples.finish"

    public var title: String
    public var description: String
    public var testTimeout: TimeInterval = 20.0
    public var type: ExampleProtocol.Type
}

public protocol ExampleProtocol {
    func resourceOptions() -> ResourceOptions
    func finish()
}

extension ExampleProtocol {
    public func resourceOptions() -> ResourceOptions {
        guard let accessToken = AccountManager.shared.accessToken else {
            fatalError("Access token not set")
        }

        guard !accessToken.isEmpty else {
            fatalError("Empty access token")
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken)
        return resourceOptions
    }

    public func finish() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let center = CFNotificationCenterGetDarwinNotifyCenter()
            CFNotificationCenterPostNotification(center, CFNotificationName(Example.finishNotificationName as CFString), nil, nil, true)
        }
    }
}

/**
 To add a new example, create a new `Example` struct
 and place it within the array below. Make sure
 the `fileName` is the same name of the new `UIViewController`
 you added in Examples/All Examples. See the README.md for more details.
 */
public struct Examples {
    public static let all = [
        Example(title: "Display a MapView",
                description: "Render a Mapbox map in your view controller, using MapView.",
                type: MapViewExample.self),
        Example(title: "Display a MapViewController",
                description: "Render a Mapbox map in your view controller, using MapViewController.",
                type: BasicMapExample.self),
        Example(title: "Animate the map camera",
                description: "Animate the map camera to a new position.",
                type: CameraAnimationExample.self),
        Example(title: "Animate the map camera using UIView.animate",
                description: "Animates the map camera using camera view properties.",
                type: CameraUIViewAnimationExample.self),
        Example(title: "Use a custom map style",
                description: "Set and use a custom map style URL.",
                type: CustomStyleURLExample.self),
        Example(title: "Add a point annotation",
                description: "Add the default point annotation on a map.",
                type: PointAnnotationExample.self),
        Example(title: "Add a point annotation using an image",
                description: "Add a point annotation using a custom image on a map.",
                type: CustomPointAnnotationExample.self),
        Example(title: "Add a line annotation",
                description: "Add a line annotation on a map.",
                type: LineAnnotationExample.self),
        Example(title: "Add a polygon annotation",
                description: "Add a polygon annotation to the map.",
                type: PolygonAnnotationExample.self),
        Example(title: "Select an annotation",
                description: "Select an annotation with a tap gesture.",
                type: SelectAnnotationExample.self),
        Example(title: "Add a GeoJSON data source",
                description: "Render multiple geometries from GeoJSON data on the map.",
                type: GeoJSONSourceExample.self),
        Example(title: "Style icons with a data-driven property",
                description: "Display multiple images in a symbol layer.",
                type: DataDrivenSymbolsExample.self),
        Example(title: "Find features at a point",
                description: "Query the map for rendered features belonging to a specific layer.",
                type: FeaturesAtPointExample.self),
        Example(title: "Animate a style layer",
                description: "Animate the position of a style layer by updating its source data.",
                type: AnimateLayerExample.self),
        Example(title: "Change the position of a layer",
                description: "Adjust the position of a layer to be above or below other layers.",
                type: LayerPositionExample.self),
        Example(title: "Add a layer below labels",
                description: "Add a new layer and position it below settlement labels.",
                type: LayerBelowExample.self),
        Example(title: "Create a static map snapshot",
                description: """
                    Create a static, non-interactive snapshot from an existing map.
                    The map on top is interactive. The bottom one is a static snapshot.
                """,
                type: SnapshotterExample.self),
        Example(title: "Add external vector tiles",
                description: "Add vector map tiles from an external source, using the {z}/{x}/{y} URL scheme.",
                type: ExternalVectorSourceExample.self),
        Example(title: "Draw on a static snapshot with Core Graphics",
                description: """
                    Use the overlayHandler parameter to draw on top of a snapshot
                    using Core Graphhics APIs.
                """,
                type: SnapshotterCoreGraphicsExample.self),
        Example(title: "Use interpolate colors between zoom level",
                description: """
                    Use an interpolate expression to style the background layer color depending on zoom level.
                """,
                type: ColorExpressionExample.self),
        Example(title: "Use FlyTo animation",
                description: """
                    Use a fly to animation to fly from San Francisco to Boston.
                """,
                type: FlyToExample.self),
        Example(title: "Fit map camera to a given geometry",
                description: "Fit the map's camera on a given geometry.",
                type: FitCameraToGeometryExample.self),
        Example(title: "Update the position of a point annotation",
                description: "Update the position of a point annotation tapping the map.",
                type: UpdatePointAnnotationPositionExample.self),
        Example(title: "Add a 3D Model to the map",
                description: "Add a 3D object in the glTF format to a map.",
                type: ModelExample.self),
        Example(title: "Restrict the map's coordinate bounds",
                description: "Prevent the map from panning outside the specified coordinate bounds.",
                type: RestrictCoordinateBoundsExample.self),
        Example(title: "Use a 3D model to show the user's location",
                description: "A 3D model is used to represent the user's location.",
                type: PuckModelLayerExample.self),
        Example(title: "Add a custom rendered layer",
                description: "Add a custom rendered Metal layer.",
                type: CustomLayerExample.self),
        Example(title: "Show 3D terrain",
                description: "Show realistic elevation by enabling terrain.",
                type: TerrainExample.self),
        Example(title: "Customize the location puck",
                description: "Use a different asset to represent the puck.",
                type: CustomLocationIndicatorLayerExample.self),
        Example(title: "Display buildings in 3D",
                description: "Use extrusions to display buildings' height in 3D.",
                type: BuildingExtrusionsExample.self),
        Example(title: "Use OfflineRegionManager to download a region",
                description: "Use the deprecated OfflineRegionManager to download regions for offline use.",
                type: OfflineRegionManagerExample.self),
        Example(title: "Add a line with a color gradient",
                description: "Add a line with a rainbow color gradient.",
                type: LineGradientExample.self),
        Example(title: "Animate a GeoJSON line",
                description: "Update a map's style to animate a line over time.",
                type: AnimateGeoJSONLineExample.self),
        Example(title: "Use a map & annotations with SwiftUI",
                description: "Use the UIViewRepresentable protocol to wrap a MapView in a SwiftUI view.",
                type: SwiftUIExample.self),
        Example(title: "Track Location Updates",
                description: "Track a device's GPS updates with the camera and location provider",
                type: TrackingModeExample.self)
    ]
}
