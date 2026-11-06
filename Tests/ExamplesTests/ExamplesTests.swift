import Testing
import SwiftUI
import UIKit
@testable import Examples
import MapboxMaps

/// In-process checks of every example, one case per example. The Search tab itself is covered by `OpenEveryExampleFromSearchUITests`.
@MainActor
@Suite(.serialized)
struct ExamplesTests {
    static let uiKitTab = Examples.all.flatMap(\.examples)
    static let searchTab = (Examples.all + SwiftUIExamples.all + UseCases.all).flatMap(\.examples)

    @Test("UIKit example metadata", arguments: uiKitTab)
    func metadata(_ example: Example) throws {
        let type = try #require(example.type)
        #expect(type is UIViewController.Type)
        #expect("\(type)".hasSuffix("Example"))
        #expect(!example.title.isEmpty)
        #expect(!example.description.isEmpty)
        if let last = example.title.unicodeScalars.last {
            #expect(!CharacterSet.punctuationCharacters.contains(last), "Title should not end with punctuation")
        }
    }

    @Test("UIKit tab: example loads and is released", arguments: uiKitTab)
    func loadsAndReleasesFromUIKitTab(_ example: Example) async throws {
        let window = try Self.makeWindow()
        let navigationController = UINavigationController(rootViewController: UIViewController())
        window.rootViewController = navigationController

        let shown = try await Self.show(example, in: navigationController, window: window)
        try await Self.popToRoot(navigationController)

        await Self.tearDown(window) { shown.controller == nil && shown.mapView == nil }
        #expect(shown.controller == nil, "Example view controller leaked")
        #expect(shown.mapView == nil, "MapView leaked")
    }

    @Test("SwiftUI, Use Cases and Search tabs: example loads and is released", arguments: searchTab)
    func loadsAndReleasesFromSwiftUITabs(_ example: Example) async throws {
        let window = try Self.makeWindow()
        weak var weakMapView: MapView?
        weak var weakController: UIViewController?

        if example.type != nil {
            // UIKit example hosted in SwiftUI: wait for its finish().
            try await Self.waitForFinish(in: window, timeout: example.ciTimeout, open: {
                window.rootViewController = Self.host(example)
            }, finished: { weakController = $0 })
        } else {
            window.rootViewController = Self.host(example)
            try await Self.waitForMapView(in: window, timeout: example.ciTimeout)
            try await Self.waitForMapLoaded(try #require(window.firstMapView), timeout: example.ciTimeout)
        }
        weakMapView = window.firstMapView

        await Self.tearDown(window) { weakMapView == nil && weakController == nil }
        #expect(weakMapView == nil, "MapView leaked")
        #expect(weakController == nil, "Example view controller leaked")
    }

    // MARK: - Helpers

    private struct Shown {
        weak var controller: UIViewController?
        weak var mapView: MapView?
    }

    /// Pushes the example, waits for its `finish()` and returns weak references.
    private static func show(_ example: Example, in navigationController: UINavigationController, window: UIWindow) async throws -> Shown {
        let controller = example.makeViewController()
        try await waitForFinish(in: window, timeout: example.ciTimeout) {
            navigationController.pushViewController(controller, animated: false)
        }
        let mapView = window.firstMapView
        #expect(mapView != nil || controller is NonMapViewExampleProtocol, "No MapView found")
        return Shown(controller: controller, mapView: mapView)
    }

    private static func host(_ example: Example) -> UIViewController {
        let view = NavigationStack {
            ExampleView { AnyView(example.destination()) }
        }
        .examplesEnvironment(overrides: StyleOverridesModel(), locations: StandardStyleLocationsModel())
        return UIHostingController(rootView: view)
    }

    /// Animated pop, awaited so the example gets `viewDidDisappear` before the release check.
    private static func popToRoot(_ navigationController: UINavigationController) async throws {
        let (stream, continuation) = AsyncStream<Void>.makeStream()
        let delegate = PopDelegate { continuation.finish() }
        navigationController.delegate = delegate
        defer { withExtendedLifetime(delegate) { navigationController.delegate = nil } }
        navigationController.popToRootViewController(animated: true)
        try await withTimeout(5, "Pop did not finish") {
            for await _ in stream {}
        }
    }

    private final class PopDelegate: NSObject, UINavigationControllerDelegate {
        private let didShowRoot: () -> Void
        init(didShowRoot: @escaping () -> Void) { self.didShowRoot = didShowRoot }
        func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
            if viewController === navigationController.viewControllers.first { didShowRoot() }
        }
    }

    private static func makeWindow() throws -> UIWindow {
        let scene = try #require(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let window = UIWindow(windowScene: scene)
        window.windowLevel = .alert
        window.makeKeyAndVisible()
        return window
    }

    /// MapView releases asynchronously, so wait up to 5s.
    private static func tearDown(_ window: UIWindow, released: @MainActor () -> Bool) async {
        window.rootViewController = nil
        window.isHidden = true
        let deadline = ContinuousClock.now + .seconds(5)
        while !released() && ContinuousClock.now < deadline {
            try? await Task.sleep(for: .milliseconds(50))
        }
    }

    /// `finished` gets the controller that posted `finish()`.
    private static func waitForFinish(in window: UIWindow, timeout: TimeInterval, open: () -> Void, finished: @escaping @MainActor (UIViewController) -> Void = { _ in }) async throws {
        let notifications = NotificationCenter.default.notifications(named: Example.finishNotificationName)
        open()
        try await withTimeout(timeout, "finish() was not called") {
            for await notification in notifications {
                if let controller = notification.object as? UIViewController, controller.viewIfLoaded?.window === window {
                    finished(controller)
                    return
                }
            }
        }
    }

    private static func waitForMapView(in window: UIWindow, timeout: TimeInterval) async throws {
        try await withTimeout(timeout, "No MapView found") {
            while window.firstMapView == nil {
                try await Task.sleep(for: .milliseconds(50))
            }
        }
    }

    /// Waits on a stream so the timeout can cancel it. `onMapIdle` keeps firing after the load, in case `onMapLoaded` came before the subscription.
    private static func waitForMapLoaded(_ mapView: MapView, timeout: TimeInterval) async throws {
        let (stream, continuation) = AsyncStream<Void>.makeStream()
        let map: MapboxMap = mapView.mapboxMap
        let tokens = [map.onMapLoaded.observe { _ in continuation.finish() }, map.onMapIdle.observe { _ in continuation.finish() }]
        defer { tokens.forEach { $0.cancel() } }
        try await withTimeout(timeout, "Map did not load") {
            for await _ in stream {}
        }
    }

    private struct Timeout: Error, CustomStringConvertible {
        var description: String
    }

    private static func withTimeout<T: Sendable>(_ seconds: TimeInterval, _ message: String, _ body: @escaping @MainActor () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask { try await body() }
            group.addTask {
                try await Task.sleep(for: .seconds(seconds))
                throw Timeout(description: "\(message) within \(Int(seconds))s")
            }
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}

extension Example: @retroactive CustomTestStringConvertible {
    public var testDescription: String { title }
}

private extension Example {
    /// The CI simulator needs a few seconds just to bring the first map up.
    var ciTimeout: TimeInterval { max(testTimeout, 60) }
}

private extension UIWindow {
    var firstMapView: MapView? { firstMapView(in: self) }

    private func firstMapView(in view: UIView) -> MapView? {
        if let mapView = view as? MapView { return mapView }
        for subview in view.subviews {
            if let mapView = firstMapView(in: subview) { return mapView }
        }
        return nil
    }
}
