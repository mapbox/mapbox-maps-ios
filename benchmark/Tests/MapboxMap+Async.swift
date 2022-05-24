import Foundation
import MapboxMaps

extension MapboxMap {
    public static func clearData(for resourceOptions: ResourceOptions) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            clearData(for: resourceOptions) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: ())
            }
        }
    }
}
