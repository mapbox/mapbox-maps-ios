import SwiftUI

@available(iOS 14.0, *)
struct MapFloatingButtonStyle: ButtonStyle {
    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let opacity = configuration.isPressed ? 0.8 : 1
        configuration.label
            .frame(width: 50, height: 50)
            .floating(Circle())
            .animation(.easeIn, value: opacity)
            .opacity(opacity)
    }
}

@available(iOS 14.0, *)
struct FloatingStyle <S: Shape>: ViewModifier {
    var shape: S
    func body(content: Content) -> some View {
        content
            .background(Color(UIColor.systemBackground))
            .clipShape(shape)
            .shadow(radius: 1.4, y: 0.7)
            .padding(5)
    }
}

@available(iOS 14.0, *)
extension View {
    func floating<S>(_ shape: S) -> some View where S : Shape  {
        modifier(FloatingStyle(shape: shape))
    }
}
