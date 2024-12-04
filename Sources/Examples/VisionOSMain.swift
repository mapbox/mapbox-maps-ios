import SwiftUI

@main
struct VisionOSMain: App {
    // A model for StandardStyleLocationsExample.
    @StateObject var locationsModel = StandardStyleLocationsModel()
    var body: some Scene {
        WindowGroup {
            SwiftUIRoot()
                .environmentObject(locationsModel)
        }

        WindowGroup(id: "standard-style-locations-settings") {
            StandardStyleLocationsSettings()
                .fixedSize()
                .padding(10)
                .environmentObject(locationsModel)
        }
        .windowResizability(.contentSize)
    }
}
