import SwiftUI
import UIKit

struct ExamplesRootView: View {
    var body: some View {
        TabView {
            UIKitExamplesView()
                .ignoresSafeArea()
                .tabItem {
                    Image(systemName: "hammer")
                    Text("UIKit")
                }

            SwiftUIWrapper()
                .tabItem {
                    Image(systemName: "swift")
                    Text("SwiftUI")
                }

            UseCasesRoot()
                .tabItem {
                    Image(systemName: "book")
                    Text("Use Cases")
                }
        }
        .safeTabBarMinimizeBehaviorOnScrollDown()
    }
}

extension View {
    func safeTabBarMinimizeBehaviorOnScrollDown() -> some View {
#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            return self.tabBarMinimizeBehavior(.onScrollDown)
        }
#endif
        return self
    }

    func safeNavigationSubtitle(_ subtitle: String) -> some View {
#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            return self.navigationSubtitle(subtitle)
        }
#endif
        return self
    }
}

struct UIKitExamplesView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        return UINavigationController(rootViewController: ExampleTableViewController(style: .insetGrouped))
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No updates needed
    }
}
