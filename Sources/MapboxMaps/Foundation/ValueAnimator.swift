internal protocol ValueAnimatorParticipant: AnyObject {
    /// Is participant running.
    var running: Bool { get set }
}

/// ValueInterpolator takes an input stream of interpolatable values and produces interpolated values on demand.
internal final class ValueInterpolator<Value>: ValueAnimatorParticipant {
    typealias InterpolateFunc = (/*from*/ Value, /*to*/ Value, /*fraction*/ Double) -> Value
    private struct ValueInTime {
        var value: Value
        var date: Date
    }
    private struct State {
        var begin: ValueInTime
        var end: ValueInTime
    }

    private let duration: TimeInterval
    private let input: Signal<Value>
    private let interpolate: InterpolateFunc
    private let nowTimestamp: Ref<Date>

    private var latestValue: Value?
    private var state: State?
    private var token: AnyCancelable?

    var running: Bool = false {
        didSet {
            if running {
                token = input.observe { [weak self] newValue in
                    self?.handle(newValue: newValue)
                }
            } else {
                token = nil
            }
        }
    }

    var currentValue: Value? {
        interpolate(for: nowTimestamp.value)
    }

    init(
        duration: TimeInterval,
        input: Signal<Value>,
        interpolate: @escaping InterpolateFunc,
        nowTimestamp: Ref<Date> = .now
    ) {
        self.duration = duration
        self.input = input
        self.interpolate = interpolate
        self.nowTimestamp = nowTimestamp
    }

    private func handle(newValue: Value) {
        latestValue = newValue
        let now = nowTimestamp.value

        if let value = interpolate(for: now) {
            // calculate new start value via interpolation to current date
            state = State(
                begin: ValueInTime(value: value, date: now),
                end: ValueInTime(value: newValue, date: now + duration))
        } else {
            // first value: initialize state, no interpolation will happen
            // until the next value update
            state = State(
                begin: ValueInTime(value: newValue, date: now - duration),
                end: ValueInTime(value: newValue, date: now))
        }
    }

    private func interpolate(for timestamp: Date) -> Value? {
        guard let state else {
            return nil
        }

        let fraction = timestamp.timeIntervalSince(state.begin.date) / state.end.date.timeIntervalSince(state.begin.date)

        guard fraction < 1 else {
            return state.end.value
        }
        return interpolate(state.begin.value, state.end.value, fraction)
    }
}

/// ValueAnimator uses an input stream of triggering events (usually display link)  to produce interpolated values to the output stream.
///
/// Every value in output stream are calculated via one or more interpolators upon every triggering event.
/// Value animator starts producing values and enables the underlying interpolators only when there are subscribers to it's output.
/// When the last subscriber is gone, the interpolators are stopped and triggered stream is not observed.
internal final class ValueAnimator<Output> {
    var output: Signal<Output> { outputSubject.signal }
    private let outputSubject = SignalSubject<Output>()
    private let trigger: Signal<Void>
    private let participants: [ValueAnimatorParticipant]

    private var token: AnyCancelable?
    private var calculateOutput: () -> Output

    private var running = false {
        didSet {
            // Start participants and triggering stream observing
            // when there are at least one output observer, otherwise stop it.
            if running {
                token = trigger.observe { [weak self] in
                    guard let self else { return }
                    self.outputSubject.send(self.calculateOutput())
                }
            } else {
                token = nil
            }
            participants.forEach { $0.running = running }
        }
    }

    /// Initializes an animator for two different-typed values.
    ///
    /// The resulting output is defined by the `reduce` function.
    convenience init<V1, V2>(
        _ v1: ValueInterpolator<V1>,
        _ v2: ValueInterpolator<V2>,
        trigger: Signal<Void>,
        reduce: @escaping (V1?, V2?) -> Output
    ) {
        self.init(trigger: trigger, participants: [v1, v2]) {
            reduce(v1.currentValue, v2.currentValue)
        }
    }

    private init(trigger: Signal<Void>,
                 participants: [ValueAnimatorParticipant],
                 calculateOutput: @escaping () -> Output) {
        self.trigger = trigger
        self.participants = participants
        self.calculateOutput = calculateOutput
        outputSubject.onObserved = { [weak self] in self?.running = $0 }
    }
}
