import MetalKit

internal protocol MapViewDependencyProviderProtocol {
    func makeMetalView(frame: CGRect, device: MTLDevice?) -> MTKView
    func makeDisplayLink(window: UIWindow, target: Any, selector: Selector) -> DisplayLinkProtocol?
}

internal final class MapViewDependencyProvider: MapViewDependencyProviderProtocol {
    func makeMetalView(frame: CGRect, device: MTLDevice?) -> MTKView {
        MTKView(frame: frame, device: device)
    }

    func makeDisplayLink(window: UIWindow, target: Any, selector: Selector) -> DisplayLinkProtocol? {
        window.screen.displayLink(withTarget: target, selector: selector)
    }
}
