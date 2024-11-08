import Foundation
import SwiftUI
@_spi(Experimental) import MapboxMaps
@_spi(Experimental) import MapboxCommon

/// This is an Example for Experimental API that is subject to change.
@available(iOS 14.0, *)
struct GeofencingPlayground: View {
    @State private var showInfoSheet = false
    @State private var isochrone: Turf.Feature?
    @ObservedObject private var geofencing = Geofencing()
    private var initialLocationProvider = InitialLocationProvider()

    var body: some View {
        MapReader { proxy in
            Map(initialViewport: .camera(center: .apple, zoom: 13)) {
                Puck2D(bearing: .heading)
                if let isochrone {
                    Isochrone(id: "isochrone", feature: isochrone)
                }
            }
            .onMapTapGesture { context in
                fetch(from: .isochrone(coordinate: context.coordinate, contourMinutes: 3)) { newFeature in
                    geofencing.replace(oldFeature: isochrone, with: newFeature)
                    isochrone = newFeature
                }
            }
            .onMapLoaded { _ in geofencing.start() }
            .ignoresSafeArea()
            .safeOverlay(alignment: .trailing) {
                InfoButton(action: { showInfoSheet = true })
                    .padding(.all)
            }
            .safeOverlay(alignment: .bottom) {
                LoggingView(hasUserConsent: geofencing.hasUserConsent, lastEvent: geofencing.lastEvent, isochrone: isochrone)
            }
            .sheet(isPresented: $showInfoSheet) {
                InfoView()
                    .defaultDetents()
            }
        }
    }
}

@available(iOS 14.0, *)
private struct Isochrone: MapStyleContent {
    var id: String
    var feature: Turf.Feature

    var body: some MapStyleContent {
        GeoJSONSource(id: "isochrone-source")
            .data(.feature(feature))

        FillLayer(id: "isochrone-layer", source: "isochrone-source")
            .fillColor(.random)
            .fillOpacity(0.5)
            .fillColorTransition(StyleTransition(duration: 0.5, delay: 0.1))
    }
}

@available(iOS 14.0, *)
private struct LoggingView: View {
    var hasUserConsent: Bool
    var lastEvent: GeofenceEvent?
    var isochrone: Turf.Feature?

    var body: some View {
        VStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                if isochrone == nil {
                    Text("Tap on map to add isochrone for the point.").font(.safeMonospaced)
                }
                if let geofencingEvent = lastEvent {
                    IndicativeLog(color: geofencingEvent.color, text: "Last geofencing event: \(geofencingEvent.type)")
                } else {
                    IndicativeLog(color: .orange, text: "No geofencing events." )
                }

                IndicativeLog(
                    color: hasUserConsent ? .green : .red,
                    text: "Geofencing consent is given - \(hasUserConsent)."
                )
            }
            .floating()

            HStack {
                OvalButton(title: "Enable Pushes", action: requestNotificationPermission)
                OvalButton(title: "Enable Location", action: requestLocationAuthorization)
            }
        }
        .padding(.bottom, 30)
    }
}

@available(iOS 14.0, *)
private struct InfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Dwell event emitted after 1 minute inside.")
                .font(.safeMonospaced)
            Spacer()
            Text("Geofences are stored persistently.")
                .font(.safeMonospaced)
            Spacer()
            Text("Deleting the isochrone programtically doesn't mean exiting from it.")
                .font(.safeMonospaced)
            Spacer()
            Text("To test background functionality you may enable push notifications and hide the app.")
                .font(.safeMonospaced)
            Spacer()
            Text("Easisest way to test location on simulator is to use Apple pre-defined routes.")
                .font(.safeMonospaced)
            Text("Simulator -> Features -> Location -> (Apple, Freeway Drive, City Bicycle Ride).")
                .font(.safeMonospaced)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
    }
}

@available(iOS 14.0, *)
private final class InitialLocationProvider {
    private var cancellables = Set<AnyCancelable>()

    func start(locationManager: LocationManager?, _ onIntialLocation: @escaping (CLLocationCoordinate2D) -> Void) {
        locationManager?.onLocationChange
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] locations in
                guard let location = locations.first else { return print("No locations received") }
                onIntialLocation(location.coordinate)
                self?.cancellables.removeAll()
            }
            .store(in: &cancellables)
    }
}

@available(iOS 14.0, *)
private final class Geofencing: ObservableObject {
    @Published var lastEvent: GeofenceEvent?
    @Published var hasUserConsent: Bool = GeofencingUtils.getUserConsent()

    func start() {
        let geofencing = GeofencingFactory.getOrCreate()
        geofencing.configure(options: GeofencingOptions()) { [weak self] result in
            guard let self else { return }
            /// Geofences are store in database on disk.
            /// To make example isolated and synchronised with UI we try to delete existing feature from database.
            geofencing.clearFeatures { result in
                print("Clear features: \(result)")
                geofencing.addObserver(observer: self) { result in print("Add observer: \(result)") }
            }
        }
    }

