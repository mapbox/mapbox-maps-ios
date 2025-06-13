import Foundation
import MapboxMaps

// To add a new example, create a new `Example` struct
// and place it within the array for the category it belongs to below. Make sure
// the `fileName` is the same name of the new `UIViewController`
// you added in Examples/All Examples. See the README.md for more details.

// swiftlint:disable:next type_body_length

struct Examples {
    // Examples that show how to get started with Mapbox, such as creating a basic map view or setting a style once.
    static let gettingStartedExamples: [Example] = .init {
        Example(title: "Display a map view",
                description: "Create and display a map that uses the default Mapbox Standard style.",
                type: BasicMapExample.self)
        Example(title: "Standard Style",
                description: "Use the Standard style and modify settings at runtime.",
                type: StandardStyleExample.self)
        Example(title: "Debug Map",
                description: "This example shows how the map looks with different debug options.",
                type: DebugMapExample.self)
    }

    // Examples that show how to use 3D terrain or fill extrusions.
    static let threeDExamples: [Example] = .init {
        Example(title: "SceneKit rendering on map",
                description: "Use a custom layer to render a SceneKit model over terrain.",
                type: SceneKitExample.self)
        Example(title: "Display 3D buildings",
                description: "Extrude the building layer in the Mapbox Light style using FillExtrusionLayer and set up the light position.",
                type: BuildingExtrusionsExample.self)
        Example(title: "Add a sky layer",
                description: "Add a customizable sky layer to simulate natural lighting with a Terrain layer.",
                type: SkyLayerExample.self)
        Example(title: "Display a 3D model in a model layer",
                description: "Showcase the usage of a 3D model layer.",
                type: ModelLayerExample.self)
        Example(title: "3D Lights",
                description: "Configure lights in 3D environment.",
                type: Lights3DExample.self)
    }

    // Examples that focus on annotations.
    static let annotationExamples: [Example] = .init {
        Example(title: "Add a polygon annotation",
                description: "Add a polygon annotation to the map.",
                type: PolygonAnnotationExample.self)
        Example(title: "Add a marker symbol",
                description: "Add a red teardrop-shaped marker image to a style and display it on the map using a SymbolLayer.",
                type: AddOneMarkerSymbolExample.self)
        Example(title: "Add Circle Annotations",
                description: "Show circle annotations on a map.",
                type: CircleAnnotationExample.self)
        Example(title: "Add Cluster Symbol Annotations",
                description: "Show fire hydrants in Washington DC area in a cluster using a symbol layer.",
                type: SymbolClusteringExample.self)
        Example(title: "Add Cluster Point Annotations",
                description: "Show fire hydrants in Washington DC area in a cluster using point annotations.",
                type: PointAnnotationClusteringExample.self)
        Example(title: "Add markers to a map",
                description: "Add markers that use different icons.",
                type: AddMarkersSymbolExample.self)
        Example(title: "Add Point Annotation",
                description: "Show custom point annotation on a map.",
                type: CustomPointAnnotationExample.self)
        Example(title: "Add Polyline annotations",
                description: "Show polyline annotations on a map.",
                type: LineAnnotationExample.self)
        Example(title: "Animate Marker Position",
                description: "Animate updates to a marker/annotation's position.",
                type: AnimatedMarkerExample.self)
        Example(title: "Change icon size",
                description: "Change icon size with Symbol layer.",
                type: IconSizeChangeExample.self)
        Example(title: "Draw multiple geometries",
                description: "Draw multiple shapes on a map.",
                type: MultipleGeometriesExample.self)
        Example(title: "View annotation with point annotation",
                description: "Add view annotation to a point annotation.",
                type: ViewAnnotationWithPointAnnotationExample.self)
        Example(title: "View annotations: basic example",
                description: "Add view annotation on a map with a click.",
                type: ViewAnnotationBasicExample.self)
        Example(title: "View annotations: advanced example",
                description: "Add view annotations anchored to a symbol layer feature.",
                type: ViewAnnotationMarkerExample.self)
        Example(title: "View annotations: Frame list of annotations",
                description: "Animates to camera framing the list of selected view annotations.",
                type: FrameViewAnnotationsExample.self)
        Example(title: "View annotations: animation",
                description: "Animate a view annotation along a route.",
                testTimeout: 60,
                type: ViewAnnotationAnimationExample.self)
        Example(title: "Dynamic view annotations",
                description: "Use Dynamic view annotations, Style, and the Viewport API to create a navigation experience.",
                type: DynamicViewAnnotationExample.self)
    }

