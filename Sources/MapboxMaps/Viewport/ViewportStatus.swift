/// `ViewportStatus` contains 3 cases that express what the ``ViewportManager`` is doing at any given time.
///
/// The ``ViewportStatus/state(_:)`` and ``ViewportStatus/transition(_:toState:)``
/// cases have associated values that are reference types, so equality and hash are implemented in terms of
/// the identities of those objects.
public enum ViewportStatus: Hashable {

    /// The `idle` status indicates that ``ViewportManager`` is inactive.
    case idle

    /// The `state(_:)` status indicates that ``ViewportManager`` is running the associated value `state`.
    case state(_ state: ViewportState)

    /// The `transition(_:toState:)` status indicates that ``ViewportManager`` is running `transition`
    /// and will start running `toState` upon success.
    case transition(_ transition: ViewportTransition, toState: ViewportState)

    /// Compares two `ViewportStatus` values. Returns `true` if and only if they are the same case
    /// and any associated values are identical.
    public static func == (lhs: ViewportStatus, rhs: ViewportStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.state(let lhsState), .state(let rhsState)):
            return lhsState === rhsState
        case (.transition(let lhsTransition, let lhsToState),
              .transition(let rhsTransition, let rhsToState)):
            return (lhsTransition === rhsTransition &&
                    lhsToState === rhsToState)
        default:
            return false
        }
    }

    /// Combines the `ObjectIdentifier` of each associated value into `hasher`.
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .idle:
            return
        case .state(let state):
            hasher.combine(ObjectIdentifier(state))
        case .transition(let transition, let toState):
            hasher.combine(ObjectIdentifier(transition))
            hasher.combine(ObjectIdentifier(toState))
        }
    }
}
