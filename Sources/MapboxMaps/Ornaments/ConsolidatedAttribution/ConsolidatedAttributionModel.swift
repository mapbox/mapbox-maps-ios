import Foundation

final class ConsolidatedAttributionModel {
    enum State {
        case pending
        case expanded(collapseTimer: TimerProtocol)
        case collapsed
    }

    private(set) var state: State = .pending {
        didSet {
            if case .expanded(let timer) = oldValue {
                timer.invalidate()
            }
            let expandedChanged = oldValue.isExpanded != state.isExpanded
            if expandedChanged {
                updateMapInteractionObservation()
            }
            // A disabled pill is hidden, so it doesn't animate.
            onStateChange?(expandedChanged && options != nil)
        }
    }

    var attributionText: String = "" {
        didSet {
            guard attributionText != oldValue else { return }
            update()
        }
    }

    /// `nil` while the pill is disabled.
    var options: ConsolidatedAttributionOptions? {
        didSet {
            guard options != oldValue else { return }
            onAppearanceChange?()
            update()
        }
    }

    var isExpanded: Bool { state.isExpanded }

    var onStateChange: ((_ animated: Bool) -> Void)?
    var onAppearanceChange: (() -> Void)?
    var onTap: (() -> Void)?

    private let introStore: ConsolidatedAttributionIntroStore
    private let onMapInteraction: Signal<Void>
    private let timerProvider: TimerProviderProtocol
    private var mapInteractionCancellable: AnyCancelable?

    /// - Parameter onMapInteraction: map touches outside the pill. Collapse the intro.
    init(
        introStore: ConsolidatedAttributionIntroStore,
        onMapInteraction: Signal<Void>,
        timerProvider: TimerProviderProtocol = TimerProvider()
    ) {
        self.introStore = introStore
        self.onMapInteraction = onMapInteraction
        self.timerProvider = timerProvider
    }

    deinit {
        if case .expanded(let timer) = state {
            timer.invalidate()
        }
    }

    /// The expanded form is a one-time intro, so a tap also collapses it.
    func handleTap() {
        onTap?()
        collapse()
    }

    private func update() {
        switch state {
        // Empty text must not use up the one-time intro.
        case .pending where options != nil && !attributionText.isEmpty:
            state = startIntro()
        case .expanded where options == nil:
            state = .collapsed
        case .pending, .expanded, .collapsed:
            onStateChange?(false)
        }
    }

    private func startIntro() -> State {
        guard let options, !introStore.shouldSkipIntro(options.introExpansion) else {
            return .collapsed
        }
        introStore.recordIntroShown()
        let timer = timerProvider.makeScheduledTimer(timeInterval: Self.collapseDelay, repeats: false) { [weak self] _ in
            self?.collapse()
        }
        return .expanded(collapseTimer: timer)
    }

    private func collapse() {
        guard isExpanded else { return }
        state = .collapsed
    }

    private func updateMapInteractionObservation() {
        guard isExpanded else {
            // Runs inside the gesture handler. Cancelling now frees the target the recognizer
            // is still calling, so wait for it to finish.
            DispatchQueue.main.async { [weak self] in
                self?.mapInteractionCancellable = nil
            }
            return
        }
        mapInteractionCancellable = onMapInteraction.observe { [weak self] in
            self?.collapse()
        }
    }

    static let collapseDelay: TimeInterval = 5.0
}

private extension ConsolidatedAttributionModel.State {
    var isExpanded: Bool {
        if case .expanded = self { return true }
        return false
    }
}
