import Metal

class EmptyCustomRenderer: NSObject, CustomLayerHost {
    let shouldWarnBeforeUsage: Bool

    init(shouldWarnBeforeUsage: Bool = true) {
        self.shouldWarnBeforeUsage = shouldWarnBeforeUsage
    }

    func renderingWillStart(_ metalDevice: MTLDevice, colorPixelFormat: UInt, depthStencilPixelFormat: UInt) { }

    func render(_ parameters: CustomLayerRenderParameters, mtlCommandBuffer: MTLCommandBuffer, mtlRenderPassDescriptor: MTLRenderPassDescriptor) {}

    func renderingWillEnd() { }
}
