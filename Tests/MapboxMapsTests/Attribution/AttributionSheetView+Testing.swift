@_spi(Restricted) @testable import MapboxMaps
internal import MapboxCommon_Private

extension AttributionSheetView {
    var rowCount: Int { menu.allItems.count }

    var attributionRowCount: Int {
        menu.allItems.filter { $0.id == .copyright }.count
    }

    func item(_ id: AttributionMenuItem.ID) -> AttributionMenuItem? {
        menu.allItems.first { $0.id == id }
    }

    func toggleIsOn(for id: AttributionMenuItem.ID) -> Bool {
        item(id)?.toggle?.wrappedValue ?? false
    }

    func simulateToggle(_ on: Bool, for id: AttributionMenuItem.ID) {
        guard let value = item(id)?.toggle else { return }
        value.wrappedValue = on
    }
}

enum GeofencingConsent {
    static var isGiven: Bool {
        get { __GeofencingUtils.getUserConsent() }
        set { __GeofencingUtils.setUserConsent(isConsentGiven: newValue) { _ in } }
    }
}
