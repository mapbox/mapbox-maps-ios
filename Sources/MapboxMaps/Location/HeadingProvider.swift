/// Listens to ``HeadingProvider``'s updates.
public protocol HeadingObserver: AnyObject {
    func onHeadingUpdate(_ heading: Heading)
}

/// Provides heading data to drive the location puck.
public protocol HeadingProvider {
    /// Latest observed heading.
    var latestHeading: Heading? { get }

    /// Adds heading observer.
    func add(headingObserver: HeadingObserver)

    /// Removes heading observer.
    func remove(headingObserver: HeadingObserver)
}
