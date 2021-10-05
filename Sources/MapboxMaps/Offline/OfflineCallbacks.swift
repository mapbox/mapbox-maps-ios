import Foundation
@_implementationOnly import MapboxCommon_Private

/// Returns a closure suitable for the OfflineManager and TileStore callback based
/// APIs, that converts the expected type into a Swift Result type.
/// - Parameters:
///   - closure: developer provided completion closure.
///   - type: The ObjC type. For example, for `[TileRegion]` this would be `NSArray`
/// - Returns: A suitable `Expected` base closure.
internal func coreAPIClosureAdapter<T, SwiftError, ObjCType>(
    for closure: @escaping (Result<T, Error>) -> Void,
    type: ObjCType.Type,
    concreteErrorType: SwiftError.Type,
    converter: @escaping (ObjCType) -> T? = { $0 as? T }) -> ((Expected<AnyObject, AnyObject>?) -> Void) where ObjCType: AnyObject,
                                                                                                               SwiftError: CoreErrorRepresentable,
                                                                                                               SwiftError.CoreErrorType: AnyObject {
    return { (expected: Expected?) in
        closure(
            Result(
                expected: expected,
                valueType: type,
                errorType: concreteErrorType,
                valueConverter: converter))
    }
}

internal extension Result where Failure == Error {
    init<Value, Error>(expected: Expected<AnyObject, AnyObject>?,
                       valueType: Value.Type,
                       errorType: Error.Type,
                       valueConverter: @escaping (Value) -> Success? = { $0 as? Success }) where Value: AnyObject,
                                                                                                 Error: CoreErrorRepresentable,
                                                                                                 Error.CoreErrorType: AnyObject {
        guard let expected = expected else {
            self = .failure(TypeConversionError.unexpectedType)
            return
        }
        if expected.isValue(), let value = expected.value {
            guard let typedValue = value as? Value else {
                self = .failure(TypeConversionError.unexpectedType)
                return
            }
            guard let convertedValue = valueConverter(typedValue) else {
                self = .failure(TypeConversionError.unsuccessfulConversion)
                return
            }
            self = .success(convertedValue)
        } else if expected.isError(), let error = expected.error {
            guard let typedError = error as? Error.CoreErrorType else {
                self = .failure(TypeConversionError.unexpectedType)
                return
            }
            self = .failure(Error(coreError: typedError))
        } else {
            assertionFailure("Encountered invalid object: \(expected)")
            self = .failure(TypeConversionError.invalidObject)
        }
    }
}

internal func coreAPIClosureAdapter<SwiftError>(
    for closure: @escaping (Error?) -> Void,
    concreteErrorType: SwiftError.Type) -> ((Expected<AnyObject, AnyObject>?) -> Void) where SwiftError: CoreErrorRepresentable,
                                                                                             SwiftError.CoreErrorType: AnyObject {
    return { (expected: Expected?) in
        var error: Error?

        defer {
            closure(error)
        }

        guard let expected = expected else {
            error = TypeConversionError.unexpectedType
            return
        }

        if expected.isError(), let expectedError = expected.error {
            guard let typedError = expectedError as? SwiftError.CoreErrorType else {
                error = TypeConversionError.unexpectedType
                return
            }
            error = SwiftError(coreError: typedError)
        } else if !expected.isValue() {
            assertionFailure("Encountered invalid object: \(expected)")
            error = TypeConversionError.invalidObject
        }
    }
}
