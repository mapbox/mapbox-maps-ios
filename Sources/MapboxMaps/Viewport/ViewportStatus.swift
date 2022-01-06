// Uses pointer-based equality and hashing
public enum ViewportStatus: Hashable {
    case state(ViewportState?)
    case transition(ViewportTransition, fromState: ViewportState?, toState: ViewportState)

    public static func == (lhs: ViewportStatus, rhs: ViewportStatus) -> Bool {
        switch (lhs, rhs) {
        case (.state(let lhsState), .state(let rhsState)):
            return lhsState === rhsState
        case (.transition(let lhsTransition, let lhsFromState, let lhsToState),
              .transition(let rhsTransition, let rhsFromState, let rhsToState)):
            return (lhsTransition === rhsTransition &&
                    lhsFromState === rhsFromState &&
                    lhsToState === rhsToState)
        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .state(let state):
            if let state = state {
                hasher.combine(ObjectIdentifier(state))
            }
        case .transition(let transition, let fromState, let toState):
            hasher.combine(ObjectIdentifier(transition))
            if let fromState = fromState {
                hasher.combine(ObjectIdentifier(fromState))
            }
            hasher.combine(ObjectIdentifier(toState))
        }
    }
}
