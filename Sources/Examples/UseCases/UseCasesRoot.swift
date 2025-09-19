import SwiftUI
@_spi(Internal) import MapboxMaps

struct UseCasesRoot: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    ExampleLink("Pin Powered Map", note: "Interactive icons that drive engagement and revenue.", destination: ContentView())
                } header: { Text("Interactive Mapping") }

            }
            .navigationTitle("Use cases")
            .safeNavigationSubtitle(Bundle.mapboxMapsMetadata.version)
        }
    }
}
