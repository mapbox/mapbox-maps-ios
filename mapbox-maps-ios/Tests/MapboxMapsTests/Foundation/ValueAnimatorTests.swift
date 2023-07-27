@testable import MapboxMaps
import XCTest

final class ValueAnimatorTests: XCTestCase {
    func testTwoValuesAnimation() {
        var triggerObserved = [Bool]()
        var input1Observed = [Bool]()
        var input2Observed = [Bool]()

        let trigger = SignalSubject<Void>()
        let input1 = SignalSubject<Double>()
        let input2 = SignalSubject<Int>()

        trigger.onObserved = { triggerObserved.append($0) }
        input1.onObserved = { input1Observed.append($0) }
        input2.onObserved = { input2Observed.append($0) }

        struct Result: Equatable {
            var d: Double?
            var i: Int?
        }

        let step0 = Date(timeIntervalSince1970: 0)
        let step1 = Date(timeIntervalSince1970: 2)
        let step2 = Date(timeIntervalSince1970: 4)
        let step3 = Date(timeIntervalSince1970: 6)
        let step4 = Date(timeIntervalSince1970: 8)
        let step5 = Date(timeIntervalSince1970: 30)
        @MutableRef var now = step0

        let duration1: TimeInterval = 5
        let duration2: TimeInterval = 10
        let interpolator1 = ValueInterpolator(duration: duration1,
                                              input: input1.signal,
                                              interpolate: interpolateD(from:to:frac:),
                                              nowTimestamp: $now)

        let interpolator2 = ValueInterpolator(duration: duration2,
                                              input: input2.signal,
                                              interpolate: interpolateI(from:to:frac:),
                                              nowTimestamp: $now)
        let animator = ValueAnimator(
            interpolator1,
            interpolator2,
            trigger: trigger.signal,
            reduce: Result.init(d:i:))

        // initially inputs are not observed
        XCTAssertEqual(triggerObserved, [])
        XCTAssertEqual(input1Observed, [])
        XCTAssertEqual(input2Observed, [])

        var outputs = [Result]()
        let token = animator.output.observe { outputs.append($0) }

        // inputs are observed
        XCTAssertEqual(triggerObserved, [true])
        XCTAssertEqual(input1Observed, [true])
        XCTAssertEqual(input2Observed, [true])

        XCTAssertEqual(outputs, [], "no outputs initially")

        // frame 1
        trigger.send()
        XCTAssertEqual(outputs, [Result()], "nil output, no values from inputs")

        // frame 2
        trigger.send()
        XCTAssertEqual(outputs, [Result(), Result()], "nil output, no values from inputs")

        // send values 1
        input1.send(0)
        input2.send(0)

        XCTAssertEqual(outputs, [Result(), Result()], "inputs don't trigger outputs")

        // clear
        outputs.removeAll()

        // frame 3
        trigger.send()
        XCTAssertEqual(outputs, [Result(d: 0, i: 0)])

        // frame 4
        now = step1
        trigger.send()
        XCTAssertEqual(outputs, [Result(d: 0, i: 0), Result(d: 0, i: 0)])
        outputs.removeAll()

        // send values 2
        now = step1
        input1.send(100)
        input2.send(200)
        XCTAssertEqual(outputs, [], "no updates without trigger")

        outputs.removeAll()

        // frame 5, first interpolated values
        now = step2
        var currentDuration = step2.timeIntervalSince(step1)
        var value1 = interpolateD(from: 0, to: 100, frac: currentDuration / duration1)
        var value2 = interpolateI(from: 0, to: 200, frac: currentDuration / duration2)
        trigger.send()
        XCTAssertEqual(outputs, [Result(d: value1, i: value2)])
        outputs.removeAll()

        // send values 2
        now = step3
        input1.send(200)
        input2.send(400)

        currentDuration = step3.timeIntervalSince(step1)
        value1 = interpolateD(from: 0, to: 100, frac: currentDuration / duration1)
        value2 = interpolateI(from: 0, to: 200, frac: currentDuration / duration2)
        XCTAssertEqual(outputs, [], "no update without trigger")

        outputs.removeAll()

        // frame 6
        now = step4
        currentDuration = now.timeIntervalSince(step3)
        value1 = interpolateD(from: value1, to: 200, frac: currentDuration / duration1)
        value2 = interpolateI(from: value2, to: 400, frac: currentDuration / duration2)
        trigger.send()
        XCTAssertEqual(outputs, [Result(d: value1, i: value2)])
        outputs.removeAll()

        // frame 7, end state, overtime
        now = step5
        trigger.send()
        XCTAssertEqual(outputs, [Result(d: 200, i: 400)])
        outputs.removeAll()

        token.cancel()

        XCTAssertEqual(triggerObserved, [true, false])
        XCTAssertEqual(input1Observed, [true, false])
        XCTAssertEqual(input2Observed, [true, false])

        var outputs2 = [Result]()
        let token2 = animator.output.observe { outputs2.append($0) }
        trigger.send()
        XCTAssertEqual(outputs2, [Result(d: 200, i: 400)])

        XCTAssertEqual(triggerObserved, [true, false, true])
        XCTAssertEqual(input1Observed, [true, false, true])
        XCTAssertEqual(input2Observed, [true, false, true])

        token2.cancel()

        XCTAssertEqual(triggerObserved, [true, false, true, false])
        XCTAssertEqual(input1Observed, [true, false, true, false])
        XCTAssertEqual(input2Observed, [true, false, true, false])
    }
}

private func interpolateD(from: Double, to: Double, frac: Double) -> Double {
    from + (to - from) * frac
}

private func interpolateI(from: Int, to: Int, frac: Double) -> Int {
    from + Int(Double(to - from) * frac)
}
