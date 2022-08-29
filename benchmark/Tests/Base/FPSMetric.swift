import XCTest
@_spi(Metrics) import MapboxMaps

class FPSMetric: NSObject, XCTMetric {

    let testCase: XCTestCase?
    init(testCase: XCTestCase?) {
        self.testCase = testCase
        super.init()

    }

    private var frameIndex = 0

    private var previousFrameTimestamp: Double!
    private var frameExpectedTimestamp: Double!

    struct MetricRecord: Codable {
        let timestamp: UInt64
        let frameExpectedTimestamp: CFTimeInterval
        let frameActualTimestamp: CFTimeInterval
        let previousFrameActualTimestamp: CFTimeInterval
        let frameIndex: Int
        let drawingDuration: CFTimeInterval?

        var frameDuration: CFTimeInterval {
            frameActualTimestamp - previousFrameActualTimestamp
        }

        var expectedFrameDuration: CFTimeInterval {
            frameExpectedTimestamp - previousFrameActualTimestamp
        }
    }

    var metricRecords: [MetricRecord] = []

    func attach(mapView: MapView) {
        mapView.beforeDrawCallback = { [weak self] _ in
            self?.drawingStartTime = CACurrentMediaTime()
        }
        mapView.afterDrawCallback = { [weak self] _ in
            guard let self = self else { return }

            if let startTime = self.drawingStartTime {
                self.previousFrameDrawingDuration = CACurrentMediaTime() - startTime
            }
        }

        mapView.beforeDisplayLinkCallback = { [weak self] _ in
            guard let self = self else { return }

            self.drawingStartTime = nil
            self.previousFrameDrawingDuration = nil
        }
        mapView.afterDisplayLinkCallback = { [weak self] displayLink in
            self?.displayLinkUpdate(displayLink)
        }
    }

    private var shouldRecordFrames = false

    func willBeginMeasuring() {
        shouldRecordFrames = true
    }

    func didStopMeasuring() {
        shouldRecordFrames = false
        frameIndex = 0
        previousFrameTimestamp = nil
        frameExpectedTimestamp = nil
    }

    var drawingStartTime: CFTimeInterval?
    var previousFrameDrawingDuration: CFTimeInterval?

    func displayLinkUpdate(_ displayLink: CADisplayLink) {
        guard shouldRecordFrames else { return }

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
                                  frameIndex: frameIndex,
                                  drawingDuration: previousFrameDrawingDuration)
        metricRecords.append(record)

        frameIndex += 1
    }

    func addAttachment(_ metrics: ArraySlice<MetricRecord>) {
        guard let testCase = testCase else {
            return
        }

        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(Array(metrics)) else { return }
        let attachment = XCTAttachment(uniformTypeIdentifier: "public.json",
                                       name: "metric_records.json",
                                       payload: data)
        attachment.lifetime = .keepAlways
        testCase.add(attachment)
    }

    func reportMeasurements(from startTime: XCTPerformanceMeasurementTimestamp, to endTime: XCTPerformanceMeasurementTimestamp) throws -> [XCTPerformanceMeasurement] {

        let metrics = filteredRecords(from: startTime, till: endTime)

        addAttachment(metrics)

        let framesCount = metrics.count

        let averageFPSValue = averageFPS(metrics: metrics)
        let p50FPS = percentileFPS(metrics: metrics, value: 0.50)
        let p95FPS = percentileFPS(metrics: metrics, value: 0.95)
        let p99FPS = percentileFPS(metrics: metrics, value: 0.99)
        let p99_9FPS = percentileFPS(metrics: metrics, value: 0.999)
        let numberOfBadFrames = junkFrames(metrics)
        let stdev = standardDeviationFrameDuration(metrics)

        return [
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.fps.average", displayName: "FPS (avg)", value: averageFPSValue, polarity: .prefersLarger),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.fps.p50", displayName: "FPS (p50)", value: p50FPS),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.fps.p95", displayName: "FPS (p95)", value: p95FPS),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.fps.p99", displayName: "FPS (p99)", value: p99FPS),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.fps.p99_9", displayName: "FPS (p99.9)", value: p99_9FPS),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.fps.stdev", displayName: "FPS (stdev)", value: stdev),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.framescount", displayName: "Frames (count)", doubleValue: Double(framesCount ), unitSymbol: ""),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.framescount.junkframes", displayName: "Junk frames", doubleValue: Double(numberOfBadFrames), unitSymbol: ""),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.fps.junkframes_ratio", displayName: "Junk frames (ratio)", doubleValue: Double(numberOfBadFrames) / Double(framesCount) * 100, unitSymbol: "%"),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.drawing.avg", displayName: "Draw (avg)", value: averageDrawingDuration(metrics: metrics))
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

    func averageDrawingDuration(metrics: ArraySlice<MetricRecord>) -> Measurement<Unit> {
        let drawingValues = metrics.compactMap(\.drawingDuration)
        let value = drawingValues.reduce(0, +) / Double(drawingValues.count)
        return Measurement(value: value, unit: UnitDuration.seconds)
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
        let epsilon = 0.0001
        let junkFrames = metrics.filter({ $0.frameDuration - $0.expectedFrameDuration >= epsilon })
        return junkFrames.count
    }

    func standardDeviationFrameDuration(_ data: ArraySlice<MetricRecord>, screen: UIScreen = .main) -> Measurement<Unit> {
        let maxFPS = Double(screen.maximumFramesPerSecond)
        let data = data.map({ min( round(1.0 / $0.frameDuration), maxFPS) })
        let count = Double(data.count)
        let mean = data.reduce(0, +) / count
        let sumOfPowDiffs = data.map({ pow($0 - mean, 2) }).reduce(0, +)

        let value = sqrt(sumOfPowDiffs / count)
        return Measurement(value: value, unit: UnitFrequency.framesPerSecond)
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
