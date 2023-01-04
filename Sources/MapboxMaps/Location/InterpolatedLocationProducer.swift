import CoreLocation

internal protocol InterpolatedLocationProducerProtocol: AnyObject {
    var isEnabled: Bool { get set }
    var isHeadingEnabled: Bool { get set }
    var location: InterpolatedLocation? { get }
    func observe(with handler: @escaping (InterpolatedLocation) -> Bool) -> Cancelable
    func addPuckLocationConsumer(_ consumer: PuckLocationConsumer)
    func removePuckLocationConsumer(_ consumer: PuckLocationConsumer)
}

internal struct InterpolatedHeading {
    internal var magneticHeading: CLLocationDirection
    internal var trueHeading: CLLocationDirection
    internal var headingAccuracy: CLLocationDirection

    internal var headingDirection: CLLocationDirection {
        return trueHeading >= 0 ? trueHeading : magneticHeading
    }

    internal init(heading: CLHeading) {
        self.magneticHeading = heading.magneticHeading
        self.trueHeading = heading.trueHeading
        self.headingAccuracy = heading.headingAccuracy
    }

    internal init(magneticHeading: CLLocationDirection, trueHeading: CLLocationDirection, headingAccuracy: CLLocationDirection) {
        self.magneticHeading = magneticHeading
        self.trueHeading = trueHeading
        self.headingAccuracy = headingAccuracy
    }
}

internal final class InterpolatedLocationProducer: NSObject, InterpolatedLocationProducerProtocol {
    private var startDate: Date?
    private var endDate: Date?
    private var startLocation: InterpolatedLocation?
    private var endLocation: InterpolatedLocation?

    private var headingStartDate: Date?
    private var headingEndDate: Date?
    private var startHeading: InterpolatedHeading?
    private var endHeading: InterpolatedHeading?

    private let observableInterpolatedLocation: ObservableInterpolatedLocationProtocol
    private let locationInterpolator: LocationInterpolatorProtocol
    private let headingInterpolator: HeadingInterpolatorProtocol
    private let dateProvider: DateProvider
    private let locationProducer: LocationProducerProtocol

    private let consumers = NSHashTable<PuckLocationConsumer>.weakObjects()
    private var cancelableToken: Cancelable?

    internal var location: InterpolatedLocation? {
        observableInterpolatedLocation.value
    }

    internal var isEnabled: Bool = true {
        didSet {
            syncConsumers()
        }
    }
    internal var isHeadingEnabled: Bool = false {
        didSet {
            if isHeadingEnabled {
                locationProducer.addHeadingConsumer(self)
            } else {
                locationProducer.removeHeadingConsumer(self)
            }
        }
    }

    deinit {
        cancelableToken?.cancel()
    }

    internal init(observableInterpolatedLocation: ObservableInterpolatedLocationProtocol,
                  locationInterpolator: LocationInterpolatorProtocol,
                  headingInterpolator: HeadingInterpolatorProtocol,
                  dateProvider: DateProvider,
                  locationProducer: LocationProducerProtocol,
                  displayLinkCoordinator: DisplayLinkCoordinator) {
        self.observableInterpolatedLocation = observableInterpolatedLocation
        self.locationInterpolator = locationInterpolator
        self.headingInterpolator = headingInterpolator
        self.dateProvider = dateProvider
        self.locationProducer = locationProducer

        super.init()
        observableInterpolatedLocation.onFirstSubscribe = { [weak self, weak displayLinkCoordinator] in
            guard let self = self else { return }
            locationProducer.add(self)
            if self.isHeadingEnabled {
                locationProducer.addHeadingConsumer(self)
            }
            displayLinkCoordinator?.add(self)
        }
        observableInterpolatedLocation.onLastUnsubscribe = { [weak self, weak displayLinkCoordinator] in
            guard let self = self else { return }
            locationProducer.remove(self)
            locationProducer.removeHeadingConsumer(self)
            displayLinkCoordinator?.remove(self)
        }
    }

    // MARK: Puck Location Consumers.

    // delivers the latest location synchronously, if available
    internal func observe(with handler: @escaping (InterpolatedLocation) -> Bool) -> Cancelable {
        return observableInterpolatedLocation.observe(with: handler)
    }

    private var hasPuckLocationConsumers: Bool {
        consumers.count > 0
    }

    internal func addPuckLocationConsumer(_ consumer: PuckLocationConsumer) {
        consumers.add(consumer)
        syncConsumers()
    }

    internal func removePuckLocationConsumer(_ consumer: PuckLocationConsumer) {
        consumers.remove(consumer)
        syncConsumers()
    }

