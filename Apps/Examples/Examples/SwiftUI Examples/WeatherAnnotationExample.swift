import SwiftUI
import MapboxMaps

private struct WeatherData: Identifiable, Equatable {
    let id = UUID().uuidString
    let coordinate: CLLocationCoordinate2D
    let temperature: Measurement<UnitTemperature>
    let iconName: String
}

@available(iOS 14.0, *)
struct WeatherAnnotationExample: View {
    @State private var viewport: Viewport = .camera(center: .berlin, zoom: 1.5)

    @State private var selectedData: WeatherData?
    private var weatherData: [WeatherData] = [
        WeatherData(coordinate: .helsinki, temperature: Measurement(value: 25, unit: .celsius), iconName: "sun.min.fill"),
        WeatherData(coordinate: .london, temperature: Measurement(value: 20, unit: .celsius), iconName: "cloud.drizzle.fill"),
        WeatherData(coordinate: .berlin, temperature: Measurement(value: 30, unit: .celsius), iconName: "cloud.bolt.rain.fill")
    ]

    var body: some View {
        Map(viewport: $viewport) {
            ForEvery(weatherData) { data in
                MapViewAnnotation(coordinate: data.coordinate) {
                    WeatherIconView(data: data, selectedData: $selectedData)
                }
            }
        }
        .onChange(of: selectedData?.coordinate) { center in
            guard let center else { return }

            withViewportAnimation(.default(maxDuration: 0.5)) {
                viewport = .camera(center: center, zoom: 2.5)
            }
        }
        .ignoresSafeArea()
    }
}

@available(iOS 14.0, *)
private struct WeatherIconView: View {
    var data: WeatherData
    @Binding var selectedData: WeatherData?
    @State private var isSelected = false

    private let formatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        return formatter
    }()

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white, lineWidth: 3)
                .overlay(Circle().fill(.blue))
                .frame(width: isSelected ? 50 : 35, height: isSelected ? 50 : 35)
            VStack {
                if isSelected {
                    Text(formatter.string(from: data.temperature))
                        .font(.caption2)
                }
                Image(systemName: data.iconName)
            }
        }
        .foregroundColor(.white)
        .onTapGesture {
            selectedData = data
        }
        .onChange(of: selectedData) { selectedData in
            withAnimation(.interactiveSpring()) {
                isSelected = selectedData == data
            }
        }
    }
}
@available(iOS 14.0, *)
struct WeatherAnnotationExample_Preview: PreviewProvider {

    static var previews: some View {
        WeatherAnnotationExample()
    }
}
