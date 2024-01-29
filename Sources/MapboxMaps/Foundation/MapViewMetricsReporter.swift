import Foundation
import MetalKit

@_spi(Metrics) public protocol MapViewMetricsReporter: AnyObject {
    func beforeDisplayLinkCallback(displayLink: CADisplayLink)
    func afterDisplayLinkCallback(displayLink: CADisplayLink)

    func beforeMetalViewDrawCallback()
    func afterMetalViewDrawCallback()
}
