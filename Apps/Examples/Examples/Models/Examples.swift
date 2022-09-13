import Foundation
import MapboxMaps

// To add a new example, create a new `Example` struct
// and place it within the array for the category it belongs to below. Make sure
// the `fileName` is the same name of the new `UIViewController`
// you added in Examples/All Examples. See the README.md for more details.

// swiftlint:disable:next type_body_length
struct Examples {
    static let all = [
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
            "title": "Lab",
            "examples": labExamples
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
            "title": "Accessibility",
            "examples": accessibilityExamples
        ],
        [   "title": "Globe and Atmosphere",
            "examples": globeAndAtmosphere
        ]
    ]

    // Examples that show how to get started with Mapbox, such as creating a basic map view or setting a style once.
    static let gettingStartedExamples = [
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
        Example(title: "Debug Map",
                description: "This example shows how the map looks with different debug options",
                type: DebugMapExample.self),
    ]

    // Examples that show how to use 3D terrain or fill extrusions.
    static let threeDExamples = [
        Example(title: "Show 3D terrain",
                description: "Show realistic elevation by enabling terrain.",
                type: TerrainExample.self),
        Example(title: "SceneKit rendering on map",
                description: "Use custom layer to render SceneKit model over terrain.",
                type: SceneKitExample.self),
        Example(title: "Display 3D buildings",
                description: "Extrude the building layer in the Mapbox Light style using FillExtrusionLayer and set up the light position.",
                type: BuildingExtrusionsExample.self),
        Example(title: "Add a sky layer",
                description: "Add a customizable sky layer to simulate natural lighting with a Terrain layer.",
                type: SkyLayerExample.self)
    ]

    // Examples that focus on annotations.
    static let annotationExamples = [
        Example(title: "Add a polygon annotation",
                description: "Add a polygon annotation to the map.",
                type: PolygonAnnotationExample.self),
        Example(title: "Add a marker symbol",
                description: "Add a blue teardrop-shaped marker image to a style and display it on the map using a SymbolLayer.",
                type: AddOneMarkerSymbolExample.self),
        Example(title: "Add Circle Annotations",
                description: "Show circle annotations on a map",
                type: CircleAnnotationExample.self),
        Example(title: "Add Cluster Symbol Annotations",
                description: "Show fire hydrants in Washington DC area in a cluster.",
                type: SymbolClusteringExample.self),
        Example(title: "Add markers to a map",
                description: "Add markers that use different icons.",
                type: AddMarkersSymbolExample.self),
        Example(title: "Add Point Annotations",
                description: "Show point annotations on a map",
                type: CustomPointAnnotationExample.self),
        Example(title: "Add Polylines Annotations",
                description: "Show polyline annotations on a map.",
                type: LineAnnotationExample.self),
        Example(title: "Animate Marker Position",
                description: "Animate updates to a marker/annotation's position.",
                type: AnimatedMarkerExample.self),
        Example(title: "Change icon size",
                description: "Change icon size with Symbol layer.",
                type: IconSizeChangeExample.self),
        Example(title: "Draw multiple geometries",
                description: "Draw multiple shapes on a map.",
                type: MultipleGeometriesExample.self),
        Example(title: "Use a map & annotations with SwiftUI",
                description: "Use the UIViewRepresentable protocol to wrap a MapView in a SwiftUI view.",
                type: SwiftUIExample.self),
        Example(title: "View annotation with point annotation",
                description: "Add view annotation to a point annotation",
                type: ViewAnnotationWithPointAnnotationExample.self),
        Example(title: "View annotations: basic example",
                description: "Add view annotation on a map with a click.",
                type: ViewAnnotationBasicExample.self),
        Example(title: "View annotations: advanced example",
                description: "Add view annotations anchored to a symbol layer feature.",
                type: ViewAnnotationMarkerExample.self)
    ]

    // Examples that focus on setting, animating, or otherwise changing the map's camera and viewport.
    static let cameraExamples = [
            Example(title: "Use custom camera animations",
                description: """
                    Animate the map camera to a new position using camera animators. Individual camera properties such as zoom, bearing, and center coordinate can be animated independently.
                """,
                type: CameraAnimatorsExample.self),
        Example(title: "Use camera animations",
                description: "Use ease(to:) to animate updates to the camera's position.",
                type: CameraAnimationExample.self),
        Example(title: "Viewport",
                description: "Viewport camera showcase",
                type: ViewportExample.self),
        Example(title: "Advanced Viewport Gestures",
                description: "Viewport configured to allow gestures",
                type: AdvancedViewportGesturesExample.self),

    ]

    // Miscellaneous examples
    public static let labExamples = [
        Example(title: "Resizable image",
                description: "Add a resizable image with cap insets to a style.",
                type: ResizableImageExample.self)
    ]

    // Examples that focus on displaying the user's location.
    public static let locationExamples = [
        Example(title: "Display the user's location",
                description: "Display the user's location on a map with the default user location puck.",
                type: TrackingModeExample.self),
        Example(title: "Basic pulsing circle",
                description: "Display sonar-like animation radiating from the location puck.",
                type: BasicLocationPulsingExample.self),
        Example(title: "Customize the location puck",
                description: "Customized the location puck on the map",
                type: Custom2DPuckExample.self),
        Example(title: "Use a 3D model to show the user's location",
                description: "A 3D model is used to represent the user's location.",
                type: Custom3DPuckExample.self),
        Example(title: "Add a custom location provider",
                description: "Display the location puck at a custom location.",
                type: CustomLocationProviderExample.self),
        Example(title: "Simulate navigation",
                description: "Simulate a driving trip from LA to San Francisco along a pre-defined route",
                type: NavigationSimulatorExample.self),
    ]

    // Examples that highlight using the Offline APIs.
    static let offlineExamples = [
        Example(title: "Use OfflineManager and TileStore to download a region",
                description: """
                    Shows how to use OfflineManager and TileStore to download regions
                    for offline use.

                    By default, users may download up to 750 tile packs for offline
                    use across all regions. If the limit is hit, any loadRegion call
                    will fail until excess regions are deleted. This limit is subject
                    to change. Please contact Mapbox if you require a higher limit.
                    Additional charges may apply.
                """,
                type: OfflineManagerExample.self),
        Example(title: "Use OfflineRegionManager to download a region",
                description: "Use the deprecated OfflineRegionManager to download regions for offline use.",
                testTimeout: 120,
                type: OfflineRegionManagerExample.self),
    ]

    // Examples that show how to use the map's snapshotter.
    static let snapshotExamples = [
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
    static let styleExamples = [
        Example(title: "Display multiple icon images in a symbol layer",
                description: """
            Add point data and several images to a style and use the switchCase and get expressions to choose which image to display at each point in a SymbolLayer based on a data property.
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
                description: "Load a polyline to a style using GeoJSONSource, display it on a map using LineLayer, and style it with a rainbow color gradient.",
                type: LineGradientExample.self),
        Example(title: "Change the map's style",
                description: "Switch between local and default Mapbox styles for the same map view.",
                type: SwitchStylesExample.self),
        Example(title: "Change the map's language",
                description: "Switch between supported languages for Symbol Layers",
                type: LocalizationExample.self),
        Example(title: "Add animated weather data",
                description: "Load a raster image to a style using ImageSource and display it on a map as animated weather data using RasterLayer.",
                type: AnimateImageLayerExample.self),
        Example(title: "Add a raster tile source",
                description: "Add third-party raster tiles to a map.",
                type: RasterTileSourceExample.self),
        Example(title: "Show and hide layers",
                description: "Allow the user to toggle the visibility of a CircleLayer and LineLayer on a map.",
                type: ShowHideLayerExample.self),
        Example(title: "Add live data",
                description: "Update feature coordinates from a geoJSON source in real time.",
                type: LiveDataExample.self),
        Example(title: "Join data to vector geometry",
                description: "Join local JSON data with vector tile geometries.",
                type: DataJoinExample.self),
        Example(title: "Use a distance expression", description: "Use a distance style expression to show features within a specific radius.", type: DistanceExpressionExample.self)
    ]

    // Examples that show use cases related to user interaction with the map.
    static let userInteractionExamples = [
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

    // Examples that show map accessibility features
    static let accessibilityExamples = [
        Example(title: "Access map features using VoiceOver",
                description: "Use VoiceOver to highlight annotations and hear their associated features.",
                type: VoiceOverAccessibilityExample.self),
    ]

    // Examples that display maps using the globe projection
    static let globeAndAtmosphere = [
        Example(title: "Display a globe",
                description: "Create a map using the globe projection.",
                type: GlobeExample.self),
        Example(title: "Fly-to camera animation",
                description: "Smoothly interpolate between locations with the fly-to animation.",
                type: GlobeFlyToExample.self),
        Example(title: "Create a rotating globe",
                description: "Display your map as an interactive, rotating globe.",
                type: SpinningGlobeExample.self),
        Example(title: "Visualize data as a heatmap",
                description: "Display your heatmap using the globe projection.",
                type: HeatmapLayerGlobeExample.self)
    ]
}
