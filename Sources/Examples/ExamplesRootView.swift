import SwiftUI
import UIKit

struct ExamplesRootView: View {
    @State private var searchText: String = ""

    // MARK: - Tab Content
    private var uikitTab: some View {
        UIKitExampleView(vc: UINavigationController(rootViewController: ExampleTableViewController(style: .insetGrouped)), title: "UIKit")
            .ignoresSafeArea()
    }

    private var swiftUITab: some View {
        SwiftUIWrapper()
    }

    private var useCasesTab: some View {
        UseCasesRoot()
    }

    private var settingsTab: some View {
        ExamplesSettingsView()
    }

    private var searchTab: some View {
        SearchView(searchText: $searchText)
            .searchable(text: $searchText)
    }

    var body: some View {
        if #available(iOS 18.0, *) {
            modernTabView
                .safeTabBarMinimizeBehaviorOnScrollDown()
        } else {
            legacyTabView
                .safeTabBarMinimizeBehaviorOnScrollDown()
        }
    }

    // MARK: - Modern Tab View (iOS 18+)
    @available(iOS 18.0, *)
    private var modernTabView: some View {
        TabView {
            Tab("UIKit", systemImage: "hammer") {
                uikitTab
            }

            Tab("SwiftUI", systemImage: "swift") {
                swiftUITab
            }

            Tab("Use Cases", systemImage: "book") {
                useCasesTab
            }

            Tab("Settings", systemImage: "gear") {
                settingsTab
            }

            Tab(role: .search) {
                searchTab
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }

    // MARK: - Legacy Tab View
    private var legacyTabView: some View {
        TabView {
            uikitTab
                .tabItem {
                    Image(systemName: "hammer")
                    Text("UIKit")
                }

            swiftUITab
                .tabItem {
                    Image(systemName: "swift")
                    Text("SwiftUI")
                }

            useCasesTab
                .tabItem {
                    Image(systemName: "book")
                    Text("Use Cases")
                }

            settingsTab
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
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
}

struct UIKitExampleView: UIViewControllerRepresentable {
    private var vc: () -> UIViewController
    private var title: String

    init(vc: @escaping @autoclosure () -> UIViewController, title: String) {
        self.vc = vc
        self.title = title
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = vc()
        vc.title = title
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed
    }
}
