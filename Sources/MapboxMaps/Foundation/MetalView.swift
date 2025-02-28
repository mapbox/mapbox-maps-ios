import MetalKit

#if swift(>=5.9) && os(visionOS)
/// Implements analog of MTKView on top of CAMetalLayer. Currently is used only for visionOS rendering.
class MetalView: UIView, CoreMetalView {
    var presentsWithTransaction: Bool {
        get { metalLayer.presentsWithTransaction }
        set { metalLayer.presentsWithTransaction = newValue }
    }

    var drawableSize: CGSize {
        get { metalLayer.drawableSize }
        set { metalLayer.drawableSize = newValue }
    }

    let autoResizeDrawable = false
    let multisampleColorTexture: MTLTexture? = nil // TODO: MAPSIOS-1282
    var sampleCount: Int = 0
    var onRender: (() -> Void)?

    init(frame: CGRect, device: MTLDevice?) {
        super.init(frame: frame)
        metalLayer.device = device
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }

    func draw() {
        onRender?()
    }

    func nextDrawable() -> CAMetalDrawable? {
        metalLayer.nextDrawable()
    }

    func releaseDrawables() {
        // TODO: MAPSIOS-1282
    }

    private var metalLayer: CAMetalLayer {
        // swiftlint:disable:next force_cast
        layer as! CAMetalLayer
    }

    static override var layerClass: AnyClass {
        CAMetalLayer.self
    }
}
#else
/// On iOS the MTKView is used to prevent potential breaking of existing behavior.
/// Also, iOS 13 simulator doesn't directly support CAMetalLayer.
class MetalView: MTKView, CoreMetalView {
    private class DelegateImpl: NSObject, MTKViewDelegate {
        var onRender: (() -> Void)?
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        func draw(in view: MTKView) {
            onRender?()
        }
    }

    var onRender: (() -> Void)? {
        get { delegateImpl.onRender }
        set { delegateImpl.onRender = newValue }
    }

    func nextDrawable() -> CAMetalDrawable? { currentDrawable }

    private let delegateImpl = DelegateImpl()

    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        autoResizeDrawable = false
        isPaused = true
        enableSetNeedsDisplay = false
        delegate = delegateImpl
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
#endif
