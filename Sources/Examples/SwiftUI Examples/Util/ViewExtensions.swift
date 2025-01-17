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
