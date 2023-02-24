import Foundation
import UIKit

final class Bag: Cancelable {
    private var store = [Cancelable]()

    func add(_ cancelable: Cancelable) {
        store.append(cancelable)
    }

    func add<S: Sequence>(_ cancellables: S) where S.Element == Cancelable {
        store.append(contentsOf: cancellables)
    }

    func cancel() {
        let c = store
        store.removeAll()
        c.forEach { $0.cancel() }
    }

    deinit {
        cancel()
    }
}

final class BlockCancelable: Cancelable {
    private var block: (() -> Void)?

    internal init(block: @escaping () -> Void) {
        self.block = block
    }

    func cancel() {
        if let b = block {
            block = nil
            b()
        }
    }
}

extension Cancelable {
    func addTo(_ bag: Bag) {
        bag.add(self)
    }
}

extension Sequence where Element == Cancelable {
    func addTo(_ bag: Bag) {
        bag.add(self)
    }
}

/// Incapsulates play with target/action for gesture recognizers.
@objc private final class Handler: NSObject {
    private let handle: () -> Void
    private let gesture: UIGestureRecognizer
    init(_ gesture: UIGestureRecognizer, _ handle: @escaping () -> Void) {
        self.gesture = gesture
        self.handle = handle
        super.init()
        gesture.addTarget(self, action: #selector(action))
    }

    @objc func action() {
        handle()
    }

    func cancel() {
        gesture.removeTarget(self, action: nil)
    }
}

func addGestureHandler<T: UIGestureRecognizer>(_ gesture: T, handler: @escaping (T) -> Void) -> Cancelable {
    let objcHandler = Handler(gesture) { handler(gesture) }
    return BlockCancelable(block: objcHandler.cancel)
}

@available(iOS 13.0, *)
extension CollectionDifference.Change {

    var element: ChangeElement {
        switch self {
        case .insert(_, let element, _), .remove(_, let element, _): return element
        }
    }
}

func wrapAssignError(_ body: () throws -> Void) {
    do {
        try body()
    } catch {
        print("error: \(error)") // TODO: Logger
    }
}
