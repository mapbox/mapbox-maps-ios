import Foundation

/// Returns a closure suitable for the OfflineManager and TileStore callback based
/// APIs, that converts the expected type into a Swift Result type.
/// - Parameters:
///   - closure: developer provided completion closure.
///   - type: The ObjC type. For example, for `[TileRegion]` this would be `NSArray`
/// - Returns: A suitable `MBXExpected` base closure.
internal func coreAPIClosureAdapter<T, ErrorType, ObjCType>(for closure: @escaping (Result<T, ErrorType>) -> Void, type: ObjCType.Type)
-> ((MBXExpected<AnyObject, AnyObject>?) -> Void)
where ObjCType: AnyObject,
      ErrorType: CoreErrorRepresentable,
      ErrorType.CoreErrorType: AnyObject {
    return { (expected: MBXExpected?) in
        let result: Result<T, ErrorType>

        defer {
            closure(result)
        }

        guard let expected = expected as? MBXExpected<ObjCType, ErrorType.CoreErrorType>  else {
            result = .failure(ErrorType(unspecifiedError: "No or invalid result returned."))
            return
        }

        if expected.isValue(), let value = expected.value as? T {
            result = .success(value)
        } else if expected.isError(), let error = expected.error {
            result = .failure(ErrorType(coreError: error))
        } else {
            assertionFailure("Unexpected value or error: \(expected), expected: \(T.self)")
            result = .failure(ErrorType(unspecifiedError: "Unexpected value or error."))
        }
    }
}
