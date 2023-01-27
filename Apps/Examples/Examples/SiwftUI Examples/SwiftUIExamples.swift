import SwiftUI
import UIKit

@available(iOS 14.0, *)
struct SwiftUIExamples: View {
    var onClose: () -> Void
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Simple Map", destination: SimpleMapExample())
                NavigationLink("Query features", destination: FeaturesQueryExample())
                NavigationLink(destination: MapSettingsExample()) {
                    VStack(alignment: .leading) {
                        Text("Map Settings")
                        Text("Shows many of possible map configurations").font(.footnote).foregroundColor(.gray)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("SwiftUI Examples")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close", action: onClose)
                }
            }
        }
    }
}


@available(iOS 14.0, *)
func createSwiftUIExamplesController() -> UIViewController {
    weak var weakController: UIViewController?
    let controller =  UIHostingController(rootView: SwiftUIExamples(onClose: {
        weakController?.presentingViewController?.dismiss(animated: true)
    }))
    weakController = controller
    controller.title = title
    controller.modalPresentationStyle = .fullScreen
    return controller
}

private let title = "SwiftUI Examples"
