import Foundation
import MapboxCoreMaps

/// Options for the following statistics collection behaviors:
/// - Specify the types of sampling: cumulative, per-frame, or both.
/// - Define the minimum elapsed time for collecting performance samples.
@_spi(Experimental)
extension PerformanceStatisticsOptions {
    @_spi(Experimental)
    public struct SamplerOptions: OptionSet, Hashable, Sendable {
        /// Enables the collection of `cumulativeValues`, which are GPU resource statistics.
        public static let cumulative = SamplerOptions(rawValue: 1 << 0)
        /// Enables the collection of `perFrameValues`, which are CPU timeline duration statistics.
        public static let perFrame = SamplerOptions(rawValue: 1 << 1)

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    /// Set of samplers to which define the following types of sampling: cumulative, per-frame, or boths.
    public var samplerOptions: SamplerOptions {
        SamplerOptions(rawValue: __samplerOptions.reduce(0) { $0 + $1.intValue })
    }

    /// Specify the types of sampling: cumulative, per-frame, or both and define the minimum elapsed time for collecting performance samples.
    /// - Note: Setting ``samplingDurationMillis`` to 0 forces the collection of performance statistics every frame., negative sampling duration is an error and results in no operation.
    public convenience init(_ samplerOptions: SamplerOptions, samplingDurationMillis: Double) {
        self.init(__samplerOptions: samplerOptions.core, samplingDurationMillis: samplingDurationMillis)
    }

    /// Specify the types of sampling: cumulative, per-frame, or both.
    ///  - Note: Default minimum elapsed time for collecting performance samples will be used, default is 1000 milliseconds.
    public convenience init(_ samplerOptions: SamplerOptions) {
        self.init(__samplerOptions: samplerOptions.core)
    }
}

extension PerformanceStatisticsOptions.SamplerOptions {
    var core: [NSNumber] {
        var nativeDebugOptions = [CorePerformanceSamplerOptions]()
        if contains(.cumulative) { nativeDebugOptions.append(.cumulativeRenderingStats) }
        if contains(.perFrame) { nativeDebugOptions.append(.perFrameRenderingStats) }
        return nativeDebugOptions.map(\.NSNumber)
    }
}

extension CumulativeRenderingStatistics {
    /// The number of draw calls at the end of the collection window.
    public var drawCalls: UInt? { __drawCalls?.uintValue }

    /// The amount of texture memory in use at the end of the collection window.
    ///  - Note: This value is nil for Metal renderer.
    public var textureBytes: UInt? { __textureBytes?.uintValue }

    /// The amount of vertex memory (array and index buffer memory) in use at the end of the collection window.
    /// - Note: This value is nil for Metal renderer.
    public var vertexBytes: UInt? { __vertexBytes?.uintValue }
}
