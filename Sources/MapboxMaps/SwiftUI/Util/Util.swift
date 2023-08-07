import Foundation
import UIKit
import SwiftUI

@available(iOS 13.0, *)
enum ConstantOrBinding<T> {
    case constant(T)
    case binding(Binding<T>)
}

func wrapAssignError(_ body: () throws -> Void) {
    do {
        try body()
    } catch {
        Log.error(forMessage: "Failed to assign property, error: \(error)", category: "swiftui")
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
