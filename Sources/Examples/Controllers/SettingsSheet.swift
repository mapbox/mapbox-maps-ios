import SwiftUI

/// A reusable SwiftUI-based bottom sheet for displaying map settings
struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let sections: [SettingsSection]

    var body: some View {
        NavigationView {
            Form {
                ForEach(sections) { section in
                    Section {
                        ForEach(section.controls) { control in
                            control.view
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 5))
                        }
                    } header: {
                        HStack {
                            Text(section.title)
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(.primary)
                                .textCase(nil)
                            Spacer()
                        }
                        .padding(.leading, 8)
                        .listRowInsets(EdgeInsets())
                    }
                    .listSectionSeparator(.hidden)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Settings Data Model

struct SettingsSection: Identifiable {
    let id = UUID()
    let title: String
    var controls: [SettingsControl]
}

struct SettingsControl: Identifiable {
    let id = UUID()
    let view: AnyView

    /// Create a segmented picker control for multiple options
    static func segmentedPicker(
        title: String,
        options: [String],
        selection: Binding<Int>
    ) -> SettingsControl {
        SettingsControl(view: AnyView(
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Picker(title, selection: selection) {
                    ForEach(0..<options.count, id: \.self) { index in
                        Text(options[index]).tag(index)
                    }
                }
                .pickerStyle(.segmented)
            }
        ))
    }

    /// Create a boolean toggle control (On/Off)
    static func toggle(
        title: String,
        isOn: Binding<Bool>
    ) -> SettingsControl {
        SettingsControl(view: AnyView(
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Picker(title, selection: isOn) {
                    Text("On").tag(true)
                    Text("Off").tag(false)
                }
                .pickerStyle(.segmented)
            }
        ))
    }

    /// Create a documentation link
    static func link(
        title: String,
        url: URL
    ) -> SettingsControl {
        SettingsControl(view: AnyView(
            Link(destination: url) {
                HStack(spacing: 6) {
                    Image(systemName: "link")
                        .font(.system(size: 13))
                    Text(title)
                        .font(.system(size: 13))
                    Spacer()
                }
                .foregroundColor(.secondary)
            }
        ))
    }
}
