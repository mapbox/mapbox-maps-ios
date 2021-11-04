import Foundation
import MapboxMaps

/**
 To add a new example, create a new `Example` struct
 and place it within the array for the category it belongs to below. Make sure
 the `fileName` is the same name of the new `UIViewController`
 you added in Examples/All Examples. See the README.md for more details.
 */
public struct Examples {
    public static let all = [
        [
            "title": "Getting started",
            "examples": gettingStartedExamples
        ],
        [
            "title": "3D and Fill Extrusions",
            "examples": threeDExamples
        ],
        [
            "title": "Annotations",
            "examples": annotationExamples
        ],
        [
            "title": "Camera",
            "examples": cameraExamples
        ],
        [
            "title": "Location",
            "examples": locationExamples
        ],
        [
            "title": "Offline",
            "examples": offlineExamples
        ],
        [
            "title": "Snapshot",
            "examples": snapshotExamples
        ],
        [
            "title": "Style",
            "examples": styleExamples
        ],
        [
            "title": "User Interaction",
            "examples": userInteractionExamples
        ],
        [
            "title": "Experimental",
            "examples": experimentalExamples
        ]
    ]

    // Examples that show how to get started with Mapbox, such as creating a basic map view or setting a style once.
    public static let gettingStartedExamples = [
        Example(title: "Display a map view",
                description: """
                Create and display a map that uses the default Mapbox streets style. This example also shows how to update the starting camera for a map.
                """,
                type: BasicMapExample.self),
        Example(title: "Use a custom map style",
                description: "Set and use a custom map style URL.",
                type: CustomStyleURLExample.self),
        Example(title: "Display a map view using storyboard",
                description: "Create and display a map using a storyboard.",
                type: StoryboardMapViewExample.self),
    ]

    // Examples that show how to use 3D terrain or fill extrusions.
    public static let threeDExamples = [
        Example(title: "Show 3D terrain",
                description: "Show realistic elevation by enabling terrain.",
                type: TerrainExample.self),
        Example(title: "SceneKit rendering on map",
                description: "Use custom layer to render SceneKit model over terrain.",
                type: SceneKitExample.self),
        Example(title: "Display buildings in 3D",
                description: "Use extrusions to display buildings' height in 3D.",
                type: BuildingExtrusionsExample.self),
        Example(title: "Add a sky layer",
                description: "Add a customizable sky layer to simulate natural lighting with a Terrain layer.",
                type: SkyLayerExample.self)
    ]

    // Examples that focus on annotations.
    public static let annotationExamples = [
        Example(title: "Add a point annotation using an image",
                description: "Add a point annotation using a custom image on a map.",
                type: CustomPointAnnotationExample.self),
        Example(title: "Update the position of a point annotation",
                description: "Update the position of a point annotation tapping the map.",
                type: UpdatePointAnnotationPositionExample.self),
        Example(title: "Add a line annotation",
                description: "Add a line annotation on a map.",
                type: LineAnnotationExample.self),
        Example(title: "Add a polygon annotation",
                description: "Add a polygon annotation to the map.",
                type: PolygonAnnotationExample.self),
        Example(title: "Select an annotation",
                description: "Select an annotation with a tap gesture.",
                type: SelectAnnotationExample.self),
        Example(title: "Use a map & annotations with SwiftUI",
                description: "Use the UIViewRepresentable protocol to wrap a MapView in a SwiftUI view.",
                type: SwiftUIExample.self),
        Example(title: "Add multiple annotations to a map",
                description: "Add default and custom annotations to a map.",
                type: MultiplePointAnnotationsExample.self),
        Example(title: "Add view annotations to a map",
                description: "Use custom view in annotations on a map.",
                type: ViewAnnotationExample.self)
    ]

    // Examples that focus on setting, animating, or otherwise changing the map's camera.
    public static let cameraExamples = [
        Example(title: "Fly-to camera animation",
                description: """
                    Smoothly interpolate between locations with the fly-to animation.
                """,
                type: FlyToExample.self),
            Example(title: "Use custom camera animations",
                description: """
                    Animate the map camera to a new position using camera animators. Individual camera properties such as zoom, bearing, and center coordinate can be animated independently.
                """,
                type: CameraAnimatorsExample.self),
        Example(title: "Use camera animations",
                description: "Use ease(to:) to animate updates to the camera's position.",
                type: CameraAnimationExample.self),

    ]

    // Examples focused on displaying the user's location.
    public static let locationExamples = [
        Example(title: "Display the user's location",
                description: "Display the user's location on a map with the default user location puck.",
                type: TrackingModeExample.self),
        Example(title: "Customize the location puck",
                description: "Use a different asset to represent the puck.",
                type: Custom2DPuckExample.self),
        Example(title: "Use a 3D model to show the user's location",
                description: "A 3D model is used to represent the user's location.",
                type: Custom3DPuckExample.self),
    ]

