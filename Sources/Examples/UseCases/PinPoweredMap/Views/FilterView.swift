import SwiftUI

struct FilterView: View {
    @Binding var selectedCategories: [POICategory]
    @Namespace var namespace

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            if #available(iOS 26.0, *) {
#if compiler(>=6.2)
                GlassEffectContainer(spacing: 0) {
                    content
                }
#else
                content
#endif
            } else {
                content
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        HStack(spacing: 0) {
            Group {
                ForEach(POICategory.allCases) { category in
                    toggle(for: category)
                        .font(.system(size: 18, weight: .regular))
                        .padding(.leading, 12)
                }
            }
            .fixedSize()
            .font(.footnote)
        }
        .padding(.trailing, 12)
        .toggleStyle(MyToggleStyle())
    }

    @ViewBuilder
    func toggle(for category: POICategory) -> some View {
        Toggle(
            isOn: Binding<Bool>(
                get: {
                    return selectedCategories.contains(category)
                }, set: { newValue in
                    if newValue {
                        selectedCategories.append(category)
                    } else {
                        selectedCategories.removeAll { $0.id == category.id }
                    }
                }
            )) {
                Label {
                    Text(category.name)
                } icon: {
                    Image(category.icon)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(selectedCategories.contains(category) ? .white : .accentColor)
                        .frame(width: 28, height: 28)
                }
            }
    }
}

struct MyToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        let style = ButtonToggleStyle()
            .makeBody(configuration: configuration)
            .frame(minHeight: 48)
            .foregroundStyle(configuration.isOn ? .white : .primary)

#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            return style
                .glassEffect(.regular.tint(configuration.isOn ? Color(hex: 0x0F38BF) : nil).interactive())
        }
#endif
        return style
            .background(configuration.isOn ? Color(hex: 0x0F38BF) : .white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
