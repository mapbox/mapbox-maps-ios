#if !os(visionOS)
import CoreLocation

// On iOS 18+, Always authorization is only effective while a session holds it, and a
// session only lives as long as the process. Without it, geofences stop once the app
// is terminated.
final class AlwaysLocationSession {
    static let shared = AlwaysLocationSession()

    private let locationManager = CLLocationManager()
    private var session: AnyObject?

    // Prompts if Always isn't granted yet.
    func requestAlwaysAuthorization() {
        if #available(iOS 18.0, *) {
            createSession()
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }

    // Called on every launch, including background launches. Never prompts.
    func resumeIfAuthorizedAlways() {
        guard #available(iOS 18.0, *), locationManager.authorizationStatus == .authorizedAlways else {
            return
        }
        createSession()
    }

    @available(iOS 18.0, *)
    private func createSession() {
        if session == nil {
            session = CLServiceSession(authorization: .always)
        }
    }
}
#endif
