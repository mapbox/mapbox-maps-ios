import Foundation
import SwiftUI
@_spi(Experimental) import MapboxMaps
@_spi(Experimental) import MapboxCommon

/// This is an Example for Experimental API that is subject to change.
struct GeofencingUserLocation: View {
    @State private var region: CircularRegion?
    @ObservedObject private var geofencing = Geofencing()
    private let initialLocationProvider = InitialLocationProvider()

    var body: some View {
        MapReader { proxy in
            Map(initialViewport: .followPuck(zoom: 13)) {
                Puck2D(bearing: .heading)
                if let region {
                    GeofenceCircle(id: "circle", region: region, event: geofencing.lastEvent)
                }
            }
            .onMapLoaded { _ in startGeofencing(proxy.location) }
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                PermissionView()
            }
        }
    }

    func startGeofencing(_ locationManager: LocationManager?) {
        geofencing.start {
            initialLocationProvider.start(locationManager: locationManager) { initialLocation in
                let _region = CircularRegion(center: Point(initialLocation), radius: .random(in: 200...300))
                var feature = Feature(geometry: _region.center)
                feature.identifier = .string("geofence-source-circle")
                feature = feature.properties([
                    GeofencingPropertiesKeys.dwellTimeKey: 1,
                    GeofencingPropertiesKeys.pointRadiusKey: .number(_region.radius)
                ])
                geofencing.add(feature: feature) {
                    region = _region
                }
            }
        }
    }
}

private struct CircularRegion {
    let center: Turf.Point
    let radius: CLLocationDistance
}

private struct GeofenceCircle: MapStyleContent {
    var id: String
    var region: CircularRegion
    var event: GeofenceEvent?

    var body: some MapStyleContent {
        GeoJSONSource(id: "geofence-source-\(id)")
            .data(.geometry(Polygon(center: region.center.coordinates, radius: region.radius, vertices: 64).geometry))

        FillLayer(id: "geofence-layer-\(id)", source: "geofence-source-\(id)")
            .fillColor(color(for: event))
            .fillOpacity(0.5)
    }

    private func color(for event: GeofenceEvent?) -> UIColor {
        switch event?.type {
        case .none:
            return .yellow
        case .entry:
            return .blue
        case .exit:
            return .red
        case .dwell:
            return .green
        }
    }
}

private struct PermissionView: View {
    var body: some View {
        HStack {
            OvalButton(title: "Enable Pushes") {
                Task {
                    // Request notifications (alert, badge) once via async/await.
                    do {
                        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge])
                        print("Notification permission request finished. Granted: \(granted)")
                    } catch {
                        print("Notification permission request failed with error: \(error)")
                    }
                }
            }
            #if !os(visionOS)
            OvalButton(title: "Enable Location") {
                CLLocationManager().requestAlwaysAuthorization()
            }
            #endif
        }
        .padding(30)
    }
}

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

private final class Geofencing: ObservableObject {
    @Published var lastEvent: GeofenceEvent?

    func start(_ completion: @escaping () -> Void) {
        let geofencing = GeofencingFactory.getOrCreate()
        geofencing.configure(options: GeofencingOptions()) { [weak self] result in
            guard let self else { return }
            /// Geofences are store in database on disk.
            /// To make example isolated and synchronised with UI we try to delete existing feature from database.
            geofencing.clearFeatures { result in
                print("Clear features: \(result)")
                geofencing.addObserver(observer: self) { result in print("Add observer: \(result)") }
                completion()
            }
        }
    }

    func add(feature: Turf.Feature, onSuccess: @escaping () -> Void) {
        let geofencing = GeofencingFactory.getOrCreate()
        geofencing.addFeature(feature: feature) { result in
            print("Add feature result: \(result)")
            if case .success = result { onSuccess() }
        }
    }

    func remove(featureId: String, completion: @escaping () -> Void) {
        let geofencing = GeofencingFactory.getOrCreate()
        geofencing.removeFeature(identifier: featureId) { result in
            print("Remove feature result: \(result)")
            completion()
        }
    }
}

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

    func onError(error: GeofencingError) {}
    func onUserConsentChanged(isConsentGiven: Bool) {}
}

private struct GeofenceEvent {
    enum GeofenceEventType {
        case entry
        case dwell
        case exit
    }

    var type: GeofenceEventType
    var feature: Turf.Feature
}
