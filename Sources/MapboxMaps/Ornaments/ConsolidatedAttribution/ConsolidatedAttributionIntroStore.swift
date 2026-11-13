import MapboxCommon

/// Remembers whether the expanded intro was shown, for this session and across launches.
final class ConsolidatedAttributionIntroStore {
    static let shared = ConsolidatedAttributionIntroStore(
        settings: SettingsServiceFactory.getInstance(storageType: .persistent)
    )

    static let shownKey = "com.mapbox.maps.consolidatedAttribution.introShown"

    private let settings: SettingsService
    private let key: String
    private var shownInSession = false

    init(settings: SettingsService, key: String = shownKey) {
        self.settings = settings
        self.key = key
    }

    func shouldSkipIntro(_ introExpansion: ConsolidatedAttributionIntroExpansion) -> Bool {
        shownInSession || (introExpansion == .once && wasShownBefore())
    }

    func recordIntroShown() {
        shownInSession = true
        _ = settings.set(key: key, value: true)
    }

    private func wasShownBefore() -> Bool {
        let expected = settings.getForKey(key)
        return expected.isValue() && (expected.value as? Bool ?? false)
    }
}