    // Examples that highlight using the Offline APIs.
    public static let offlineExamples = [
        Example(title: "Use OfflineManager and TileStore to download a region",
                description: """
                    Shows how to use OfflineManager and TileStore to download regions
                    for offline use.

                    By default, users may download up to 250MB of data for offline
                    use without incurring additional charges. This limit is subject
                    to change.
                """,
                type: OfflineManagerExample.self),
        Example(title: "Use OfflineRegionManager to download a region",
                description: "Use the deprecated OfflineRegionManager to download regions for offline use.",
                type: OfflineRegionManagerExample.self),
    ]

    // Examples that show how to use the map's snapshotter.
    public static let snapshotExamples = [
        Example(title: "Create a static map snapshot",
                description: """
                    Create a static, non-interactive image of a map style with specified camera position. The resulting snapshot is provided as a `UIImage`.
                    The map on top is interactive. The bottom one is a static snapshot.
                """,
                type: SnapshotterExample.self),
        Example(title: "Draw on a static snapshot with Core Graphics",
                description: """
                    Use the overlayHandler parameter to draw on top of a snapshot
                    using Core Graphhics APIs.
                """,
                type: SnapshotterCoreGraphicsExample.self),
    ]

    // Examples that highlight how to set or modify the map's style and its contents.
    public static let styleExamples = [
        Example(title: "Display multiple icon images in a symbol layer",
                description: """
            Use different images to represent features within a symbol layer based on properties.
            """,
                type: DataDrivenSymbolsExample.self),
        Example(title: "Change the position of a layer",
                description: "Insert a specific layer above or below other layers.",
                type: LayerPositionExample.self),
        Example(title: "Cluster points within a layer",
                description: "Create a circle layer from a geoJSON source and cluster the points from that source. The clusters will update as the map's camera changes.",
                type: PointClusteringExample.self),
        Example(title: "Animate a line layer",
                description: "Animate updates to a line layer from a geoJSON source.",
                type: AnimateGeoJSONLineExample.self),
        Example(title: "Draw multiple geometries",
                description: "Render multiple geometries from GeoJSON data on the map.",
                type: MultipleGeometriesExample.self),
        Example(title: "Animate a style layer",
                description: "Animate the position of a style layer by updating its source data.",
                type: AnimateLayerExample.self),
        Example(title: "Add external vector tiles",
                description: "Add vector map tiles from an external source, using the {z}/{x}/{y} URL scheme.",
                type: ExternalVectorSourceExample.self),
        Example(title: "Use interpolate colors between zoom level",
                description: """
                    Use an interpolate expression to style the background layer color depending on zoom level.
                """,
                type: ColorExpressionExample.self),
        Example(title: "Add a custom rendered layer",
                description: "Add a custom rendered Metal layer.",
                type: CustomLayerExample.self),
        Example(title: "Add a line with a color gradient",
                description: "Add a line with a rainbow color gradient.",
                type: LineGradientExample.self),
        Example(title: "Change the map's style",
                description: "Switch between local and default Mapbox styles for the same map view.",
                type: SwitchStylesExample.self),
        Example(title: "Change the map's language",
                description: "Switch between supported languages for Symbol Layers",
                type: LocalizationExample.self),
        Example(title: "Add an animated image",
                description: "Add an image to a raster layer on the map and animate it.",
                type: AnimateImageLayerExample.self),
        Example(title: "Add a raster tile source",
                description: "Add third-party raster tiles to a map.",
                type: RasterTileSourceExample.self),
        Example(title: "Show and hide layers",
                description: "Enable and disable two different map layers at runtime.",
                type: ShowHideLayerExample.self),
        Example(title: "Add live data",
                description: "Update feature coordinates from a geoJSON source in real time.",
                type: LiveDataExample.self)
    ]

    // Examples that show use cases related to user interaction with the map.
    public static let userInteractionExamples = [
        Example(title: "Find features at a point",
                description: "Query the map for rendered features belonging to a specific layer.",
                type: FeaturesAtPointExample.self),
        Example(title: "Use Feature State",
                description: "Manipulate map styling with feature states and expressions.",
                type: FeatureStateExample.self),
        Example(title: "Restrict the map's coordinate bounds",
                description: "Prevent the map from panning outside the specified coordinate bounds.",
                type: RestrictCoordinateBoundsExample.self),
        Example(title: "Add an interactive clustered layer",
                description: "Display an alert controller after selecting a feature.",
                type: SymbolClusteringExample.self),
    ]

    // Examples that uses experimental APIs
    public static let experimentalExamples = [
        Example(title: "Globe View",
                description: "Display map on a globe.",
                type: GlobeViewExample.self),
    ]
}

struct ExamplesCategories {
}
