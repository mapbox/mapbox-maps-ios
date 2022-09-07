import Foundation

internal final class StyleSourceManager {
    private typealias SourceId = String

    internal static func sourcePropertyDefaultValue(for sourceType: String, property: String) -> StylePropertyValue {
        return StyleManager.getStyleSourcePropertyDefaultValue(forSourceType: sourceType, property: property)
    }

    private let styleManager: StyleManagerProtocol
    private let mainQueue: DispatchQueueProtocol
    private let backgroundQueue: DispatchQueueProtocol
    private var workItems = [SourceId: DispatchWorkItem]()

    internal var allSourceIdentifiers: [SourceInfo] {
        return styleManager.getStyleSources().compactMap { info in
            guard let sourceType = SourceType(rawValue: info.type) else {
                Log.error(forMessage: "Failed to create SourceType from \(info.type)", category: "Example")
                return nil
            }
            return SourceInfo(id: info.id, type: sourceType)
        }
    }

    internal init(
        styleManager: StyleManagerProtocol,
        mainQueue: DispatchQueueProtocol = DispatchQueue.main,
        backgroundQueue: DispatchQueueProtocol = DispatchQueue(label: "GeoJSON parsing queue", qos: .userInitiated)
    ) {
        self.styleManager = styleManager
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
    }

    // MARK: - Typed API

    internal func source<T>(withId id: String, type: T.Type) throws -> T where T: Source {
        let sourceProps = try sourceProperties(for: id)
        return try type.init(jsonObject: sourceProps)
    }

    internal func source(withId id: String) throws -> Source {
        // Get the source properties for a given identifier
        let sourceProps = try sourceProperties(for: id)

        guard let typeString = sourceProps["type"] as? String,
              let type = SourceType(rawValue: typeString) else {
            throw TypeConversionError.invalidObject
        }
        return try type.sourceType.init(jsonObject: sourceProps)
    }

    internal func addSource(_ source: Source, id: String) throws {
        if let geoJSONSource = source as? GeoJSONSource {
            try addGeoJSONSource(geoJSONSource, id: id)
        } else {
            try addSourceInternal(source, id: id)
        }
    }

    private func addSourceInternal(_ source: Source, id: String) throws {
        let sourceDictionary = try source.jsonObject(userInfo: [.nonVolatilePropertiesOnly: true])
        try addSource(withId: id, properties: sourceDictionary)

        // volatile properties have to be set after the source has been added to the style
        let volatileProperties = try source.jsonObject(userInfo: [.volatilePropertiesOnly: true])

        try setSourceProperties(for: id, properties: volatileProperties)
    }

    internal func updateGeoJSONSource(withId id: String, geoJSON: GeoJSONObject) throws {
        workItems.removeValue(forKey: id)?
            .cancel()

        guard let sourceInfo = allSourceIdentifiers.first(where: { $0.id == id }),
              sourceInfo.type == .geoJson else {
            fatalError("updateGeoJSONSource: Source with id '\(id)' is not a GeoJSONSource.")
        }
        applyGeoJSONData(data: geoJSON.sourceData, sourceId: id)
    }

    // MARK: - Untyped API

    internal func addSource(withId id: String, properties: [String: Any]) throws {
        try handleExpected {
            return styleManager.addStyleSource(forSourceId: id, properties: properties)
        }
    }

    internal func removeSource(withId id: String) throws {
        workItems.removeValue(forKey: id)?
            .cancel()

        try handleExpected {
            return styleManager.removeStyleSource(forSourceId: id)
        }
    }

    internal func sourceExists(withId id: String) -> Bool {
        return styleManager.styleSourceExists(forSourceId: id)
    }

    internal func sourceProperty(for sourceId: String, property: String) -> StylePropertyValue {
        return styleManager.getStyleSourceProperty(forSourceId: sourceId, property: property)
    }

    internal func sourceProperties(for sourceId: String) throws -> [String: Any] {
        return try handleExpected {
            return styleManager.getStyleSourceProperties(forSourceId: sourceId)
        }
    }

    internal func setSourceProperty(for sourceId: String, property: String, value: Any) throws {
        try handleExpected {
            return styleManager.setStyleSourcePropertyForSourceId(sourceId, property: property, value: value)
        }
    }

    internal func setSourceProperties(for sourceId: String, properties: [String: Any]) throws {
        try handleExpected {
            return styleManager.setStyleSourcePropertiesForSourceId(sourceId, properties: properties)
        }
    }

    // MARK: - Async GeoJSON source data parsing

    private func addGeoJSONSource(_ source: GeoJSONSource, id: String) throws {
        guard let data = source.data else {
            try addSourceInternal(source, id: id)
            return
        }

        if case GeoJSONSourceData.empty = data {
            try addSourceInternal(source, id: id)
            return
        }

        var emptySource = source
        emptySource.data = .empty

        try addSourceInternal(emptySource, id: id)

        applyGeoJSONData(data: data, sourceId: id)
    }

    private func applyGeoJSONData(data: GeoJSONSourceData, sourceId id: String) {
        let item = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            var isCancelled: Bool { self.workItems[id]?.isCancelled ?? true }

            guard !isCancelled else { return }

            do {
                Tracer.beginInterval("GeoJSON->String")
                let json = try data.toString()
                Tracer.endInterval("GeoJSON->String")

                guard !isCancelled else { return }

                self.mainQueue.async { [weak self] in
                    guard let self = self else { return }

                    do {
                        Tracer.beginInterval("Apply String to core")
                        try self.setSourceProperty(for: id, property: "data", value: json)
                        Tracer.endInterval("Apply String to core")
                    } catch {
                        Log.error(forMessage: "Failed to set data for source with id: \(id), error: \(error)")
                    }
                }
            } catch {
                Log.error(forMessage: "\(error) error when converting GeoJSON data for \(id)")
            }
        }

        workItems[id] = item
        backgroundQueue.async(execute: item)
    }
}
