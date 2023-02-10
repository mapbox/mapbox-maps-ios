/// Instance that allows connecting or disconnecting the Mapbox stack to the network.
public class OfflineSwitch {
    internal var internalOfflineSwitch: MapboxCommon.OfflineSwitch

    /// Returns the `OfflineSwitch` shared instance.
    public static var shared = {
        return OfflineSwitch()
    }()

    private init() {
        internalOfflineSwitch = MapboxCommon.OfflineSwitch.getInstance()
    }

    /// Connects or disconnects the Mapbox stack. If set to `false`, current
    /// and new HTTP requests will fail with `HttpRequestError` with type
    /// `.connectionError`.
    public var isMapboxStackConnected: Bool {
        get {
            return internalOfflineSwitch.isMapboxStackConnected()
        }
        set {
            internalOfflineSwitch.setMapboxStackConnectedForConnected(newValue)
        }
    }
}
