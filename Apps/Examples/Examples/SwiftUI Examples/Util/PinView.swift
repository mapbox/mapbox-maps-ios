import SwiftUI

@available(iOS 13.0, *)
struct PinView: View {
    var text: String
    var type: String?

    @State private var scale: CGFloat = 0.0

    var body: some View {
        let size = 35.0
        VStack {
            ZStack {
                let gradient = switch type {
                case "hotel": [Color.red, Color.blue]
                case "university": [Color(UIColor.brown), Color(UIColor.brown)]
                case "park": [Color(UIColor.systemGreen), Color(UIColor.systemGreen)]
                case "restaurant": [Color(UIColor.systemOrange), Color(UIColor.systemOrange)]
                default: [Color.red, Color.blue]
                }
                PinShape()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: gradient),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                PinShape()
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            }
            .shadow(radius: 10)
            .scaleEffect(scale, anchor: .bottom)
            .onAppear {
                withAnimation(Animation.interpolatingSpring(stiffness: 200, damping: 10).delay(0)) {
                    scale = 1.0
                }
            }
            .frame(width: size, height: size * 3 / 2)
            .padding(.bottom, 3)
            Text(text)
                .foregroundColor(Color.red)
                .font(.system(size: 13.5).bold())
                .shadow(color: .white, radius: 0, x: 0.5, y: 0.5)
                .shadow(color: .white, radius: 0, x: -0.5, y: 0.5)
                .shadow(color: .white, radius: 0, x: 0.5, y: -0.5)
                .shadow(color: .white, radius: 0, x: -0.5, y: -0.5)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 130)
        }
    }

    private struct PinShape: Shape {
        var hole: Bool = true

        func path(in rect: CGRect) -> Path {
            var path = Path()
            let circleRadius = rect.width / 2
            let circleCenter = CGPoint(x: rect.midX, y: circleRadius)
            let bottomPoint = CGPoint(x: rect.midX, y: rect.height)

            let angle = Double.pi / 4

            let startPoint = CGPoint(x: circleRadius +  circleRadius*cos(angle), y: circleRadius + circleRadius * sin(angle))
            path.move(to: startPoint)
            path.addArc(center: circleCenter, radius: circleRadius, startAngle: .radians(.pi / 4), endAngle: .radians(.pi * 5 / -4), clockwise: true)
            path.addLine(to: bottomPoint)
            path.addLine(to: startPoint)

            // inner circle
            let holeRadius = circleRadius / 3 // Adjust the hole size as needed
            let holeCenter = CGPoint(x: rect.midX, y: circleRadius)
            path.addEllipse(in: CGRect(x: holeCenter.x - holeRadius, y: holeCenter.y - holeRadius, width: holeRadius * 2, height: holeRadius * 2))

            return path
        }
    }
}
