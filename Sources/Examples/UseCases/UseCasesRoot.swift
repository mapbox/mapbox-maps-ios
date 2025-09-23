import SwiftUI
@_spi(Internal) import MapboxMaps

struct UseCases {
    static let all: [Examples.Category] = [
        Examples.Category("Interactive Mapping") {
            Example("Pin Powered Map", note: "Interactive icons that drive engagement and revenue.", destination: ContentView())
        },
        Examples.Category("Data Visualization") {
            Example("Weather Radar", note: "Interactive weather visualization with timeline controls.", destination: RadarContentView())
        }
    ]
}

struct UseCasesRoot: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(UseCases.all, id: \.title) { category in
                    Section {
                        ForEach(category.examples, id: \Example.title) { example in
                            ExampleLink(example.title, note: example.description, destination: AnyView(example.destination()))
                        }
                    } header: { Text(category.title) }
                }
            }
            .navigationTitle("Use cases")
        }
    }
}
