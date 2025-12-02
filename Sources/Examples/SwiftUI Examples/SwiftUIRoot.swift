import SwiftUI
import UIKit
@_spi(Internal) import MapboxMaps

struct SwiftUIExamples {
    static let all: [Examples.Category] = [
        Examples.Category("Getting Started") {
            Example("Simple Map", note: "Camera observing, automatic dark mode support.", destination: SimpleMapExample())
            Example("Locate Me", note: "Use Viewport to create user location control.", destination: LocateMeExample())
            Example("Dynamic Styling Example", note: "Use dynamic styling at runtime", destination: DynamicStylingExample())
            Example("Override Location", note: "Override LocationProvider using Combine", destination: LocationOverrideExample())
        },
        Examples.Category("Standard Style") {
            Example("Locations", note: "New look of locations, configure standard style parameters.", destination: StandardStyleLocationsExample())
            Example("Style Imports", note: "Learn how to use style imports and add interactions to featuresets.", destination: StandardStyleImportExample())
            Example("Interactive features", note: "Use featuresets to add interactions to Standard Style.", destination: StandardInteractiveFeaturesExample())
            Example("Interactive buildings", note: "Add interactions to buildings in Standard Style", destination: StandardInteractiveBuildingsExample())
        },
        Examples.Category("Annotations") {
            Example("Add Map Markers", note: "Add/remove Markers to your map.", destination: MarkersExample())
            Example("View Annotations", note: "Add/remove view annotation on tap.", destination: ViewAnnotationsExample())
            Example("Weather annotations", note: "Show view annotations with contents changed on selection.", destination: WeatherAnnotationExample())
            Example("Layer Annotations", note: "Add/remove layer annotation on tap.", destination: AnnotationsExample())
        },
        Examples.Category("Use cases") {
#if !os(visionOS)
            Example("Query Rendered Features on tap", note: "Use MapReader and MapboxMap to query rendered features.", destination: FeaturesQueryExample())
#endif
            Example("Clustering data", note: "Display GeoJSON data with clustering using custom layers and handle interactions with them.", destination: ClusteringExample())
            Example("Appearances", note: "Change icon images dynamically using the Appearances API with feature-state.", destination: AppearancesExample())
            Example("Custom Vector Icons", note: "Dynamically style vector icons with custom colors and interactively change their size on tap.", destination: CustomVectorIconsExample())
            Example("Geofencing User Location", note: "Set geofence on user initial location.", destination: GeofencingUserLocation())
            Example("Geofencing Playground", note: "Showcase isochrone API together with geofences.", destination: GeofencingPlayground())
            Example("Color Themes", note: "Showcase the Color Theme API", destination: ColorThemeExample())
        },
        Examples.Category("🔬 Experimental APIs") {
            Example("Line elevation", note: "Showcase of the Line Elevation API.", destination: ElevatedLineMapView())
        },
        Examples.Category("Testing Examples") {
            Example("Map settings", note: "Showcase of the most possible map configurations.", destination: MapSettingsExample())
            Example("Interactions playground", note: "Interactions edge cases", destination: InteractionsPlayground())
            Example("Viewport Playground", note: "Showcase of the possible viewport states.", destination: ViewportPlayground())
            Example("Puck playground", note: "Display user location using puck.", destination: PuckPlayground())
            Example("Annotation Order", note: "Test the rendering order of annotations.", destination: AnnotationsOrderTestExample())
            Example("Snapshot Map", note: "Make a snapshot of the map.", destination: SnapshotMapExample())
            Example("Locate Me (Core Location Provider)", note: "Use Viewport to create user location control. This example uses Location Provider from MabpoxCommon", destination: LocateMeCoreLocationProviderExample())

            Example("Attribution url via callback", note: "Works on iOS 13+", destination: AttributionManualURLOpen())
            Example("Raster particles", note: "Rendering of raster particles.", destination: RasterParticleExample())
            Example("Clip Layer", note: "Usage of clip layer to hide 3D models at some areas on the map", destination: ClipLayerExample())
            Example("Attribution url open via environment", note: "Works on iOS 15+", destination: AttributionEnvironmentURLOpen())
#if !os(visionOS)
            if #available(iOS 16.5, *) {
                Example("Attribution dialog with presented sheet", note: "Works on iOS 16.5 and above", destination: AttributionDialogueWithSheet())
            }
#endif
            Example("Precipitation", note: "Show show and rain", destination: PrecipitationExample())
            Example("Custom geometry", note: "Supply custom geometry to the map", destination: CustomGeometrySourceExample())
            Example("Studio style", note: "Test a Mapbox Studio style", destination: StudioStyleExample())
        }
    ]
}

struct SwiftUIRoot: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(SwiftUIExamples.all, id: \.title) { category in
                    Section {
                        ForEach(category.examples, id: \Example.title) { example in
                            ExampleLink(example.title, note: example.description, destination: AnyView(example.destination()))
                        }
                    } header: { Text(category.title) }
                }
            }
            .navigationTitle(title)
        }
    }
}

struct ExampleLink<S, Destination>: View where S: StringProtocol, Destination: View {
    var title: S
    var note: S?
    var destination: () -> Destination
    init(_ title: S, note: S? = nil, destination: @escaping @autoclosure () -> Destination) {
        self.title = title
        self.note = note
        self.destination = destination
    }
    var body: some View {
        NavigationLink(destination: ExampleView(destination).navigationTitle(title)) {
            VStack(alignment: .leading) {
                Text(title)
                note.map {
                    Text($0)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

private struct ToolbarContentWhenPresented<T: ToolbarContent>: ViewModifier {
    @Environment(\.presentationMode) var presentationMode
    var toolbarContent: (@escaping () -> Void) -> T
    func body(content: Content) -> some View {
        if presentationMode.wrappedValue.isPresented {
            content.toolbar {
                toolbarContent({ presentationMode.wrappedValue.dismiss() })
            }
        } else {
            content
        }
    }
}

struct SwiftUIWrapper: View {
    // A model for StandardStyleLocationsExample.
    @StateObject var locationsModel = StandardStyleLocationsModel()
    var body: some View {
        SwiftUIRoot()
            .environmentObject(locationsModel)
    }
}

struct ExampleView<Content>: View where Content: View {
    @State private var isNavigationBarHidden = false
    let content: Content

    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(isNavigationBarHidden)
            .onShake {
                isNavigationBarHidden.toggle()
            }
    }
}

private let title = "SwiftUI Examples"
