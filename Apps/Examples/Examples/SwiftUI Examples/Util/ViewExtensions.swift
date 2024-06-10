import SwiftUI

@available(iOS 14.0, *)
extension View {
    @ViewBuilder
    func safeOverlay<V: View>(alignment: Alignment, @ViewBuilder content: () -> V) -> some View {
        if #available(iOS 16.0, *) {
            overlay(alignment: alignment, content: content)
        } else {
            overlay(content(), alignment: alignment)
        }
    }

    @ViewBuilder
    func defaultDetents() -> some View {
        if #available(iOS 16, *) {
            presentationDetents([.fraction(0.33), .large])
        }
    }

    @ViewBuilder
    func prominentButton() -> some View {
        if #available(iOS 15, *) {
            buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    func toggleStyleButton() -> some View {
        if #available(iOS 15, *) {
            toggleStyle(.button)
        }
    }

    func debug(_ closure: () -> Void) -> some View {
        closure()
        return self
    }

    /// Utility for printing body changes reasons.
    ///
    /// Example:
    ///
    ///     var body: some View {
    ///         debugPrintChanges()
    ///         Text("Hello world!")
    ///     }
    ///
    /// More info: https://twitter.com/luka_bernardi/status/1402045202714435585
    ///
    func debugPrintChanges() -> some View {
        if #available(iOS 15.0, *) {
            Self._printChanges()
        }
        return EmptyView()
    }

    func limitPaneWidth() -> some View {
        self.frame(maxWidth: 500)
    }
}

@available(iOS 14.0, *)
extension Font {
    static let safeMonospaced: Font = .system(.footnote, design: .monospaced)
}

@available(iOS 13.0, *)
extension Color {
    /// Utility helper for visually debug SwiftUI's draw calls.
    ///
    /// Simply add `.background(Color.random)` to see when SwiftUI executes
    /// the body of a view.
    static var random: Color {
        Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
    }
}

@available(iOS 13.0, *)
extension View {
    func fixedMenuOrder() -> some View {
        if #available(iOS 16.0, *) {
            return self.menuOrder(.fixed)
        } else {
            return AnyView(self)
        }
    }
}

@available(iOS 13.0, *)
extension View {
    func simpleAlert(message: Binding<String?>, title: String = "Alert") -> some View {
        return alert(item: message) { item in
            Alert(title: Text("\(title)"), message: Text("\(item)"))
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}

@available(iOS 13.0, *)
extension View {
    func onChangeOfSize(perform action: @escaping (CGSize) -> Void) -> some View {
        modifier(OnSizeChangeModifier(action: action))
    }
}

@available(iOS 13.0, *)
private struct OnSizeChangeModifier: ViewModifier {
    let action: (CGSize) -> Void

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: action)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
