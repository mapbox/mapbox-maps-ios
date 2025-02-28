import os.log

@_spi(Experimental)
extension StyleImport: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedStyleImport(
            id: id ?? node.id.stringId,
            styleData: style.data,
            configuration: style.configuration
        ))
    }
}

struct MountedStyleImport: MapContentMountedComponent {
    let id: String
    let styleData: MapStyle.Data
    let configuration: JSONObject?

    func mount(with context: MapContentNodeContext) throws {
        let importPosition = context.resolveImportPosition()
        os_log(.debug, log: .contentDSL, "style import %s insert %s", id, importPosition.asString())

        switch styleData {
        case .uri(let styleURI):
            try handleExpected {
                context.style.styleManager.addStyleImportFromURI(
                    forImportId: id,
                    uri: styleURI.rawValue,
                    config: configuration?.turfRawValue as? [String: Any],
                    importPosition: importPosition.corePosition)
            }
        case .json(let json):
            try handleExpected {
                context.style.styleManager.addStyleImportFromJSON(
                    forImportId: id,
                    json: json,
                    config: configuration?.turfRawValue as? [String: Any],
                    importPosition: importPosition.corePosition)
            }
        }
    }

    func unmount(with context: MapContentNodeContext) throws {
        os_log(.debug, log: .contentDSL, "remove style import %s", id)

        guard context.style.styleManager.getStyleImports().map(\.id).contains(id) else {
            return
        }

        try handleExpected {
            context.style.styleManager.removeStyleImport(forImportId: id)
        }
    }

    func tryUpdate(from old: MapContentMountedComponent, with context: MapContentNodeContext) throws -> Bool {
        os_log(.debug, log: .contentDSL, "update style import %s", id)

        guard let old = old as? Self, old.id == id else {
            return false
        }

        if styleData != old.styleData {
            switch styleData {
            case .uri(let styleURI):
                try handleExpected {
                    context.style.styleManager.updateStyleImportWithURI(
                        forImportId: id,
                        uri: styleURI.rawValue,
                        config: configuration?.turfRawValue as? [String: Any]
                    )
                }
            case .json(let json):
                try handleExpected {
                    context.style.styleManager.updateStyleImportWithJSON(
                        forImportId: id,
                        json: json,
                        config: configuration?.turfRawValue as? [String: Any]
                    )
                }
            }
        } else if configuration != old.configuration, let config = configuration?.turfRawValue as? [String: Any] {
            try handleExpected {
                context.style.styleManager.setStyleImportConfigPropertiesForImportId(id, configs: config)
            }
        }

        return true
    }

    func updateMetadata(with context: MapContentNodeContext) {
        context.lastImportId = id
    }
}

private extension ImportPosition {
    func asString() -> String {
        (try? toString()) ?? "<nil>"
    }
}
