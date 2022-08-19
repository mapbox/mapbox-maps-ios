import XCTest

class FPSMetric: NSObject, XCTMetric {
    private var displayLink: CADisplayLink!

    override init() {
        super.init()
        displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(displayLinkUpdate(_:)))!
        displayLink.isPaused = true
        displayLink.add(to: .main, forMode: .common)
    }

    private var frameIndex = 0

    private var previousFrameTimestamp: Double!
    private var frameExpectedTimestamp: Double!

    struct MetricRecord {
        let timestamp: UInt64
        let frameExpectedTimestamp: CFTimeInterval
        let frameActualTimestamp: CFTimeInterval
        let previousFrameActualTimestamp: CFTimeInterval
        let frameIndex: Int

        var frameDuration: CFTimeInterval {
            frameActualTimestamp - previousFrameActualTimestamp
        }

        var expectedFrameDuration: CFTimeInterval {
            frameExpectedTimestamp - previousFrameActualTimestamp
        }
    }

    var metricRecords: [MetricRecord] = []

    func willBeginMeasuring() {
        print("Beginning measuring with framesCount = \(frameIndex)")
        displayLink.isPaused = false
    }

    func didStopMeasuring() {
        displayLink.isPaused = true
        print("Did stop measuring with framesCount = \(frameIndex)")
        frameIndex = 0
        previousFrameTimestamp = nil
        frameExpectedTimestamp = nil
    }

    @objc
    func displayLinkUpdate(_ displayLink: CADisplayLink) {
        defer {
            self.frameExpectedTimestamp = displayLink.targetTimestamp
            self.previousFrameTimestamp = displayLink.timestamp
        }

        guard let previousFrameTimestamp = previousFrameTimestamp,
            let frameExpectedTimestamp = frameExpectedTimestamp else {
            return
        }

        let record = MetricRecord(timestamp: mach_absolute_time(),
                                  frameExpectedTimestamp: frameExpectedTimestamp,
                                  frameActualTimestamp: displayLink.timestamp,
                                  previousFrameActualTimestamp: previousFrameTimestamp,
                                  frameIndex: frameIndex)
        metricRecords.append(record)

        frameIndex += 1
    }

    var measuringIndex = 0
    func reportMeasurements(from startTime: XCTPerformanceMeasurementTimestamp, to endTime: XCTPerformanceMeasurementTimestamp) throws -> [XCTPerformanceMeasurement] {
        print("Request start time: \(startTime.date) till \(endTime.date)")

        let metrics = filteredRecords(from: startTime, till: endTime)

        let framesCount = metrics.count

        let averageFPSValue = averageFPS(metrics: metrics)
        let p50FPS = percentileFPS(metrics: metrics, value: 0.50)
        let p95FPS = percentileFPS(metrics: metrics, value: 0.95)
        let p99FPS = percentileFPS(metrics: metrics, value: 0.99)
        let p99_9FPS = percentileFPS(metrics: metrics, value: 0.999)
        let numberOfBadFrames = junkFrames(metrics)
        

        return [
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.fps.average", displayName: "FPS (avg)", value: averageFPSValue, polarity: .prefersLarger),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.fps.p50", displayName: "FPS (p50)", value: p50FPS),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.fps.p95", displayName: "FPS (p95)", value: p95FPS),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.fps.p99", displayName: "FPS (p99)", value: p99FPS),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.fps.p99_9", displayName: "FPS (p99.9)", value: p99_9FPS),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.framescount", displayName: "Frames (count)", doubleValue: Double(framesCount ), unitSymbol: ""),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.fps.junkframes", displayName: "Junk frames", doubleValue: Double(numberOfBadFrames), unitSymbol: ""),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.fps.junkframes_ratio", displayName: "Junk frames (ratio)", doubleValue: Double(numberOfBadFrames) / Double(framesCount) * 100, unitSymbol: "%"),
        ]
    }

    func filteredRecords(from: XCTPerformanceMeasurementTimestamp, till: XCTPerformanceMeasurementTimestamp) -> ArraySlice<MetricRecord> {
        let leftIndex = metricRecords.firstIndex { record in
            record.timestamp >= from.absoluteTime
        }
        let rightResultIndex = metricRecords.firstIndex { record in
            record.timestamp >= till.absoluteTime
        }

        guard let leftIndex = leftIndex else { return [] }
        let rightIndex = rightResultIndex ?? metricRecords.endIndex

        return metricRecords[leftIndex..<rightIndex]
    }

    func averageFPS(metrics: ArraySlice<MetricRecord>, screen: UIScreen = .main) -> Measurement<Unit> {
        let totalTime = metrics.map(\.frameDuration).reduce(0, +)
        let averageFrameTime = totalTime / Double(metrics.count)
        let fpsValue = 1.0 / averageFrameTime
        return Measurement(value: min(fpsValue, Double(screen.maximumFramesPerSecond)), unit: UnitFrequency.framesPerSecond)
    }

    func percentileFPS(metrics: ArraySlice<MetricRecord>, value: Double, screen: UIScreen = .main) -> Measurement<Unit> {
        let maximumFPSValue = Double(screen.maximumFramesPerSecond)
        let value = percentile(metrics.map(\.frameDuration), percentile: value) ?? 0
        let fpsValue = 1.0 / value
        return Measurement(value: min(fpsValue, maximumFPSValue), unit: UnitFrequency.framesPerSecond)
    }

    func percentile(_ data: [Double], percentile probability: Double) -> Double? {
        func qDef(_ data: [Double], k: Int, probability: Double) -> Double? {
          if data.isEmpty { return nil }
          if k < 1 { return data[0] }
          if k >= data.count { return data.last }
          return ((1.0 - probability) * data[k - 1]) + (probability * data[k])
        }

        let data = data.sorted(by: <)
        let count = Double(data.count)
        let m = 1.0 - probability
        let k = Int((probability * count) + m)
        let probability = (probability * count) + m - Double(k)
        return qDef(data, k: k, probability: probability)
    }

    func junkFrames(_ metrics: ArraySlice<MetricRecord>, screen: UIScreen = .main) -> Int {
        // Acceptable error margin is half (or less) of a frame duration
        let epsilon = 1.0 / Double(screen.maximumFramesPerSecond) / 2
        let junkFrames = metrics.filter({ $0.frameDuration - $0.expectedFrameDuration >= epsilon })
        return junkFrames.count
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
