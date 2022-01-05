public final class ImmediateViewportTransition: ViewportTransition {
    private let mapboxMap: MapboxMapProtocol

    internal init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    public func run(from fromState: ViewportState?,
                    to toState: ViewportState,
                    completion: @escaping (Bool) -> Void) -> Cancelable {
        let resultCancelable = CompositeCancelable()
        var complete = false
        resultCancelable.add(toState.observeDataSource { [mapboxMap] cameraOptions in
            mapboxMap.setCamera(to: cameraOptions)
            completion(true)
            complete = true
            // stop receiving updates
            return false
        })
        // we still have to call the completion block if the transition is canceled
        resultCancelable.add(BlockCancelable {
            if !complete {
                completion(false)
            }
        })
        return resultCancelable
    }
}
