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
                    ExampleLink("Simple map", note: "Camera observing, automatic dark mode support.", destination: SimpleMapExample())
                    ExampleLink("Map settings", note: "Showcase of the most possible map configurations.", destination: MapSettingsExample())
                    ExampleLink("Viewport", note: "Showcase of the possible viewport states", destination: MapViewportExample())
                    ExampleLink("Locate Me", note: "Example of how to create user location control", destination: LocateMeExample())
                } header: { Text("Getting started") }

                Section {
                    ExampleLink("Locations", note: "New look of locations, configure standard style parameters", destination: StandardStyleLocationsExample())
                    ExampleLink("Standard Style Import", note: "Import Mapbox Standard style into your custom style.", destination: StandardStyleImportExample())
                } header: { Text("Standard Style") }

                Section {
                    ExampleLink("Query Rendered Features on tap", note: "Use MapReader and MapboxMap to query rendered features.", destination: FeaturesQueryExample())
                    ExampleLink("Clustering data", note: "Display GeoJSON data with clustering using custom layers and handle interactions with them.", destination: ClusteringExample())
                } header: { Text("Use cases") }

                Section {
                    ExampleLink("View Annotations", note: "Add/remove view annotation on tap.", destination: ViewAnnotationsExample())
                    ExampleLink("Layer Annotations", note: "Add/remove layer annotation on tap.", destination: AnnotationsExample())
                } header: { Text("Annotations") }

                Section {
                    ExampleLink("Puck playground", note: "Display user location using puck", destination: PuckPlayground())
                    ExampleLink("Annotation Stability", destination: AnnotationsStabilityTestExample())
                    ExampleLink("AttributionURL open (iOS 13+)", note: "Override attribution url opener.", destination: URLOpenIOS13())
                    if #available(iOS 15.0, *) {
                        ExampleLink("AttributionURL open (iOS 15+)", note: "Override attribution url opener.", destination: URLOpenIOS15())
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
