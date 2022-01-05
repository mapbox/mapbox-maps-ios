public enum ViewportStatus {
    case state(ViewportState)
    case transition(ViewportTransition, fromState: ViewportState?, toState: ViewportState)
}
