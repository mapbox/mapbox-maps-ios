import Foundation
import MetalKit

final class MockMetalView: MTKView {
    let setNeedsDisplayStub = Stub<Void, Void>()
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        setNeedsDisplayStub.call()
    }
}
