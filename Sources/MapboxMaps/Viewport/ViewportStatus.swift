// Uses pointer-based equality and hashing
public enum ViewportStatus: Hashable {
    case idle
    case state(ViewportState)
    case transition(ViewportTransition, toState: ViewportState)

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
