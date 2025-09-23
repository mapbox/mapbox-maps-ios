import SwiftUI
@_spi(Internal) import MapboxMaps

struct ExamplesSettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Maps SDK") {
                    ViewThatFits {
                        // Try horizontal layout first
                        HStack {
                            Text("Version")
                            Spacer()
                            Text(Bundle.mapboxMapsMetadata.version)
                                .foregroundColor(.secondary)
                        }

                        // Fall back to vertical layout if horizontal doesn't fit
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Version")
                            Text(Bundle.mapboxMapsMetadata.version)
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ExamplesSettingsView()
}
