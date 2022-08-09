import Foundation
import QuartzCore

internal protocol DateProvider {

    // Provides the current date
    var now: Date { get }
}

internal protocol TimeProvider {
    // Provides the current time
    var current: TimeInterval { get }
}

internal struct DefaultDateProvider: DateProvider {
    var now: Date {
        return Date()
    }
}

internal struct DefaultTimeProvider: TimeProvider {
    var current: TimeInterval {
        return CACurrentMediaTime()
    }
}
