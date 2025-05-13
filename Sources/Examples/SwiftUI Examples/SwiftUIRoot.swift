import SwiftUI
import UIKit
import MapboxMaps

struct SwiftUIRoot: View {
    var body: some View {
        ExamplesNavigationView {
            List {
                Section {
                    ExampleLink("Simple Map", note: "Camera observing, automatic dark mode support.", destination: SimpleMapExample())
                    ExampleLink("Locate Me", note: "Use Viewport to create user location control.", destination: LocateMeExample())
                    ExampleLink("Dynamic Styling Example", note: "Use dynamic styling at runtime", destination: DynamicStylingExample())
                    ExampleLink("Override Location", note: "Override LocationProvider using Combine", destination: LocationOverrideExample())
                } header: { Text("Getting started") }

                Section {
                    ExampleLink("Locations", note: "New look of locations, configure standard style parameters.", destination: StandardStyleLocationsExample())
                    ExampleLink("Style Imports", note: "Learn how to use style imports and add interactions to featuresets.", destination: StandardStyleImportExample())
                    ExampleLink("Interactive features", note: "Use featuresets to add interactions to Standard Style.", destination: StandardInteractiveFeaturesExample())
                    ExampleLink("Interactive buildings", note: "Add interactions to buildings in Standard Style", destination: StandardInteractiveBuildingsExample())
                } header: { Text("Standard Style") }

                Section {
                    ExampleLink("View Annotations", note: "Add/remove view annotation on tap.", destination: ViewAnnotationsExample())
                    ExampleLink("Weather annotations", note: "Show view annotations with contents changed on selection.", destination: WeatherAnnotationExample())
                    ExampleLink("Layer Annotations", note: "Add/remove layer annotation on tap.", destination: AnnotationsExample())
                } header: { Text("Annotations") }

                Section {
#if !os(visionOS)
                    ExampleLink("Query Rendered Features on tap", note: "Use MapReader and MapboxMap to query rendered features.", destination: FeaturesQueryExample())
#endif
                    ExampleLink("Clustering data", note: "Display GeoJSON data with clustering using custom layers and handle interactions with them.", destination: ClusteringExample())
                    ExampleLink("Geofencing User Location", note: "Set geofence on user initial location.", destination: GeofencingUserLocation())
                    ExampleLink("Geofencing Playground", note: "Showcase isochrone API together with geofences.", destination: GeofencingPlayground())
                    ExampleLink("Color Themes", note: "Showcase the Color Theme API", destination: ColorThemeExample())
                } header: { Text("Use cases") }

                Section {
                    ExampleLink("Line elevation", destination: ElevatedLineMapView())
                } header: { Text("🔬 Experimental APIs") }

                Section {
                    ExampleLink("Map settings", note: "Showcase of the most possible map configurations.", destination: MapSettingsExample())
                    ExampleLink("Interactions playground", note: "Interactions edge cases", destination: InteractionsPlayground())
                    ExampleLink("Viewport Playground", note: "Showcase of the possible viewport states.", destination: ViewportPlayground())
                    ExampleLink("Puck playground", note: "Display user location using puck.", destination: PuckPlayground())
                    ExampleLink("Annotation Order", destination: AnnotationsOrderTestExample())
                    ExampleLink("Snapshot Map", note: "Make a snapshot of the map.", destination: SnapshotMapExample())

                    ExampleLink("Attribution url via callback", note: "Works on iOS 13+", destination: AttributionManualURLOpen())
                    ExampleLink("Raster particles", note: "Rendering of raster particles.", destination: RasterParticleExample())
                    ExampleLink("Clip Layer", note: "Usage of clip layer to hide 3D models at some areas on the map", destination: ClipLayerExample())
                    ExampleLink("Attribution url open via environment", note: "Works on iOS 15+", destination: AttributionEnvironmentURLOpen())
#if !os(visionOS)
                    if #available(iOS 16.5, *) {
                        ExampleLink("Attribution dialog with presented sheet", destination: AttributionDialogueWithSheet())
                    }
#endif
                    ExampleLink("Precipitation", note: "Show show and rain", destination: PrecipitationExample())
                    ExampleLink("Custom geometry", note: "Supply custom geometry to the map", destination: CustomGeometrySourceExample())

                } header: { Text("Testing Examples") }
            }
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
        NavigationLink(destination: ExampleView(destination)) {
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

func createSwiftUIExamplesController() -> UIViewController {
    let controller =  UIHostingController(rootView: SwiftUIWrapper())
    controller.title = title
    controller.modalPresentationStyle = .fullScreen
    return controller
}

struct ExamplesNavigationView<Content>: View where Content: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationView {
            content
                .listStyle(.plain)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .modifier(ToolbarContentWhenPresented { dismiss in
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") { dismiss() }
                    }
                })
        }
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
            .navigationBarHidden(isNavigationBarHidden)
            .onShake {
                isNavigationBarHidden.toggle()
            }
    }
}

private let title = "SwiftUI Examples"
