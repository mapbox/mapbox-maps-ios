import XCTest
@_spi(Metrics) import MapboxMaps

class FPSMetric: NSObject, XCTMetric, MapViewMetricsReporter {
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
        let displayLinkProcessDuration: CFTimeInterval?

        var frameDuration: CFTimeInterval {
            frameActualTimestamp - previousFrameActualTimestamp
        }

        var expectedFrameDuration: CFTimeInterval {
            frameExpectedTimestamp - previousFrameActualTimestamp
        }
    }

    var metricRecords: [MetricRecord] = []

    var displayLinkCallbackStarted: CFTimeInterval?
    var previousDisplayLinkProcessDuration: CFTimeInterval?

    var drawingStartTime: CFTimeInterval?
    var previousFrameDrawingDuration: CFTimeInterval?

    func beforeDisplayLinkCallback(displayLink: CADisplayLink) {
        displayLinkCallbackStarted = CACurrentMediaTime()
        drawingStartTime = nil
        previousFrameDrawingDuration = nil
    }

    func afterDisplayLinkCallback(displayLink: CADisplayLink) {
        if let displayLinkCallbackStarted = displayLinkCallbackStarted {
            previousDisplayLinkProcessDuration = CACurrentMediaTime() - displayLinkCallbackStarted
        }
        self.displayLinkUpdate(displayLink)
    }

    func beforeMetalViewDrawCallback(metalView: MTKView?) {
        drawingStartTime = CACurrentMediaTime()
    }

    func afterMetalViewDrawCallback(metalView: MTKView?) {
        if let drawingStartTime = self.drawingStartTime {
            self.previousFrameDrawingDuration = CACurrentMediaTime() - drawingStartTime
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
                                  drawingDuration: previousFrameDrawingDuration,
                                  displayLinkProcessDuration: previousDisplayLinkProcessDuration)
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

        return fpsStatsData(for: metrics) + jankFramesMeasurements(metrics) +
        statsData(for: metrics.compactMap(\.drawingDuration), measurementId: "com.mapbox.metrics.drawing", displayName: "Draw", unit: UnitDuration.seconds, polarity: .prefersSmaller) +
        statsData(for: metrics.compactMap(\.displayLinkProcessDuration), measurementId: "com.mapbox.metrics.displaylink", displayName: "DisplayLink", unit: UnitDuration.seconds, polarity: .prefersSmaller)
    }

    func fpsStatsData(for metrics: ArraySlice<MetricRecord>, screen: UIScreen = .main) -> [XCTPerformanceMeasurement] {
        return statsData(for: metrics.map(\.frameDuration),
                         measurementId: "com.mapbox.metrics.fps",
                         displayName: "FPS",
                         unit: UnitFrequency.framesPerSecond,
                         polarity: .prefersLarger) { frameDurationValue in
            return frameDurationValue.map({ min(1.0 / $0, Double(screen.maximumFramesPerSecond)) })
        }
    }

    func jankFramesMeasurements(_ metrics: ArraySlice<MetricRecord>) -> [XCTPerformanceMeasurement] {
        let framesCount = metrics.count
        let numberOfBadFrames = jankFrames(metrics)

        return [
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.framescount", displayName: "Frames (count)", doubleValue: Double(framesCount ), unitSymbol: ""),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.framescount.jankframes", displayName: "Jank frames", doubleValue: Double(numberOfBadFrames), unitSymbol: ""),
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.fps.jankframes_ratio", displayName: "Jank frames (ratio)", doubleValue: Double(numberOfBadFrames) / Double(framesCount) * 100, unitSymbol: "%"),
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

    func statsData(for data: [Double], measurementId: String, displayName: String, unit: Unit, polarity: XCTPerformanceMeasurement.Polarity, convertMeasurementValue: ((Double?) -> Double?)? = nil) -> [XCTPerformanceMeasurement] {
        func convert(_ input: Double) -> Double? {
            if let convertMeasurementValue = convertMeasurementValue {
                return convertMeasurementValue(input)
            } else {
                return input
            }
        }

        let sortedData = data.sorted()

        // Calculate default percentiles
        var measurements = [0.5, 0.95, 0.99, 0.999].compactMap { percentile -> XCTPerformanceMeasurement? in
            guard let value = self.percentile(sortedData, percentile: percentile, presorted: true),
                  let measurementValue = convert(value) else { return nil }

            let percentileString = String(format: "%g", locale: Locale(identifier: "en_us_posix"), percentile*100)
                .replacingOccurrences(of: ".", with: "_")

            let identifier = "\(measurementId).p\(percentileString)"
            let displayName = "\(displayName) (p\(percentileString))"
            let measurement = Measurement(value: measurementValue, unit: unit)
            return XCTPerformanceMeasurement(identifier: identifier, displayName: displayName, value: measurement, polarity: polarity)
        }

        // Calculate AVERAGE value
        let average = data.reduce(0, +) / Double(data.count)
        if let convertedAverageValue = convert(average) {
            let averageMeasurement = XCTPerformanceMeasurement(identifier: "\(measurementId).average",
                                                               displayName: "\(displayName) (AVG)",
                                                               value: Measurement(value: convertedAverageValue, unit: unit),
                                                               polarity: polarity)
            measurements.append(averageMeasurement)

        }


        // Calculate STDEV
        let deviationValue = stdev(data)
        if let convertedSTDEV = convert(deviationValue) {
            measurements.append(XCTPerformanceMeasurement(identifier: "\(measurementId).stdev",
                                                          displayName: "\(displayName) (STDEV)",
                                                          value: Measurement(value: convertedSTDEV, unit: unit),
                                                          polarity: polarity))
        }

        return measurements
    }

    func percentileFPS(metrics: ArraySlice<MetricRecord>, value: Double, screen: UIScreen = .main) -> Measurement<Unit> {
        let maximumFPSValue = Double(screen.maximumFramesPerSecond)
        let value = percentile(metrics.map(\.frameDuration), percentile: value) ?? 0
        let fpsValue = 1.0 / value
        return Measurement(value: min(fpsValue, maximumFPSValue), unit: UnitFrequency.framesPerSecond)
    }

    func percentile(_ data: [Double], percentile probability: Double, presorted: Bool = false) -> Double? {
        func qDef(_ data: [Double], k: Int, probability: Double) -> Double? {
          if data.isEmpty { return nil }
          if k < 1 { return data[0] }
          if k >= data.count { return data.last }
          return ((1.0 - probability) * data[k - 1]) + (probability * data[k])
        }

        let data = presorted ? data : data.sorted(by: <)
        let count = Double(data.count)
        let m = 1.0 - probability
        let k = Int((probability * count) + m)
        let probability = (probability * count) + m - Double(k)
        return qDef(data, k: k, probability: probability)
    }

    func stdev(_ data: [Double]) -> Double {
        let mean = data.reduce(0, +) / Double(data.count)
        let sumOfPowDiffs = data.map({ pow($0 - mean, 2) }).reduce(0, +)

        return sqrt(sumOfPowDiffs / Double(data.count))
    }

    func jankFrames(_ metrics: ArraySlice<MetricRecord>, screen: UIScreen = .main) -> Int {
        let epsilon = 0.0001
        let jankFrames = metrics.filter({ $0.frameDuration - $0.expectedFrameDuration >= epsilon })
        return jankFrames.map({ record in
            let numberOfSkippedFrames = record.frameDuration / record.expectedFrameDuration
            return Int(ceil(numberOfSkippedFrames))

        }).reduce(0, +)
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}

extension FPSMetric: Metric {
    func commandDidFinishExecuting(_ command: AsyncCommand) {
        if let command = command as? CreateMapCommand, let mapView = command.mapView {
            mapView.metricsReporter = self
        }
    }
}
