import SwiftUI

struct SegmentedToggleView: View {
    @Binding var isToggleOn: Bool
    @Namespace private var namespace

    var body: some View {
        Button {
            withAnimation(.bouncy) {
                isToggleOn.toggle()
            }
        } label: {
            HStack(spacing: 4) {
                Image("lodging")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 20, height: 20)
                    .padding(8)
                    .foregroundColor(isToggleOn ? .white : Color.accentColor)
                    .matchedGeometryEffect(id: true, in: namespace, isSource: true)

                Color(hex: 0xDFE2E8)
                    .frame(width: 1, height: 27)
                    .padding(.horizontal, 4)

                Image("restaurant")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 20, height: 20)
                    .padding(8)
                    .foregroundColor(isToggleOn ? Color.accentColor : .white)
                    .matchedGeometryEffect(id: false, in: namespace, isSource: true)
            }
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: 0x0F38BF))
                    .matchedGeometryEffect(id: isToggleOn, in: namespace, isSource: false)
            }
        }
    }
}