    // Examples that focus on setting, animating, or otherwise changing the map's camera and viewport.
    static let cameraExamples: [Example] = .init {
        Example(title: "Use custom camera animations",
                description: """
                    Animate the map camera to a new position using camera animators. Individual camera properties such as zoom, bearing, and center coordinate can be animated independently.
                """,
                type: CameraAnimatorsExample.self)
        Example(title: "Use camera animations",
                description: "Use ease(to:) to animate updates to the camera's position.",
                type: CameraAnimationExample.self)
        Example(title: "Viewport",
                description: "Viewport camera showcase.",
                type: ViewportExample.self)
        Example(title: "Advanced viewport gestures",
                description: "Viewport configured to allow gestures.",
                type: AdvancedViewportGesturesExample.self)
        Example(title: "Filter symbols based on pitch and distance",
                description: "Use pitch and distance-from-center expressions in the filter field of a symbol layer to remove large size POI labels in the far distance at high pitch.",
                type: PitchAndDistanceExample.self)
        Example(title: "Add an inset map",
                description: "Add a smaller inset map that visualizes the viewport of the main map.",
                type: InsetMapExample.self)
        Example(title: "Use camera(for:) bounding coordinates",
                description: "Use camera(for:) bounding coordinaters",
                type: CameraForExample.self)
    }

    // Miscellaneous examples
    public static let labExamples: [Example] = .init {
        Example(title: "Resizable image",
                description: "Add a resizable image with cap insets to a style.",
                type: ResizableImageExample.self)
        Example(title: "Map events",
                description: "Print out map events and data.",
                type: MapEventsExample.self)
        Example(title: "Map recorder",
                description: "Record and replay map animations and actions.",
                type: MapRecorderExample.self)
        Example(title: "Resize MapView",
                description: "Support smooth MapView resizing animations",
                type: ResizeMapViewExample.self)
        Example(title: "Combine",
                description: "Shows how to use map events with Combine framework.",
                type: CombineExample.self)
        Example(title: "Color Theme Example",
                description: "Shows how to use color theme",
                type: ColorThemeMapExample.self)
        Example(title: "Combine location",
                description: "Shows how to use Combine framework to drive the location puck.",
                type: CombineLocationExample.self)
        Example(title: "Edit polygon with drag/drop",
                description: "Shows how to update a polygon with drag",
                type: EditPolygonExample.self)
    }

    // Examples that focus on displaying the user's location.
    public static let locationExamples: [Example] = .init {
        Example(title: "Display the user's location",
                description: "Display the user's location on a map with the default user location puck.",
                type: TrackingModeExample.self)
        Example(title: "Basic pulsing puck",
                description: "Display sonar-like animation radiating from the location puck.",
                type: BasicLocationPulsingExample.self)
        Example(title: "Customize the location puck",
                description: "Customized the location puck on the map.",
                type: Custom2DPuckExample.self)
        Example(title: "Use a 3D model to show the user's location",
                description: "A 3D model is used to represent the user's location.",
                type: Custom3DPuckExample.self)
        Example(title: "Simulate navigation",
                description: "Simulate a driving trip from LA to San Francisco along a pre-defined route.",
                type: NavigationSimulatorExample.self)
    }

    // Examples that highlight using the Offline APIs.
    static let offlineExamples: [Example] = .init {
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
                type: OfflineManagerExample.self)

