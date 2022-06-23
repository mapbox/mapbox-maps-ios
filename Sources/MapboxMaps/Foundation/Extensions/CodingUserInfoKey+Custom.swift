import Foundation

internal extension CodingUserInfoKey {
    static var nonVolatilePropertiesOnly: CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "nonVolatilePropertiesOnly")!
    }

    static var volatilePropertiesOnly: CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "volatilePropertiesOnly")!
    }
}
