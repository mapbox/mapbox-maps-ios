import SwiftUI

extension View {
    @ViewBuilder
    func defaultDetents() -> some View {
        presentationDetents([.fraction(0.33), .large])
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
        Self._printChanges()
        return EmptyView()
    }

    func limitPaneWidth() -> some View {
        self.frame(maxWidth: 500)
    }

    /// Forces light-colored navigation bar content (title, back button, status bar) on iOS 26+.
    ///
    /// iOS 18 and below have an opaque nav bar, so the default black title/status bar text is fine.
    /// iOS 26 has a transparent nav bar: over a dark map the black title becomes unreadable, while the
    /// system back button and status bar already adapt to the content underneath. Apply this to
    /// examples whose map background is dark.
    @ViewBuilder
    func applyDarkNavigationBarOniOS26AndAbove() -> some View {
#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            toolbarColorScheme(.dark, for: .navigationBar)
        } else {
            self
        }
#else
        self
#endif
    }
}

extension Font {
    static let safeMonospaced: Font = .system(.footnote, design: .monospaced)
}

extension Color {
    /// Utility helper for visually debug SwiftUI's draw calls.
    ///
    /// Simply add `.background(Color.random)` to see when SwiftUI executes
    /// the body of a view.
    static var random: Color {
        Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
    }
}

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

extension View {
    @ViewBuilder
    func safeGlassEffect(in shape: some Shape = RoundedRectangle(cornerRadius: 14)) -> some View {
#if compiler(>=6.2) && !os(visionOS)
        if #available(iOS 26.0, *) {
            self.glassEffect(in: shape)
        } else {
            self.floating(shape)
        }
#else
        self.floating(shape)
#endif
    }
}

extension View {
    func onChangeOfSize(perform action: @escaping (CGSize) -> Void) -> some View {
        modifier(OnSizeChangeModifier(action: action))
    }
}

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