    func replace(oldFeature: Turf.Feature?, with newFeature: Turf.Feature?) {
        guard let newFeature else { return }
        let geofencing = GeofencingFactory.getOrCreate()

        if let featureId = oldFeature?.identifier?.string {
            geofencing.removeFeature(identifier: featureId) { result in
                print("Remove feature with id(\(featureId): \(result)")
                geofencing.addFeature(feature: newFeature) { result in print("Add feature \(result)") }
            }
        } else {
            geofencing.addFeature(feature: newFeature) { result in print("Add feature \(result)") }
        }
    }

    func add(feature: Turf.Feature) {
        let geofencing = GeofencingFactory.getOrCreate()
        geofencing.addFeature(feature: feature) { result in print("Add feature: \(result)") }
    }

    func remove(featureId: String) {
        let geofencing = GeofencingFactory.getOrCreate()
        geofencing.removeFeature(identifier: featureId) { result in print("Remove feature with id(\(featureId): \(result)") }
    }

    func reset() {
        GeofencingFactory.reset()
    }
}

private extension GeoJSONSourceData {
    static func isochrone(_ featureCollection: FeatureCollection) -> GeoJSONSourceData {
        .featureCollection(featureCollection)
    }
}

@available(iOS 14.0, *)
extension Geofencing: GeofencingObserver {
    func onEntry(event: GeofencingEvent) {
        DispatchQueue.main.async { self.lastEvent = GeofenceEvent(type: .entry, feature: event.feature) }
    }

    func onDwell(event: GeofencingEvent) {
        DispatchQueue.main.async { self.lastEvent = GeofenceEvent(type: .dwell, feature: event.feature) }
    }

    func onExit(event: GeofencingEvent) {
        DispatchQueue.main.async { self.lastEvent = GeofenceEvent(type: .exit, feature: event.feature) }
    }

    func onUserConsentChanged(isConsentGiven: Bool) {
        DispatchQueue.main.async { self.hasUserConsent = isConsentGiven }
    }

    func onError(error: GeofencingError) {}
}

@available(iOS 14.0, *)
private struct GeofenceEvent {
    enum GeofenceEventType {
        case entry
        case dwell
        case exit
    }

    var type: GeofenceEventType
    var feature: Turf.Feature

    var color: Color {
        switch type {
        case .dwell:
            return .green
        case .exit:
            return .red
        case .entry:
            return .blue
        }
    }
}

private extension URL {
    static func isochrone(
        coordinate: CLLocationCoordinate2D,
        profile: IsochroneProfile = .driving,
        contourMinutes: Int = 10,
        createPolygon: Bool = true
    ) -> URL {
        guard let accessToken = Bundle.main.object(forInfoDictionaryKey: "MBXAccessToken") as? String else {
            fatalError("No access token provided to the Examples app.")
        }

        return URL(string: "https://api.mapbox.com/isochrone/v1/mapbox/\(profile.rawValue)/\(coordinate.longitude)%2C\(coordinate.latitude)?contours_minutes=\(contourMinutes)&polygons=\(createPolygon)&denoise=1&access_token=\(accessToken)")!

    }
}

enum IsochroneProfile: String {
    case driving
    case drivingTraffic = "driving-traffic"
    case walking
    case cycling
}

private func fetch(from isochroneURL: URL, _ completion: @escaping (Turf.Feature?) -> Void) {
    URLSession.shared.dataTask(with: URLRequest(url: isochroneURL)) { data, response, error in
        var feature: Turf.Feature?
        defer { DispatchQueue.main.async { completion(feature) } }
        if let data {
            let featureCollection = try? JSONDecoder().decode(FeatureCollection.self, from: data)
            /// Assuming here that isochrone polygon returned as a single feature, which is not strictly guaranteed.
            feature = featureCollection?.features.first?.enriched()
        }
    }.resume()
}

private func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { success, error in
        print("Notification permission request finished. Success: \(success), error: \(String(describing: error))")
    }
}

private func requestLocationAuthorization() {
    CLLocationManager().requestAlwaysAuthorization()
    print("Location request finished.")
}

private extension Turf.Feature {
    func enriched() -> Turf.Feature {
        var enrichedFeature = Feature(geometry: geometry)
        enrichedFeature = enrichedFeature.properties([GeofencingPropertiesKeys.dwellTimeKey: 1])
        enrichedFeature.identifier = .string("isochrone")
        return enrichedFeature
    }
}

@available(iOS 14.0, *)
struct InfoButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "info.circle")
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .background(Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40))
        }
    }
}

@available(iOS 14.0, *)
struct OvalButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.blue))
        }
    }
}

@available(iOS 14.0, *)
struct IndicativeLog: View {
    var color: Color
    var text: String

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 15, height: 15)
            Text(text).font(.safeMonospaced)
        }
    }
}
