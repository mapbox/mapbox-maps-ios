import SwiftUI

// MARK: - AttributionSheetView

struct AttributionSheetView: View {
    let menu: AttributionMenuContent
    let dismiss: (_ completion: (() -> Void)?) -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(menu.sections, id: \.self) { section in
                    Section {
                        ForEach(section.items, id: \.self) { item in
                            AttributionRow(item: item, open: menu.open, dismiss: dismiss)
                        }
                    } header: {
                        if let title = section.title {
                            Text(title)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(menu.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26.0, visionOS 26.0, *) {
                        Button(role: .close) {
                            dismiss(nil)
                        }.buttonStyle(.plain)
                    } else {
                        Button {
                            dismiss(nil)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .accessibilityLabel(CommonStrings.close)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - AttributionRow

private struct AttributionRow: View {
    let item: AttributionMenuItem
    let open: (URL) -> Void
    let dismiss: (_ completion: (() -> Void)?) -> Void

    var body: some View {
        switch item.kind {
        case .toggle(let value):
            ToggleRow(item: item, value: value, open: open)
        case .link(let url):
            LinkRow(item: item, url: url, open: open, dismiss: dismiss)
        }
    }
}

// MARK: - LinkRow

private struct LinkRow: View {
    let item: AttributionMenuItem
    let url: URL?
    let open: (URL) -> Void
    let dismiss: (_ completion: (() -> Void)?) -> Void

    var body: some View {
        Button {
            guard let url else { return }
            // Open after dismiss, or an in-app opener like SFSafariViewController closes with the sheet.
            dismiss { open(url) }
        } label: {
            HStack {
                let displayTitle = item.id == .copyright ? Attribution.copyrightText(item.title) : item.title
                Text(displayTitle)
                Spacer()
                if url != nil {
                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                }
            }
            .foregroundColor(url != nil ? .accentColor : .primary)
        }
        .disabled(url == nil)
    }
}

// MARK: - ToggleRow

private struct ToggleRow: View {
    let item: AttributionMenuItem
    let value: MutableRef<Bool>
    let open: (URL) -> Void

    @State private var isOn: Bool

    init(item: AttributionMenuItem, value: MutableRef<Bool>, open: @escaping (URL) -> Void) {
        self.item = item
        self.value = value
        self.open = open
        _isOn = State(initialValue: value.wrappedValue)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle(isOn: $isOn) {
                Text(item.title)
            }
            if let message = item.message(forToggleState: isOn) {
                MessageText(message: message, link: item.link, open: open)
                    .font(.footnote)
                    .padding(.top, 2)
            }
        }
        .onChange(of: isOn) { value.wrappedValue = $0 }
    }
}

// MARK: - MessageText

/// Below iOS 15 the whole message is the link.
private struct MessageText: View {
    let message: String
    let link: AttributionMenuItem.Link?
    let open: (URL) -> Void

    var body: some View {
        if #available(iOS 15, *) {
            Text(attributedMessage)
                .foregroundColor(.secondary)
                .environment(\.openURL, OpenURLAction { url in
                    open(url)
                    return .handled
                })
        } else if let link {
            Text("\(message) \(link.title)")
                .foregroundColor(.accentColor)
                .onTapGesture { open(link.url) }
        } else {
            Text(message)
                .foregroundColor(.secondary)
        }
    }

    @available(iOS 15, *)
    private var attributedMessage: AttributedString {
        guard let link else { return AttributedString(message) }
        return (try? AttributedString(markdown: "\(message) [\(link.title)](\(link.url.absoluteString))"))
            ?? AttributedString("\(message) \(link.title)")
    }
}
