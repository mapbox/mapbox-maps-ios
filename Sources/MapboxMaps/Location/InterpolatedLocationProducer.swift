import CoreLocation

internal protocol InterpolatedLocationProducerProtocol: AnyObject {
    var location: InterpolatedLocation? { get }
    func observe(with handler: @escaping (InterpolatedLocation) -> Bool) -> Cancelable
}

internal final class InterpolatedLocationProducer: NSObject, InterpolatedLocationProducerProtocol {
    private var startDate: Date?
    private var endDate: Date?
    private var startLocation: InterpolatedLocation?
    private var endLocation: InterpolatedLocation?

    private let observableInterpolatedLocation: ObservableInterpolatedLocationProtocol
    private let locationInterpolator: LocationInterpolatorProtocol
    private let dateProvider: DateProvider

    internal var location: InterpolatedLocation? {
        observableInterpolatedLocation.value
    }

    internal init(observableInterpolatedLocation: ObservableInterpolatedLocationProtocol,
                  locationInterpolator: LocationInterpolatorProtocol,
                  dateProvider: DateProvider,
                  locationProducer: LocationProducerProtocol,
                  displayLinkCoordinator: DisplayLinkCoordinator) {
        self.observableInterpolatedLocation = observableInterpolatedLocation
        self.locationInterpolator = locationInterpolator
        self.dateProvider = dateProvider
        super.init()
        locationProducer.add(self)
        displayLinkCoordinator.add(self)
    }

    // delivers the latest location synchronously, if available
    internal func observe(with handler: @escaping (InterpolatedLocation) -> Bool) -> Cancelable {
        return observableInterpolatedLocation.observe(with: handler)
    }

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

extension InterpolatedLocationProducer: DisplayLinkParticipant {
    internal func participate() {
        if let location = interpolatedLocation(with: dateProvider.now) {
            observableInterpolatedLocation.notify(with: location)
        }
    }
}
