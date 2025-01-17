import CoreGraphics
import SwiftUI

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