    private func syncConsumers() {
        guard isEnabled, hasPuckLocationConsumers else {
            cancelableToken?.cancel()
            cancelableToken = nil
            return
        }
        guard cancelableToken == nil else { return }

        cancelableToken = observableInterpolatedLocation.observe { [weak self] interpolatedLocation in
            guard let self = self else { return false }

            for puckLocationConsumer in self.consumers.allObjects {
                puckLocationConsumer.puckLocationUpdate(newLocation: interpolatedLocation.location)
            }
            return true
        }
    }

    // MARK: Interpolation.

    private func interpolatedLocation(with date: Date) -> InterpolatedLocation? {
        guard let startDate = startDate,
              let endDate = endDate,
              let startLocation = startLocation,
              let endLocation = endLocation else {
                  return nil
              }
        let fraction = date.timeIntervalSince(startDate) / endDate.timeIntervalSince(startDate)
        guard fraction < 1 else {
            return endLocation
        }
        return locationInterpolator.interpolate(
            from: startLocation,
            to: endLocation,
            fraction: fraction)
    }

    private func interpolatedHeading(with date: Date) -> InterpolatedHeading? {
        guard let startDate = headingStartDate,
              let endDate = headingEndDate,
              let startHeading = startHeading,
              let endHeading = endHeading else {
                  return nil
              }
        let fraction = date.timeIntervalSince(startDate) / endDate.timeIntervalSince(startDate)
        guard fraction < 1 else {
            return endHeading
        }
        return headingInterpolator.interpolate(from: startHeading, to: endHeading, fraction: fraction)
    }
}

extension InterpolatedLocationProducer: LocationConsumer {
    internal func locationUpdate(newLocation: Location) {
        let currentDate = dateProvider.now

        // as a first iteration, assume a 1s location update interval and use a
        // slightly longer interpolation duration to avoid pauses between updates
        let duration: TimeInterval = 1.1

        if let location = interpolatedLocation(with: currentDate) {
            // calculate new start location via interpolation to current date
            startLocation = location
            startDate = currentDate
            endLocation = InterpolatedLocation(location: newLocation)
            endDate = currentDate + duration
        } else {
            // first location: initialize state, no interpolation will happen
            // until the next location update
            startLocation = InterpolatedLocation(location: newLocation)
            startDate = currentDate - duration
            endLocation = startLocation
            endDate = currentDate
        }
    }
}

extension InterpolatedLocationProducer: HeadingConsumer {
    func headingUpdate(newHeading: CLHeading) {
        let currentDate = dateProvider.now

        guard let heading = interpolatedHeading(with: currentDate) else {
            // first heading: initialize state, no interpolation will happen
            // until the next heading update
            startHeading = InterpolatedHeading(heading: newHeading)
            headingStartDate = Date.distantPast
            endHeading = startHeading
            headingEndDate = currentDate
            return
        }

        let finalHeading = InterpolatedHeading(heading: newHeading)

        // This is a suggestion how we can move away from static animation duration for bearing.
        // The issue with the static duration - the speed of the heading change is variable, depending on magnitude of the change.
        //
        // * In case of puck bearing - the default duration of 1100ms makes an impression
        //      that the puck bearing is very sluggish in pretty much all cases.
        // * In case of viewport - the 1100ms duration makes for a pretty good value
        //      as we want camera movements to be smooth and dampened.
        // It seems that we might want to have different animation configurations(durations?) for these two scenarios.
        //
        // The suggestion below calculates the total animation duration from the magitude of heading direction change.
        // This way the speed of bearing change is always constant, regardless whether it's a 300° or 10° change.
        // This makes for pretty snappy(almost instant) puck bearing indicator when direction is changing a little,
        // and quick but still smooth full rotations.
        // The animation speed is based on the previous value of 1100ms for total duration, equalling 3ms per a degree of change.
        // This results in changes up to 5° to be applied during one frame(60 fps), 2.5° per a single 120fps frame.
        let headingDiff: CLLocationDegrees = 180.0 - abs(abs(heading.headingDirection - finalHeading.headingDirection) - 180.0)
        let fullRotationDurationInMs: Float = 1100.0
        let animationSpeedInMs: Float = fullRotationDurationInMs / 360.0 // x ms per degree
        let duration: TimeInterval = (Double(animationSpeedInMs) / 1000.0) * headingDiff

        // calculate new start heading via interpolation to current date
        startHeading = heading
        headingStartDate = currentDate
        endHeading = finalHeading
        headingEndDate = currentDate + duration
    }
}

extension InterpolatedLocationProducer: DisplayLinkParticipant {
    internal func participate() {
        let now = dateProvider.now
        if var location = interpolatedLocation(with: now) {
            if let heading = interpolatedHeading(with: now) {
                location.heading = heading.headingDirection
            }
            observableInterpolatedLocation.notify(with: location)
        }
    }
}
