internal protocol ObservableCameraOptionsProtocol: AnyObject {
    func notify(with newValue: CameraOptions)
    func observe(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable
}

// This thin wrapper allows injecting ObservableValue without
// making the injected class generic as well. We won't duplicate
// the ObservableValue tests for this class, so it should always
// remain a simple pass-through — do not add additional logic.
internal final class ObservableCameraOptions: ObservableCameraOptionsProtocol {
    private let observableValue = ObservableValue<CameraOptions>()

    internal func notify(with newValue: CameraOptions) {
        observableValue.notify(with: newValue)
    }

    internal func observe(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        return observableValue.observe(with: handler)
    }
}
