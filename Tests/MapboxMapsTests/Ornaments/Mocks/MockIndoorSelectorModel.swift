@testable import MapboxMaps
@_spi(Experimental) import MapboxCoreMaps

final class MockIndoorSelectorModel: IndoorSelectorModelProtocol {
    var floors: [IndoorFloor] = []
    var selectedFloorId: String = ""
    var isHidden: Bool = true
    var onFloorsUpdated: (() -> Void)?
    var onFloorSelected: (() -> Void)?
    var onVisibilityChanged: (() -> Void)?

    private(set) var selectFloorCallArgs: [String] = []
    func selectFloor(_ floorId: String) {
        selectFloorCallArgs.append(floorId)
    }
 }
