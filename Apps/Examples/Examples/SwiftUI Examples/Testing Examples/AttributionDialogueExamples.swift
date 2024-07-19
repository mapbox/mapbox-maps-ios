import SwiftUI
import MapboxMaps

@available(iOS 15, *)
struct AttributionEnvironmentURLOpen: View {
    @State private var alert: String?
    var body: some View {
        Map()
            .ignoresSafeArea()
            .environment(\.openURL, OpenURLAction {
                alert = $0.absoluteString
                return .handled
            })
            .simpleAlert(message: $alert, title: "Open URL")
    }
}

@available(iOS 16.4, *)
struct AttributionDialogueWithSheet: View {
    @State var sheet = true
    var body: some View {
        Map()
            .additionalSafeAreaInsets(.bottom, 70)
            .ignoresSafeArea()
            .sheet(isPresented: $sheet) {
                Text("Tap attribution info button")
                    .interactiveDismissDisabled()
                    .presentationBackgroundInteraction(.enabled(upThrough: .large))
                    .presentationDetents([.height(80), .medium, .large])
            }
        }
}

@available(iOS 13, *)
struct AttributionManualURLOpen: View {
    @State private var alert: String?
    var body: some View {
        Map(urlOpener: { alert = $0.absoluteString}) {}
            .edgesIgnoringSafeArea(.all)
            .simpleAlert(message: $alert, title: "Open URL")
    }
}
