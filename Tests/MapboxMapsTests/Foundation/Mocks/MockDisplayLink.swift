import Foundation
@testable import MapboxMaps

final class MockDisplayLink: DisplayLinkProtocol {

    var timestamp: CFTimeInterval = 0

    var duration: CFTimeInterval = 0

    var preferredFramesPerSecond: Int = 0

    struct AddParams {
        var runloop: RunLoop
        var mode: RunLoop.Mode
    }
    let addStub = Stub<AddParams, Void>()
    func add(to runloop: RunLoop, forMode mode: RunLoop.Mode) {
        addStub.call(with: AddParams(runloop: runloop, mode: mode))
    }

    let invalidateStub = Stub<Void, Void>()
    func invalidate() {
        invalidateStub.call()
    }
}
