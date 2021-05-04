import Foundation

internal protocol DateProvider {

    // Provides the current date
    var now: Date { get }
}

internal struct DefaultDateProvider: DateProvider {
    var now: Date {
        return Date()
    }
}
