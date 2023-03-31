import SwiftUI
import UIKit
@_spi(Experimental) import MapboxMapsSwiftUI

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
                } header: { Text("Getting started") }

                Section {
                    ExampleLink("Query Rendered Features on tap", note: "Use MapReader and MapboxMap to query rendered features.", destination: FeaturesQueryExample())
                    ExampleLink("Clustering data", note: "Display GeoJSON data with clustering using custom layers and handle interactions with them.", destination: ClusteringExample())
                } header: { Text("Use cases") }

                Section {
                    ExampleLink("Basic View annotations example", note: "Add/remove view annotation on tap", destination: ViewAnnotationsExample())
                } header: { Text("View Annotations") }

                Section {
                    ExampleLink("Show user location", note: "Display user location using default 2D puck", destination: Puck2DExample())
                    ExampleLink("Show user location with 3D puck", note: "Display user location using 3D puck", destination: Puck3DExample())
                } header: { Text("Location") }
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
