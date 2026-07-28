import UIKit
@_spi(Experimental) import MapboxCoreMaps

protocol IndoorSelectorModelProtocol: AnyObject {
    var floors: [IndoorFloor] { get }
    var selectedFloorId: String? { get }
    var isHidden: Bool { get }
    var onFloorsUpdated: (() -> Void)? { get set }
    var onFloorSelected: (() -> Void)? { get set }
    var onVisibilityChanged: (() -> Void)? { get set }

    func selectFloor(_ floorId: String)
    func clearFloor()
}

final class IndoorSelectorModel: IndoorSelectorModelProtocol {
    private(set) var floors: [IndoorFloor] = []
    private(set) var selectedFloorId: String?
    private(set) var isHidden: Bool = true

    private let indoorManager: IndoorManager
    var onFloorsUpdated: (() -> Void)?
    var onFloorSelected: (() -> Void)?
    var onVisibilityChanged: (() -> Void)?

    private var cancellables = Set<AnyCancelable>()

    init(indoorManager: IndoorManager) {
        self.indoorManager = indoorManager

        indoorManager.onIndoorUpdated.sink { [weak self] state in
            self?.onIndoorUpdated(state)
        }.store(in: &cancellables)
    }

    func selectFloor(_ floorId: String) {
        selectedFloorId = floorId
        indoorManager.selectFloor(selectedFloorId: floorId)
        onFloorSelected?()
    }

    func clearFloor() {
        selectedFloorId = nil
        indoorManager.selectFloor(selectedFloorId: nil)
        onFloorSelected?()
    }

    private func onIndoorUpdated(_ state: IndoorState) {
        let incomingFloorId: String? = state.selectedFloorId.isEmpty ? nil : state.selectedFloorId
        let floorSelectionChanged = selectedFloorId != incomingFloorId
        selectedFloorId = incomingFloorId

        if floors != state.floors {
            floors = state.floors
            onFloorsUpdated?()
        }

        if floorSelectionChanged {
            onFloorSelected?()
        }

        if isHidden != state.floors.isEmpty {
            isHidden = state.floors.isEmpty
            onVisibilityChanged?()
        }
    }
}
