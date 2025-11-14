import SwiftUI

struct CirclePinView: View {
    var icon: String
    var active = false

    @State private var scale: CGFloat = 0.0

    var body: some View {
        let size = 35.0
        VStack {
            ZStack {
                let strokeColor: Color = active ? .white : .black
                let backgroundColor: Color = active ?  .black : .white
                Circle()
                    .fill(backgroundColor)
                Circle()
                    .stroke(strokeColor, lineWidth: 1)
                Image(systemName: icon)
                    .renderingMode(.template)
                    .foregroundStyle(strokeColor)
            }
            .shadow(radius: 10)
            .scaleEffect(scale, anchor: .bottom)
            .onAppear {
                withAnimation(Animation.interpolatingSpring(stiffness: 200, damping: 10).delay(0)) {
                    scale = 1.0
                }
            }
            .frame(width: size, height: size)
            .animation(.linear, value: active)
        }
    }
}
