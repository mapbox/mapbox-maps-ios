import XCTest
@testable import MapboxMaps

class MockCustomRenderer: NSObject, CustomLayerHost {
    // swiftlint:disable large_tuple
    let renderingWillStartStub = Stub<(MTLDevice, UInt, UInt), Void>()
    func renderingWillStart(_ metalDevice: MTLDevice, colorPixelFormat: UInt, depthStencilPixelFormat: UInt) {
        renderingWillStartStub.call(with: (metalDevice, colorPixelFormat, depthStencilPixelFormat))
    }

    let renderStub = Stub<(CustomLayerRenderParameters, MTLCommandBuffer, MTLRenderPassDescriptor), Void>()
    func render(_ parameters: CustomLayerRenderParameters, mtlCommandBuffer: MTLCommandBuffer, mtlRenderPassDescriptor: MTLRenderPassDescriptor) {
        renderStub.call(with: (parameters, mtlCommandBuffer, mtlRenderPassDescriptor))
    }
    // swiftlint:enable large_tuple

    let renderingWillEndStub = Stub()
    func renderingWillEnd() {
        renderingWillEndStub.call()
    }
}
