import Foundation
import XCTest

class ThermalStateMetric: NSObject, XCTMetric {
    var peakThermalState = ProcessInfo.processInfo.thermalState

    func willBeginMeasuring() {
        NotificationCenter.default.addObserver(self, selector: #selector(recordThermalState), name: ProcessInfo.thermalStateDidChangeNotification, object: nil)
    }

    func didStopMeasuring() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func recordThermalState() {
        if ProcessInfo.processInfo.thermalState.rawValue > peakThermalState.rawValue {
            peakThermalState = ProcessInfo.processInfo.thermalState
            print("New PEAK thermal state: \(peakThermalState)")
        }
    }

    func reportMeasurements(from startTime: XCTPerformanceMeasurementTimestamp, to endTime: XCTPerformanceMeasurementTimestamp) throws -> [XCTPerformanceMeasurement] {
        return [
            XCTPerformanceMeasurement(identifier: "com.mapbox.metrics.thermal_state", displayName: "Peak thermal state", doubleValue: Double(peakThermalState.rawValue), unitSymbol: " ThermalState", polarity: .prefersSmaller)
        ]
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return ThermalStateMetric()
    }
}
