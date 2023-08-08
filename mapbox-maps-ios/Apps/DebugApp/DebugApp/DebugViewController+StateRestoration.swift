import MapboxMaps
import os

extension DebugViewController {
    func configureStateRestoration(mapView: MapView) {
        guard #available(iOS 13.0, *) else { return }

        restoreControllerStateIfAvailable(mapView: mapView)

        // Skip trigger on state restoration in the next runloop cycle
        DispatchQueue.main.async {
            mapView.mapboxMap.onCameraChanged
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .sink { [weak self] cameraChanged in
                    self?.saveCameraState(cameraChanged.cameraState)
                }.store(in: &self.cancellables)
        }
    }

    func saveCameraState(_ cameraState: CameraState? = nil) {
        guard let cameraState = cameraState ?? mapView?.mapboxMap.cameraState else { return }

        let state = ControllerState(cameraState: cameraState)
        save(controllerState: state)
    }
}

private extension DebugViewController {
    struct ControllerState: Codable {
        let cameraState: CameraState
    }

    var stateRestorationURL: URL {
        let folder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return folder.appendingPathComponent("StateRestoration")
    }

    func loadControllerState() -> ControllerState? {
        guard FileManager.default.fileExists(atPath: stateRestorationURL.path) else { return nil }

        do {
            let data = try Data(contentsOf: stateRestorationURL)
            return try JSONDecoder().decode(ControllerState.self, from: data)
        } catch {
            os_log(.info, "Failed to load state: %@", error.localizedDescription)
        }
        return nil
    }

    func restoreControllerStateIfAvailable(mapView: MapView) {
        guard let state = loadControllerState() else { return }

        mapView.mapboxMap.setCamera(to: CameraOptions(cameraState: state.cameraState))
        os_log("State restored")
    }

    func save(controllerState: ControllerState) {
        do {
            try JSONEncoder().encode(controllerState).write(to: stateRestorationURL)
            os_log("State saved")
        } catch {
            os_log(.info, "Failed to save state: %@", error.localizedDescription)
        }
    }
}
