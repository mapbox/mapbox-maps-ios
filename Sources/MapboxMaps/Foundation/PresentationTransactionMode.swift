/// Determines if the underlying `CAMetalLayer` rendering output should synchronize with the Core Animation transactions.
///
/// This property controls the `CAMetalLayer.presentsWithTransaction` property, please refer to its documentation.
public enum PresentationTransactionMode: Sendable {
    /// The map render call is synchronized with Core Animation transaction (`presentsWithTransaction = true`).
    ///
    /// Use this option if position a custom View depending on map camera position.
    case sync

    /// The map render call is synchronized with Core Animation transaction (`presentsWithTransaction = false`).
    case async

    /// In automatic mode, the value is calculated dynamically. Meaning, the  ``PresentationTransactionMode/sync`` option is used when there are view annotation on the map. The ``PresentationTransactionMode/async`` is used otherwise.
    case automatic
}

final class MapPresentation {
    var metalView: MetalView? {
        didSet { sync() }
    }

    var mode: PresentationTransactionMode = .automatic {
        didSet { update() }
    }

    var presentsWithTransaction: Bool {
        get { resolved }
        set { mode = newValue ? .sync : .async }
    }

    var displaysAnnotations: Signal<Bool>? {
        didSet {
            token = displaysAnnotations?.skipRepeats().assign(to: \._displaysAnnotations, ofWeak: self)
        }
    }

    private var _displaysAnnotations: Bool = false {
        didSet { update() }
    }

    private var token: AnyCancelable?

    private var resolved: Bool = false {
        didSet { sync() }
    }

    private func sync() {
        if let metalView, metalView.presentsWithTransaction != resolved {
            metalView.presentsWithTransaction = resolved
        }
    }

    private func update() {
        switch mode {
        case .async:
            resolved = false
        case .sync:
            resolved = true
        case .automatic:
            resolved = _displaysAnnotations
        }
    }
}
