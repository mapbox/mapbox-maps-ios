import MetalKit

final class MockMetalView: MTKView {
    let drawStub = Stub<Void, Void>()
    override func draw() {
        super.draw()
        drawStub.call()
    }
}
