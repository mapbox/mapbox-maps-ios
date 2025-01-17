import Foundation
import UIKit
import SwiftUI

enum ConstantOrBinding<T> {
    case constant(T)
    case binding(Binding<T>)
}

func wrapAssignError(_ body: () throws -> Void) {
    do {
        try body()
    } catch {
        Log.error("Failed to assign property, error: \(error)", category: "SwiftUI")
    }
}

func assign<T: Equatable>(_ oldValue: T, _ setter: (T) throws -> Void, value: T) {
    wrapAssignError {
        if oldValue != value {
            try setter(value)
        }
    }
}

func assign<U, T: Equatable>(_ object: inout U, _ keyPath: WritableKeyPath<U, T>, value: T) {
    assign(object[keyPath: keyPath], { object[keyPath: keyPath] = $0 }, value: value)
}

func assign<U, T: Equatable>(_ object: U, _ keyPath: ReferenceWritableKeyPath<U, T>, value: T) {
    assign(object[keyPath: keyPath], { object[keyPath: keyPath] = $0 }, value: value)
}

func copyAssigned<Root, T>(_ s: Root, _ keyPath: WritableKeyPath<Root, T>, _ value: T) -> Root {
    var copy = s
    copy[keyPath: keyPath] = value
    return copy
}

func copyAppended<Root, T>(_ s: Root, _ keyPath: WritableKeyPath<Root, T>, _ newElement: T.Element) -> Root where T: RangeReplaceableCollection {
    copyAssigned(s, keyPath, s[keyPath: keyPath] + [newElement])
}

/// - Returns: The result of `f` applied to `a`.
func with<A, B>(_ a: A, _ f: (A) throws -> B) rethrows -> B {
    return try f(a)
}

/// Produces an immutable setter function for a given key path and constant value.
///
/// - Parameters:
///   - keyPath: A key path.
///   - value: A new value.
/// - Returns: A setter function.
func setter<Root, Value>(
    _ keyPath: WritableKeyPath<Root, Value>,
    _ value: Value
)
-> (Root) -> Root {

    over(keyPath, { return value })
}

/// Produces an immutable setter function for a given key path and update function.
func over<Root, Value>(
    _ keyPath: WritableKeyPath<Root, Value>,
    _ update: @escaping () -> Value
)
-> (Root) -> Root {

    return { root in
        var copy = root
        copy[keyPath: keyPath] = update()
        return copy
    }
}
