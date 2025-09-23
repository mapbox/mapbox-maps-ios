import UIKit
import SwiftUI

public struct Example: Sendable {
    public static let finishNotificationName = Notification.Name("com.mapbox.Examples.finish")

    public var title: String
    public var description: String
    public var testTimeout: TimeInterval = 20.0
    public var type: ExampleProtocol.Type?
    public var destination: () -> any View

    init(_ title: String, note: String, destination: @autoclosure @escaping () -> any View) {
        self.title = title
        self.description = note
        self.destination = destination
    }

    init(title: String, description: String, testTimeout: TimeInterval = 20.0, type: ExampleProtocol.Type) {
        self.title = title
        self.description = description
        self.testTimeout = testTimeout
        self.type = type
        self.destination = { AnyView(UIKitExampleView(vc: Self.viewControllerFrom(type: type, title: title), title: title).ignoresSafeArea()) }
    }

    static private func viewControllerFrom(type: ExampleProtocol.Type?, title: String) -> UIViewController {
        guard let exampleClass = type as? UIViewController.Type else {
            fatalError("Unable to get class name from example named \(type.debugDescription)")
        }

        let exampleViewController: UIViewController

        // Look for a storyboard
        let storyboardName = String(describing: exampleClass)
        if Bundle.main.path(forResource: storyboardName, ofType: "storyboardc") != nil {
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            exampleViewController = storyboard.instantiateInitialViewController()!

            // Check controller is what we expect
            assert(Swift.type(of: exampleViewController) == exampleClass)
        } else {
            exampleViewController = exampleClass.init()
        }

        exampleViewController.title = title
        exampleViewController.navigationItem.largeTitleDisplayMode = .never

        return exampleViewController

    }

    func makeViewController() -> UIViewController { Self.viewControllerFrom(type: type, title: title) }
}

@resultBuilder
struct ExampleBuilder {
    static func buildBlock(_ components: [Example]...) -> [Example] {
        components.flatMap { $0 }
    }

    static func buildExpression(_ expression: Example) -> [Example] {
        [expression]
    }

    static func buildExpression(_ expression: [Example]) -> [Example] {
        expression
    }

    static func buildOptional(_ component: [Example]?) -> [Example] {
        component ?? []
    }

    static func buildEither(first component: [Example]) -> [Example] {
        component
    }

    static func buildEither(second component: [Example]) -> [Example] {
        component
    }

    static func buildLimitedAvailability(_ component: [Example]) -> [Example] {
        component
    }
}