        #if DEBUG
        Example(title: "Use OfflineRegionManager to download a region",
                description: "Use the deprecated OfflineRegionManager to download regions for offline use.",
                testTimeout: 120,
                type: OfflineRegionManagerExample.self)
        #endif
    }

    // Examples that show how to use the map's snapshotter.
    static let snapshotExamples: [Example] = .init {
        Example(title: "Create a static map snapshot",
                description: """
                    Create a static, non-interactive image of a map style with specified camera position. The resulting snapshot is provided as a `UIImage`.
                    The map on top is interactive. The bottom one is a static snapshot.
                """,
                type: SnapshotterExample.self)
        Example(title: "Draw on a static snapshot with Core Graphics",
                description: """
                    Use the overlayHandler parameter to draw on top of a snapshot
                    using Core Graphhics APIs.
                """,
                type: SnapshotterCoreGraphicsExample.self)
    }

    // Examples that highlight how to set or modify the map's style and its contents.
    static let styleExamples: [Example] = .init {
        Example(title: "Display multiple icon images in a symbol layer",
                description: """
            Add point data and several images to a style and use the switchCase and get expressions to choose which image to display at each point in a SymbolLayer based on a data property.
            """,
                type: DataDrivenSymbolsExample.self)
        Example(title: "Change the position of a layer",
                description: "Insert a specific layer above or below other layers.",
                type: LayerPositionExample.self)
        Example(title: "Change the slot of a layer",
                description: "Assign a layer to a slot to make it appear above or below other layers.",
                type: LayerSlotExample.self)
        Example(title: "Cluster points within a layer",
                description: "Create a circle layer from a geoJSON source and cluster the points from that source. The clusters will update as the map's camera changes.",
                type: PointClusteringExample.self)
        Example(title: "Animate a line layer",
                description: "Animate updates to a line layer from a geoJSON source.",
                type: AnimateGeoJSONLineExample.self)
        Example(title: "Animate a style layer",
                description: "Animate the position of a style layer by updating its source data.",
                type: AnimateLayerExample.self)
        Example(title: "Add external vector tiles",
                description: "Add vector map tiles from an external source, using the {z}/{x}/{y} URL scheme.",
                type: ExternalVectorSourceExample.self)
        Example(title: "Interpolate colors between zoom level",
                description: """
                    Use an interpolate expression to style the background layer color depending on zoom level.
                """,
                type: ColorExpressionExample.self)
        Example(title: "Add a custom rendered layer",
                description: "Add a custom rendered Metal layer.",
                type: CustomLayerExample.self)
        Example(title: "Add animated weather data",
                description: "Load a raster image to a style using ImageSource and display it on a map as animated weather data using RasterLayer.",
                type: AnimateImageLayerExample.self)
        Example(title: "Add a raster tile source",
                description: "Add third-party raster tiles to a map.",
                type: RasterTileSourceExample.self)
        Example(title: "Raster colorization",
                description: "Display weather using raster-color.",
                type: RasterColorExample.self)
        Example(title: "Add live data",
                description: "Update feature coordinates from a geoJSON source in real time.",
                type: LiveDataExample.self)
        Example(title: "Join data to vector geometry",
                description: "Join local JSON data with vector tile geometries.",
                type: DataJoinExample.self)
        Example(title: "Use a distance expression",
                description: "Use a distance style expression to show features within a specific radius.",
                type: DistanceExpressionExample.self)
        Example(title: "Add custom raster source",
                description: "Load a custom raster source to Style and display it on a map as animated weather data using RasterLayer.",
                type: CustomRasterSourceExample.self)
        Example(title: "Runtime slots example",
                description: "Shows shows how to use the runtime slots.",
                type: RuntimeSlotsExample.self)
    }

    // Examples that show use cases related to user interaction with the map.
    static let userInteractionExamples: [Example] = .init {
        Example(title: "Standard Style Interactions",
                description: "Showcase of Standard style interactions.",
                type: StandardStyleInteractionsExample.self)
        Example(title: "Find features at a point",
                description: "Query the map for rendered features belonging to a specific layer.",
                type: FeaturesAtPointExample.self)
        Example(title: "Use feature state",
                description: "Manipulate map styling with feature states and expressions.",
                type: FeatureStateExample.self)
        Example(title: "Add an interactive clustered layer",
                description: "Display an alert controller after selecting a feature in a clustered layer.",
                type: SymbolClusteringExample.self)
        Example(title: "Long tap animation",
                description: "Animate camera upon a long tap.",
                type: LongTapAnimationExample.self)
    }

    // Examples that show map accessibility features
    static let accessibilityExamples: [Example] = .init {
        Example(title: "Access map features using VoiceOver",
                description: "Use VoiceOver to highlight annotations and hear their associated features.",
                type: VoiceOverAccessibilityExample.self)
    }

    // Examples that display maps using the globe projection
    static let globeAndAtmosphere: [Example] = .init {
        Example(title: "Fly-to camera animation",
                description: "Smoothly interpolate between locations with the fly-to animation.",
                type: GlobeFlyToExample.self)
        Example(title: "Create a rotating globe",
                description: "Display your map as an interactive, rotating globe.",
                type: SpinningGlobeExample.self)
        Example(title: "Visualize data as a heatmap",
                description: "Display your heatmap using the globe projection.",
                type: HeatmapLayerGlobeExample.self)
    }
}

extension Examples {
    struct Category {
        let title: String
        let examples: [Example]
    }

    static let all: [Category] = .init {
        Category(title: "Getting started", examples: gettingStartedExamples)
        Category(title: "3D and Fill Extrusions", examples: threeDExamples)
        Category(title: "Annotations", examples: annotationExamples)
        Category(title: "Camera", examples: cameraExamples)
        Category(title: "Lab", examples: labExamples)
        Category(title: "Location", examples: locationExamples)
        Category(title: "Offline", examples: offlineExamples)
        Category(title: "Snapshot", examples: snapshotExamples)
        Category(title: "Style", examples: styleExamples)
        Category(title: "User Interaction", examples: userInteractionExamples)
        Category(title: "Accessibility", examples: accessibilityExamples)
        Category(title: "Globe and Atmosphere", examples: globeAndAtmosphere)
    }
}

extension Array {
    init(@ArrayBuilder<Element> builder: () -> [Element]) {
        self.init(builder())
    }
}
