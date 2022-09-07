import Foundation
import os

internal enum Tracer {
    static func beginInterval(_ name: StaticString) {
        if #available(iOS 12.0, *) {
            SignpostTracer.default.beginInterval(name)
        }
    }

    static func endInterval(_ name: StaticString) {
        if #available(iOS 12.0, *) {
            SignpostTracer.default.endInterval(name)
        }
    }
}

@available(iOS 12.0, *)
internal final class SignpostTracer {
    fileprivate static let `default` = SignpostTracer(log: OSLog(subsystem: "Aaaa", category: "Performance Logging"))

    private let log: OSLog
    let signpostID: OSSignpostID

    internal init(log: OSLog) {
        self.log = log
        self.signpostID = OSSignpostID(log: log)
    }

    internal func beginInterval(_ name: StaticString) {
        os_signpost(.begin, log: log, name: name, signpostID: signpostID)
    }

    internal func endInterval(_ name: StaticString) {
        os_signpost(.end, log: log, name: name, signpostID: signpostID)
    }
}
