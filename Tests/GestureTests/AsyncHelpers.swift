import XCTest
@testable import MapboxMaps

extension CameraAnimator {
    @MainActor
    func waitAnimationsToEnd() async {
        guard let animator = self as? CameraAnimatorProtocol else {
            assertionFailure("Cannot convert camera animator to the CameraAnimatorProtocol")
            return
        }

        await withCheckedContinuation { continuation in
            animator.addCompletion { position in
                if position != .end {
                    assertionFailure("""
                                Animation completion handler called with
                                unexpected position type: \(position)
                                """)
                }

                continuation.resume(returning: ())
            }
        }
    }
}

extension Array where Element == CameraAnimator {
    @MainActor
    func waitForAllAnimations() async {
        for animator in self {
            await animator.waitAnimationsToEnd()
        }
    }
}
