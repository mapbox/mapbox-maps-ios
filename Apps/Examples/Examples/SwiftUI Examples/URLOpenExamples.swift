import SwiftUI
@_spi(Experimental) import MapboxMaps


@available(iOS 15, *)
struct URLOpenIOS15: View {
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

@available(iOS 13, *)
struct URLOpenIOS13: View {
    @State private var alert: String?
    var body: some View {
        Map(urlOpener: { alert = $0.absoluteString}) {}
            .edgesIgnoringSafeArea(.all)
            .simpleAlert(message: $alert, title: "Open URL")
    }
}
