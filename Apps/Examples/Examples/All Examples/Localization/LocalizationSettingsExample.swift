import Foundation
import MapboxMaps

/// An example to show how to set language and worldview settings with new settings API.
/// When set, the tiles will be loaded in localized language/worldview if the query
/// parameters are supported.
///
/// In order to get localized tiles (the server side localization), create a Setting service instance using SettingsServiceFactory,
/// and set `MapboxCommonSettings.language` or `MapboxCommonSettings.worldview`.
///
/// `SettingsServiceInterface` stores the provided language/worldview as a key:value pair in `UserDefaults`
/// and try to apply it to the tiles. If the values are supported, the localized tiles will be loaded onto the map,
/// otherwise `MapEvents.EventKind.mapLoadingError` event will be emitted.
///
/// The language parameter should be one of the BCP-47 tags and the worldview parameter one of the ISO 3166-1 alpha-2 codes.
///
/// This is currently an opt-in and experimental feature, i.e. some styles could have minor visual changes.
///
/// Previous localization functionality using `Style.localizeLabels(into:forLayerIds:)` will not work with the new settings API.
/// It will be deprecated in the future in order to benefit from more languages and additional worldview support.
/// In case you don't want to use server-side localization and it's already set, it can be removed
/// with `SettingsServiceInterface.erase(key:)`.
final class LocalizationSettingsExample: UIViewController, ExampleProtocol {
    private let supportedLanguages: [String] = [
        "ar",
        "en",
        "es",
        "fr",
        "de",
        "it",
        "pt",
        "ru",
        "zh-Hans",
        "zh-Hant",
        "ja",
        "ko",
        "vi"
    ]
    private let supportedWorldviews: [String] = ["CN", "IN", "JP", "US"]

    private var mapView: MapView!

    lazy var languageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.setTitle("Language: XX", for: .normal)
        button.addTarget(self, action: #selector(languageButtonPressed(_:)), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var worldviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 4
        button.setTitle("Worldview: XX", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.addTarget(self, action: #selector(worldviewButtonPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // Non-persistent storage for demo purposes, in order for the settings to persist choose `.persistent`
    private let settings = SettingsServiceFactory.getInstance(storageType: .nonPersistent)

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.ornaments.options.scaleBar.visibility = .visible

        view.addSubview(mapView)

        // setup buttons to change the language/worldview
        view.addSubview(languageButton)
        view.addSubview(worldviewButton)

        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: worldviewButton.bottomAnchor, constant: 32),
            view.trailingAnchor.constraint(equalTo: languageButton.trailingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: worldviewButton.trailingAnchor, constant: 16),
            worldviewButton.topAnchor.constraint(equalToSystemSpacingBelow: languageButton.bottomAnchor, multiplier: 1),
            worldviewButton.widthAnchor.constraint(equalTo: languageButton.widthAnchor)
        ])

        updateButtonTitles()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

    // MARK: - Private

    /// Update button titles according to current language/worldview settings
    private func updateButtonTitles() {
        var languageButtonTitle = "Language"
        if let language = try? settings.get(key: MapboxCommonSettings.language, type: String.self).get() {
            languageButtonTitle.append(": \(language)")
        }
        var worldviewButtonTitle = "Worldview"
        if let worldview = try? settings.get(key: MapboxCommonSettings.worldview, type: String.self).get() {
            worldviewButtonTitle.append(": \(worldview)")
        }

        languageButton.setTitle(languageButtonTitle, for: .normal)
        worldviewButton.setTitle(worldviewButtonTitle, for: .normal)
    }

    // MARK: - Actions

    @objc private func languageButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Languages",
                                      message: "Please select a language to localize to.",
                                      preferredStyle: .actionSheet)
        let locale = Locale.current
        let settings = settings
        // get the selected language setting(BCP-47 language tag, e.g. "en")
        let selectedLanguage = try? settings.get(key: MapboxCommonSettings.language, type: String.self).get()

        supportedLanguages.map { language -> UIAlertAction in
            let title = locale.localizedString(forIdentifier: language)?
                .appending(language == selectedLanguage ? " ✓" : "")

            return UIAlertAction(title: title, style: .default) { _ in
                do {
                    // set the language setting according to the language selected by the user
                    try settings.set(key: MapboxCommonSettings.language, value: language).get()
                    sender.setTitle("Language: \(language)", for: .normal)
                } catch {
                    print("Failed to set the language, error: \(error.localizedDescription)")
                }
            }
        }.forEach(alert.addAction(_:))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    @objc private func worldviewButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Worldviews",
                                      message: "Please select a worldview filter.",
                                      preferredStyle: .actionSheet)
        let locale = Locale.current
        let settings = settings
        // get the selected worldview setting(ISO 3166-1 alpha-2 code, e.g. "US")
        let selectedWorldview = try? settings.get(key: MapboxCommonSettings.worldview, type: String.self).get()

        supportedWorldviews.map { worldview -> UIAlertAction in
            let title = locale.localizedString(forRegionCode: worldview)?.appending(worldview == selectedWorldview ? " ✓" : "")

            return UIAlertAction(title: title, style: .default) { _ in
                do {
                    // set the worldview setting according to the language selected by the user
                    try settings.set(key: MapboxCommonSettings.worldview, value: worldview).get()
                    sender.setTitle("Worldview: \(worldview)", for: .normal)
                } catch {
                    print("Failed to set the worldview, error: \(error.localizedDescription)")
                }
            }
        }.forEach(alert.addAction(_:))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
}
