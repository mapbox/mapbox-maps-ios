import SwiftUI
import UIKit
@_spi(Experimental) import MapboxMaps

@available(iOS 14.0, *)
struct SwiftUIRoot: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                Section {
                    ExampleLink("Show me the map!", note: "Just a Map().", destination: Map().ignoresSafeArea())
                    ExampleLink("Locate Me", note: "Use Viewport to create user location control.", destination: LocateMeExample())
                    ExampleLink("Locations", note: "New look of locations, configure standard style parameters.", destination: StandardStyleLocationsExample())
                    ExampleLink("Standard Style Import", note: "Import Mapbox Standard style into your custom style.", destination: StandardStyleImportExample())
                } header: { Text("Getting started") }

                Section {
                    ExampleLink("View Annotations", note: "Add/remove view annotation on tap.", destination: ViewAnnotationsExample())
                    ExampleLink("Weather annotations", note: "Show view annotations with contents changed on selection.", destination: WeatherAnnotationExample())
                    ExampleLink("Layer Annotations", note: "Add/remove layer annotation on tap.", destination: AnnotationsExample())
                } header: { Text("Annotations") }

                Section {
                    ExampleLink("Query Rendered Features on tap", note: "Use MapReader and MapboxMap to query rendered features.", destination: FeaturesQueryExample())
                    ExampleLink("Clustering data", note: "Display GeoJSON data with clustering using custom layers and handle interactions with them.", destination: ClusteringExample())
                } header: { Text("Use cases") }

                Section {
                    ExampleLink("Map settings", note: "Showcase of the most possible map configurations.", destination: MapSettingsExample())
                    ExampleLink("Viewport Playground", note: "Showcase of the possible viewport states.", destination: ViewportPlayground())
                    ExampleLink("Puck playground", note: "Display user location using puck.", destination: PuckPlayground())
                    ExampleLink("Annotation Order", destination: AnnotationsOrderTestExample())
                    ExampleLink("Simple Map", note: "Camera observing, automatic dark mode support.", destination: SimpleMapExample())
                    ExampleLink("Attribution url via callback", note: "Works on iOS 13+", destination: AttributionManualURLOpen())
                    if #available(iOS 15.0, *) {
                        ExampleLink("Attribution url open via environment", note: "Works on iOS 15+", destination: AttributionEnvironmentURLOpen())
                    }
                    if #available(iOS 16.5, *) {
                        ExampleLink("Attribution dialog with presented sheet", destination: AttributionDialogueWithSheet())
                    }

                } header: { Text("Testing Examples") }
            }
            .listStyle(.plain)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

@available(iOS 14.0, *)
struct ExampleLink<S, Destination>: View where S : StringProtocol, Destination: View {
    var title: S
    var note: S?
    var destination: () -> Destination
    init(_ title: S, note: S? = nil, destination: @escaping @autoclosure () -> Destination) {
        self.title = title
        self.note = note
        self.destination = destination
    }
    var body: some View {
        NavigationLink(destination: destination) {
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


@available(iOS 14.0, *)
func createSwiftUIExamplesController() -> UIViewController {
    let controller =  UIHostingController(rootView: SwiftUIRoot())
    controller.title = title
    controller.modalPresentationStyle = .fullScreen
    return controller
}

private let title = "SwiftUI Examples"
