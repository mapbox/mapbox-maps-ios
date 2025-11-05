import SwiftUI
@_spi(Internal) import MapboxMaps

enum StyleOverrideDestination: Hashable {
    case create
    case edit(id: UUID)
}

struct ClearableTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never
    var focused: FocusState<Bool>.Binding?
    var onSubmit: (() -> Void)?

    var body: some View {
        HStack {
            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(5, reservesSpace: false)
                .monospaced()
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .autocorrectionDisabled()
                .textInputAutocapitalization(autocapitalization)
                .focused(focused ?? FocusState<Bool>().projectedValue)
                .onSubmit {
                    onSubmit?()
                }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct ExamplesSettingsView: View {
    @EnvironmentObject private var overridesModel: StyleOverridesModel
    @State private var destination: StyleOverrideDestination?

    var body: some View {
        NavigationStack {
            List {
                Section("Maps SDK") {
                    ViewThatFits {
                        // Try horizontal layout first
                        HStack {
                            Text("Version")
                            Spacer()
                            Text(Bundle.mapboxMapsMetadata.version)
                                .foregroundColor(.secondary)
                        }

                        // Fall back to vertical layout if horizontal doesn't fit
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Version")
                            Text(Bundle.mapboxMapsMetadata.version)
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                Section {
                    ForEach(overridesModel.overrides) { override in
                        NavigationLink(value: StyleOverrideDestination.edit(id: override.id)) {
                            StyleOverideView(override: override)
                        }
                    }
                    .onDelete(perform: deleteOverrides)

                    NavigationLink(value: StyleOverrideDestination.create) {
                        Text("Create New")
                    }
                } header: {
                    Text("Style overrides")
                } footer: {
                    Text("""
                        Override any Style URI used by examples app to a custom one.
                        After changing this setting, an example need to be reopened to take effect.
                        """)
                }
            }
            .navigationTitle("Settings")
            .navigationDestination(for: StyleOverrideDestination.self) { destination in
                switch destination {
                case .create:
                    StyleOverrideEditView(edit: nil, onSave: { override in
                        overridesModel.save(override: override)
                    })
                case .edit(let id):
                    if let override = overridesModel.overrides.first(where: { $0.id == id }) {
                        StyleOverrideEditView(
                            edit: override, onSave: { updatedOverride in
                            overridesModel.save(override: updatedOverride)
                        }, onDelete: {
                            overridesModel.remove(with: id)
                        })
                    }
                }
            }
        }
    }

    private func deleteOverrides(offsets: IndexSet) {
        overridesModel.overrides.remove(atOffsets: offsets)
    }
}

struct StyleOverideView: View {
    var override: StyleOverride
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Group {
                if override.active {
                    Text("Active").foregroundColor(.green)
                } else {
                    Text("Disabled").foregroundColor(.red)
                }
            }
            .font(.caption.bold())
            .opacity(0.8)

            Group {
                Text(override.baseStyle.rawValue)
                    .monospaced()
                    .font(.caption)
                Image(systemName: "arrow.down")
                    .resizable()
                    .frame(width: 10, height: 10)
                Text(override.asText)
                    .monospaced()
                    .font(.caption)
            }
            .opacity(override.active ? 1.0 : 0.5)
        }
    }
}

struct StyleChooserView: View {
    @EnvironmentObject var model: StyleOverridesModel
    @Environment(\.dismiss) private var dismiss
    @State private var customURL: String
    @FocusState private var isTextFieldFocused: Bool
    let title: String
    let suggestPreviouselyUsedUris: Bool
    let onSelect: (String) -> Void

    typealias Suggestion = (name: String?, uri: String)

    // Predefined style URLs
    private let predefinedStyles: [Suggestion] = [
        ("Standard", "mapbox://styles/mapbox/standard"),
        ("Standard Satellite", "mapbox://styles/mapbox/standard-satellite"),
        ("Streets", "mapbox://styles/mapbox/streets-v12"),
        ("Outdoors", "mapbox://styles/mapbox/outdoors-v12"),
    ]

    private var suggestions: [Suggestion] {
        var res = [Suggestion]()
        if suggestPreviouselyUsedUris {
            let previouslyUsedURIs = model.previouslyUsedURIs.map { ($0.key, $0.value) }
                .sorted(by: { $0.1 < $1.1 })
                .map { uri, _ in
                    let predifinedName = predefinedStyles.first(where: { $0.uri == uri })?.name
                    return Suggestion(name: predifinedName, uri: uri)
                }
            res += previouslyUsedURIs
        }

        for style in predefinedStyles {
            if res.contains(where: { $0.uri == style.uri }) { continue }
            res.append(style)
        }

        return res
    }

    init(title: String, initialURL: String, suggestPreviouselyUsedUris: Bool = false, onSelect: @escaping (String) -> Void) {
        self.title = title
        self.onSelect = onSelect
        self.suggestPreviouselyUsedUris = suggestPreviouselyUsedUris
        _customURL = State(initialValue: initialURL)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Style URI") {
                    ClearableTextField(
                        placeholder: "mapbox://styles/...",
                        text: $customURL,
                        keyboardType: .URL,
                        focused: $isTextFieldFocused,
                        onSubmit: saveAndDismiss
                    )
                }

                Section {
                    ForEach(suggestions, id: \.uri) { suggestion in
                        Button {
                            customURL = suggestion.uri
                        }
                        label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    if let name = suggestion.name {
                                        Text(name)
                                            .foregroundColor(.primary)
                                        Text(suggestion.uri)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .monospaced()

                                    } else {
                                        Text(suggestion.uri)
                                            .foregroundColor(.primary)
                                            .monospaced()
                                    }
                                }
                                Spacer()
                                if customURL == suggestion.uri {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isTextFieldFocused = true
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAndDismiss()
                    }
                    .disabled(customURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveAndDismiss() {
        onSelect(customURL)
        dismiss()
    }
}

struct StyleOverrideEditView: View {
    @Environment(\.dismiss) private var dismiss

    var edit: StyleOverride?
    let onSave: (StyleOverride) -> Void
    let onDelete: (() -> Void)?
    @State var baseStyle = ""
    @State var style = ""
    @State var options: [ConfigOption] = []
    @State var active = true
    @State private var showingBaseStyleChooser = false
    @State private var showingReplacementStyleChooser = false
    @State private var showingConfigEditor = false
    @State private var editingConfigKey: String?

    init(edit: StyleOverride?, onSave: @escaping (StyleOverride) -> Void, onDelete: (() -> Void)? = nil) {
        self.edit = edit
        self.onSave = onSave
        self.onDelete = onDelete
    }

    private var overrideToSave: StyleOverride? {
        guard let baseStyleURI = StyleURI(rawValue: baseStyle) else {
            return nil
        }
        guard let styleURI = StyleURI(rawValue: style) else {
            return nil
        }
        return StyleOverride(
            id: edit?.id ?? UUID(),
            baseStyle: baseStyleURI,
            style: styleURI,
            options: options,
            active: active
        )
    }

    private var navigationTitle: String { edit != nil ? "Edit Override" : "New Override" }

    private func setupInitialValues() {
        if let edit {
            baseStyle = edit.baseStyle.rawValue
            style = edit.style.rawValue
            options = edit.options
            active = edit.active
        }
    }

    var body: some View {
        Form {
            Section {
                Button {
                    showingBaseStyleChooser = true
                } label: {
                    if !baseStyle.isEmpty {
                        Text(baseStyle)
                            .monospaced()
                    } else {
                        Text("Select...")
                    }
                }
            } header: {
                Text("Base style")
            } footer: {
                Text("This style will be replaced.")
            }
            Section {
                Button {
                    showingReplacementStyleChooser = true
                } label: {
                    if !style.isEmpty {
                        Text(style)
                            .monospaced()
                    } else {
                        Text("Select...")
                    }
                }
            } header: {
                Text("Replacement style")
            } footer: {
                Text("This style will be used instead.")
            }

            Section {
                ForEach(options) { keyValue in
                    Button {
                        editingConfigKey = keyValue.key
                        showingConfigEditor = true
                    } label: {
                        HStack( spacing: 2) {
                            Text(keyValue.key)
                                .foregroundColor(.primary)
                                .monospaced()
                            Spacer()
                            Text(keyValue.value.asText)
                                .foregroundColor(.secondary)
                                .monospaced()
                        }
                    }
                }
                .onDelete { indexSet in
                    options.remove(atOffsets: indexSet)
                }

                Button {
                    editingConfigKey = nil
                    showingConfigEditor = true
                } label: {
                    Text("Add")
                }
            } header: {
                Text("Import configs")
            } footer: {
                Text("Add default import configs to the replacement style. If example itself modifies this config property, it will take prececedence over the override.")
            }

            if edit != nil {
                Section {
                    Toggle("Active", isOn: $active)

                    if let onDelete {
                        Button {
                            onDelete()
                            dismiss()
                        } label: {
                            Text("Delete")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if let overrideToSave {
                        onSave(overrideToSave)
                        dismiss()
                    }
                }
                .disabled(overrideToSave == nil)
            }
        }
        .sheet(isPresented: $showingBaseStyleChooser) {
            StyleChooserView(title: "Base Style", initialURL: baseStyle) { selectedURL in
                baseStyle = selectedURL
            }
        }
        .sheet(isPresented: $showingReplacementStyleChooser) {
            StyleChooserView(title: "Replacement Style", initialURL: style, suggestPreviouselyUsedUris: true) { selectedURL in
                style = selectedURL
            }
        }
        .sheet(isPresented: $showingConfigEditor) {
            ConfigOptionEditView(
                edit: editingConfigKey != nil ? options.first { $0.key == editingConfigKey } : nil,
                existingKeys: Set(options.map { $0.key })
            ) { keyValue in
                if let editingKey = editingConfigKey {
                    if let index = options.firstIndex(where: { $0.key == editingKey }) {
                        if editingKey != keyValue.key {
                            options.remove(at: index)
                            options.append(keyValue)
                        } else {
                            options[index] = keyValue
                        }
                    }
                } else {
                    options.append(keyValue)
                }
            }
        }
        .onAppear {
            setupInitialValues()
        }
    }

}

struct ConfigOptionEditView: View {
    @Environment(\.dismiss) private var dismiss

    let edit: ConfigOption?
    let existingKeys: Set<String>
    let onSave: (ConfigOption) -> Void

    @State private var key: String = ""
    @State private var valueText: String = ""
    @FocusState private var isKeyFocused: Bool
    @FocusState private var isValueFocused: Bool

    private var isEditingExisting: Bool { edit != nil }

    private var navigationTitle: String {
        isEditingExisting ? "Edit Config Option" : "New Config Option"
    }

    private var canSave: Bool {
        guard let optionToSave else { return false }
        return !optionToSave.key.isEmpty &&
            (isEditingExisting || !existingKeys.contains(optionToSave.key))
    }

    private var optionToSave: ConfigOption? {
        let value: JSONValue
        let trimmed = valueText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return nil
        }

        if trimmed.lowercased() == "true" {
            value = .boolean(true)
        } else if trimmed.lowercased() == "false" {
            value = .boolean(false)
        } else if let doubleValue = Double(trimmed) {
            value = .number(doubleValue)
        } else {
            value = .string(trimmed)
        }

        return ConfigOption(key: key.trimmingCharacters(in: .whitespacesAndNewlines), value: value)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Key") {
                    ClearableTextField(
                        placeholder: "Enter key name",
                        text: $key,
                        focused: $isKeyFocused
                    )
                    .disabled(isEditingExisting)

                    let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !isEditingExisting && existingKeys.contains(trimmedKey) && !trimmedKey.isEmpty {
                        Text("Key \(trimmedKey) already exists")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    } else if trimmedKey.isEmpty {
                        Text("Key is required")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Value") {
                    ClearableTextField(
                        placeholder: "Enter value",
                        text: $valueText,
                        focused: $isValueFocused
                    )

                    let desc = """
                        Use number, string, or  "true"/"false" for boolean.
                        """
                    Text(desc)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let optionToSave {
                            onSave(optionToSave)
                            dismiss()
                        }
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                setupInitialValues()
                if !isEditingExisting {
                    isKeyFocused = true
                } else {
                    isValueFocused = true
                }
            }
        }
    }

    private func setupInitialValues() {
        guard let edit else { return }
        key = edit.key
        valueText = edit.value.asText
    }
}
