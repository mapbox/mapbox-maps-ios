/// An imperative controller that can be plugged into the declarative map content.
///
/// Conforming objects are notified when they enter and leave the content tree, which lets a
/// controller that drives the map imperatively follow the lifecycle of the surrounding
/// declarative content. Put one on the map with ``CustomMapContent``.
///
/// - Note:
///     - Attachments are compared by identity: the same object stays attached across content updates.
///     - One object can be attached in one place at a time; a second mount is logged and ignored.
///     - A style reload wipes what the attachment added without re-attaching it; observe
///       ``MapboxMap/onStyleLoaded`` to rebuild.
///     - Don't retain the context's map or view annotations strongly: the content tree retains the
///       attachment, so a strong reference back closes a reference cycle. Keeping the signals is fine.
@_spi(Internal)
@_documentation(visibility: internal)
public protocol MapContentAttachment: AnyObject {
    /// Called on the main thread once the attachment is in the content tree and the style is loaded.
    ///
    /// - Note: This runs synchronously inside the content walk, so content declared after yours is not
    /// on the map yet, and SwiftUI state must not be published from here.
    func attached(to context: MapContentAttachmentContext)

    /// Called when the attachment leaves the content tree or when the map itself goes away.
    ///
    /// - Note: On map teardown the map you were attached to is already gone; don't reach for it.
    func detached()
}

/// What a ``MapContentAttachment`` gets from the map view it is attached to.
@_spi(Internal)
@_documentation(visibility: internal)
public struct MapContentAttachmentContext {
    /// The map the attachment is attached to.
    public let map: MapboxMap

    /// View annotations of the map view that shows ``map``.
    public let viewAnnotations: ViewAnnotationManager

    /// The frame's `targetTimestamp` (`CADisplayLink` clock, seconds), sent before the map's camera
    /// animators run and it draws. Silent while the view is not in a window or its scene is inactive.
    public let displayLink: Signal<CFTimeInterval>

    /// The screen's maximum frame rate, lowered to the view's preferred rate when the app set one;
    /// 0 without a window (always 0 on visionOS). Sends the current value on observing, then every change.
    public let targetFramesPerSecond: Signal<Int>
}

// In an extension to keep the memberwise init internal: only the SDK builds a context field by field.
@_spi(Internal)
extension MapContentAttachmentContext {
    /// The context of `mapView`, for calling `attached(to:)` by hand in UIKit.
    public init(mapView: MapView) {
        self.init(
            map: mapView.mapboxMap,
            viewAnnotations: mapView.viewAnnotations,
            displayLink: mapView.displayLinkSignal,
            targetFramesPerSecond: mapView.targetFramesPerSecond
        )
    }
}

/// Map content that keeps a ``MapContentAttachment`` attached to the map for as long as the content
/// stays in the content tree.
///
/// ```swift
/// Map {
///     CustomMapContent(attachment: coordinator)
/// }
/// ```
///
/// The attachment is attached exactly once per insertion into the content tree, and detached
/// exactly once on removal. A style reload does not re-attach it: rebuilding style content after a
/// reload is the attachment's own job.
@_spi(Internal)
@_documentation(visibility: internal)
public struct CustomMapContent: MapContent, PrimitiveMapContent {
    let attachment: any MapContentAttachment

    /// Creates content that attaches `attachment` to the map.
    public init(attachment: any MapContentAttachment) {
        self.attachment = attachment
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedAttachment(attachment: attachment))
    }
}
