import SwiftUI
@_spi(Experimental) import MapboxMaps

struct ColorThemeExample: View {
    enum Theme: String {
        case `default`
        case red
        case monochrome
    }

    @State private var theme: Theme = .red
    @State private var panelHeight: CGFloat = 0

    var body: some View {
        Map(initialViewport: .camera(center: .init(latitude: 40.72, longitude: -73.99), zoom: 11, pitch: 45)) {
            switch theme {
            case .default:
                EmptyMapContent()
            case .red:
                ColorTheme(base64: redTheme)
            case .monochrome:
                ColorTheme(uiimage: monochromeTheme)
            }

            /// Defines a custom layer and source to draw the border line.
            NYNJBorder()
        }
        .mapStyle(.streets) /// In standard style it's possible to provide custom theme using `.standard(themeData: "base64String")`
        .additionalSafeAreaInsets(.bottom, panelHeight)
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            VStack(alignment: .center) {
                Group {
                    HStack {
                        ColorButton(color: .white, isOn: Binding(get: { theme == .default }, set: { _, _ in theme = .default }))
                        ColorButton(color: .red, isOn: Binding(get: { theme == .red }, set: { _, _ in theme = .red }))
                        ColorButton(color: .secondaryLabel, isOn: Binding(get: { theme == .monochrome }, set: { _, _ in theme = .monochrome }))
                    }
                }
                .floating()
            }
            .padding(.bottom, 30)
        }
    }
}

private struct ColorButton: View {
    let color1: UIColor
    let color2: UIColor
    let isOn: Binding<Bool>

    init(color: UIColor, isOn: Binding<Bool>) {
        self.color1 = color
        self.color2 = color
        self.isOn = isOn
    }

    init(color1: UIColor, color2: UIColor, isOn: Binding<Bool>) {
        self.color1 = color1
        self.color2 = color2
        self.isOn = isOn
    }

    var body: some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(color1), Color(color2)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Circle().strokeBorder(Color(color1.darker), lineWidth: 2)
            }
        }
        .opacity(isOn.wrappedValue ? 1.0 : 0.2)
        .frame(width: 50, height: 50)
    }
}

private struct NYNJBorder: MapContent {
    var body: some MapContent {
        GeoJSONSource(id: "border")
            .data(.geometry(.lineString(LineString([
                CLLocationCoordinate2D(latitude: 40.913503418907936, longitude: -73.91912400100642),
                CLLocationCoordinate2D(latitude: 40.82943110786286, longitude: -73.9615887363045),
                CLLocationCoordinate2D(latitude: 40.75461056309348, longitude: -74.01409059085539),
                CLLocationCoordinate2D(latitude: 40.69522028220487, longitude: -74.02798814058939),
                CLLocationCoordinate2D(latitude: 40.65188756398558, longitude: -74.05655532615407),
                CLLocationCoordinate2D(latitude: 40.64339339389301, longitude: -74.13916853846217),
            ]))))

        LineLayer(id: "border", source: "border")
            .lineColor(.orange)
            .lineWidth(8)
            .slot(.bottom)
    }
}

private let styleURL = Bundle.main.url(forResource: "fragment-realestate-NY", withExtension: "json")!
private let monochromeTheme = UIImage(named: "monochrome_lut")!
private let redTheme = "iVBORw0KGgoAAAANSUhEUgAABAAAAAAgCAYAAACM/gqmAAAAAXNSR0IArs4c6QAABSFJREFUeF7t3cFO40AQAFHnBv//wSAEEgmJPeUDsid5h9VqtcMiZsfdPdXVzmVZlo+3ZVm+fr3//L7257Lm778x+prL1ff0/b//H+z/4/M4OkuP/n70Nc7f+nnb+yzb//sY6vxt5xXPn+dP/aH+GsXJekb25izxR/ypZ6ucUefv9g4z2jPP3/HPHwAAgABAABgACIACkAAsAL1SD4yKWQAUAHUBdAG8buKNYoYL8PEX4FcHQAAAAAAAAAAAAAAAAAAAAAAA8LAeGF1mABAABAABQACQbZP7+hk5AwACAAAAAAAAAAAAAAAAAAAAAAAA4EE9AICMx4QBAAAAAAAANgvJsxGQV1dA/PxmMEtxU9YoABQACoC5CgDxX/wvsb2sEf/Ff/Ff/N96l5n73+/5YAB4CeBqx2VvMqXgUfD2npkzBCAXEBeQcrkoa5x/FxAXEBcQF5A2Wy3/t32qNYr8I//Mln+MABgBMAJgBMAIgBEAIwBGAIwAGAEwAmAE4K4eAGCNQIw+qQ0AmQ+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB/6gEABAB5RgACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAN/UAAPKcAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgEFNODICRtDkDO/gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOhvlPUWem+h9xKQ+V4CUt9wO6KZnn/Pv+ff8z/bW5DFP59CUnJbWSP+iX/iX78znqED/urxnwHAAGAAMAAYAAwABgADgAHAAGAAMAAYAAwABgADoNMcHUAdQAQcAUfAe8xEwH0O86t3IPz8OvClu17WqD/UH+oP9cf1Gdia01d/LQsDgAHAAGAAMAAYAAwABgADgAHAAGAAMAAYAAwABkCnSQwABgACj8Aj8D1mItAMAB1wHfDS3S5r5F/5V/6Vf3XAW12h/mIArHY89iZTAAQA2XtmBKAWqOslyf4rgBXACmAFcIur8k/bJ/mnQTr5V/6Vf+fKv0YAjAAYATACYATACIARACMARgCMABgBMAJgBMAIgBEAIwCdZuiA64AjwAgwAtxjpg6cDlztLlLA7/Pr1gueyr56/jx/5ZzUNeof9Y/6R/0zk4HGAGAAMAAYAAwABgADgAHAAGAAMAAYAAwABgADgAHQaQ4DgAGAgCPgCHiPmTqQOpC1u8gAYACMjAf5V/6Vf+XfmTrQ8l97v8Z/5X8GAAOAAcAAYAAwABgADAAGAAOAAcAAYAAwABgADIBO0xgADAAdCB0IHYgeMxkADAAdkGM7IPbf/pfuWlmj/lH/qH/UPzMZGAwABgADgAHAAGAAMAAYAAwABgADgAHAAGAAMAAYAJ3mMAAYAAg4Ao6A95jJAGAA6EDrQJfuclkj/8q/8q/8O1MHWv47Nv8xABgADAAGAAOAAcAAYAAwABgADAAGAAOAAcAAYAB0msYAYADoQOhA6ED0mMkAYADogBzbAbH/9r/YFWWN+kf9o/5R/8xkYDAAGAAMAAYAA4ABwABgADAAGAAMAAYAA4ABwABgAHSawwBgACDgCDgC3mMmA4ABoAOtA126y2WN/Cv/yr/y70wdaPnv2PzHAGAAMAAYAAwABgADgAHAAGAAMAAYAAwABgADgAHQaRoDgAGgA6EDoQPRYyYDgAGgA3JsB8T+2/9iV5Q16h/1j/pH/TOTgcEAYAAwABgADAAGAAOAAcAAYAAwABgADAAGAAPgyQ2AT4NBIB3ew5dkAAAAAElFTkSuQmCC"

private extension StandardTheme {
    static let red = StandardTheme(rawValue: "red")
}

struct ColorThemeExample_Previews: PreviewProvider {
    static var previews: some View {
        StandardStyleImportExample()
    }
}
