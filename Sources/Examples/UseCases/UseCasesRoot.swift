import SwiftUI
@_spi(Internal) import MapboxMaps

struct UseCasesRoot: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    ExampleLink("Pin Powered Map", note: "Interactive icons that drive engagement and revenue.", destination: ContentView())
                    if #available(iOS 17.0, *) {
                        ExampleLink("AI Chat + Map", note: "Build a Map experience in an AI chat", destination: ChatDemoView())
                    }
                } header: { Text("Interactive Mapping") }
            }
            .navigationTitle("Use cases")
            .safeNavigationSubtitle(Bundle.mapboxMapsMetadata.version)
        }
    }
}
