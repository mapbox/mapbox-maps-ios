public class OfflineSwitch {
    internal var internalOfflineSwitch: MapboxCommon.OfflineSwitch

    public static var shared = {
        return OfflineSwitch()
    }()

    private init() {
        internalOfflineSwitch = MapboxCommon.OfflineSwitch.getInstance()
    }

    public var isMapboxStackConnected: Bool {
        get {
            return internalOfflineSwitch.isMapboxStackConnected()
        }
        set {
            internalOfflineSwitch.setMapboxStackConnectedForConnected(newValue)
        }
    }
}
