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
                    ExampleLink("Display details on tap", note: "Query rendered map features on tap and display them in details.", destination: FeaturesQueryExample())
                    ExampleLink("Clustering data", note: "Clusteing annotations using direct style modification", destination: ClusteringExample())
                    ExampleLink("Image annotations", note: "Displays Image annotations from GeoJSON using custom StyleComponent.", destination: StyleAnnotationsExample())
                    ExampleLink("Add annotation by tap", note: "Add dynamic annotations using custom StyleComponent.", destination: DynamicAnnotaionsExample())
                } header: { Text("Use cases") }
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
