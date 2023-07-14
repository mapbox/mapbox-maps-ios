import MapboxCommon

extension HeadingProvider {
    /// Converts provider to a signal. The resulting signal retains the provider.
    func toSignal() -> Signal<Heading> {
        Signal { [self] handler in
            if let latestHeading {
                handler(latestHeading)
            }
            let observer = ObjectWrapper(subject: handler)
            self.add(headingObserver: observer)
            return AnyCancelable {
                self.remove(headingObserver: observer)
            }
        }
    }
}

extension ObjectWrapper: HeadingObserver where T == (Heading) -> Void {
    func onHeadingUpdate(_ heading: Heading) {
        subject(heading)
    }
}

extension LocationProvider {
    /// Converts provider to a signal. The resulting signal retains the provider.
    func toSignal() -> Signal<[Location]> {
        Signal { [self] handler in
            handler(self.getLastObservedLocation().asArray)
            let observer = SignalLocationObserver(closure: handler)
            self.addLocationObserver(for: observer)
            return AnyCancelable {
                self.removeLocationObserver(for: observer)
            }
        }
    }
}

private final class SignalLocationObserver: LocationObserver {
    let closure: ([Location]) -> Void

    init(closure: @escaping ([Location]) -> Void) {
        self.closure = closure
    }

    func onLocationUpdateReceived(for locations: [Location]) {
        closure(locations)
    }
}
