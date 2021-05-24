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
    concreteErrorType: SwiftError.Type) -> ((Expected<AnyObject, AnyObject>?) -> Void) where ObjCType: AnyObject,
                                                                                                SwiftError: CoreErrorRepresentable,
                                                                                                SwiftError.CoreErrorType: AnyObject {
    return { (expected: Expected?) in
        let result: Result<T, Error>

        defer {
            closure(result)
        }

        guard let expected = expected as? Expected<ObjCType, SwiftError.CoreErrorType>  else {
            assertionFailure("Invalid MBXExpected types or none.")
            result = .failure(TypeConversionError.unexpectedType)
            return
        }

        if expected.isValue(), let value = expected.value as? T {
            result = .success(value)
        } else if expected.isError(), let error = expected.error {
            result = .failure(SwiftError(coreError: error))
        } else {
            assertionFailure("Unexpected value or error: \(expected), expected: \(T.self)")
            result = .failure(TypeConversionError.invalidObject)
        }
    }
}

internal func coreAPIClosureAdapter<SwiftError>(
    for closure: @escaping (Result<Void, Error>) -> Void,
    concreteErrorType: SwiftError.Type) -> ((Expected<AnyObject, AnyObject>?) -> Void) where SwiftError: CoreErrorRepresentable,
                                                                                                SwiftError.CoreErrorType: AnyObject {
    return { (expected: Expected?) in
        let result: Result<Void, Error>

        defer {
            closure(result)
        }

        guard let expected = expected as? Expected<AnyObject, SwiftError.CoreErrorType>  else {
            assertionFailure("Invalid MBXExpected types or none.")
            result = .failure(TypeConversionError.unexpectedType)
            return
        }

        if expected.isValue() {
            result = .success(())
        } else if expected.isError(), let error = expected.error {
            result = .failure(SwiftError(coreError: error))
        } else {
            assertionFailure("Unexpected value or error: \(expected)")
            result = .failure(TypeConversionError.invalidObject)
        }
    }
}
