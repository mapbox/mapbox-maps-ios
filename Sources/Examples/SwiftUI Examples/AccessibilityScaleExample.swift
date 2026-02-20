import SwiftUI
@_spi(Experimental) import MapboxMaps

/// Example demonstrating accessibility scaling for map symbols.
///
/// This example shows:
/// - **Scale Factor**: Controls ALL symbols in the map (system labels + custom annotations)
///   - Fixed: Manual control with slider
///   - System: Automatic scaling based on system text size
///   - Custom: System scaling with custom mapping
/// - **Icon/Text Size Scale Range**: Only affects the custom annotations (shown in blue)
struct AccessibilityScaleExample: View {
    struct Location: Identifiable {
        let id = UUID()
        let name: String
        let coordinate: CLLocationCoordinate2D
    }

    enum ScaleMode: String, CaseIterable {
        case fixed = "Fixed"
        case system = "System"
        case custom = "Custom"
    }

    // Sample locations
    private static let locations = [
        Location(name: "Harlem", coordinate: CLLocationCoordinate2D(latitude: 40.8116, longitude: -73.9465)),
        Location(name: "Upper West Side", coordinate: CLLocationCoordinate2D(latitude: 40.7870, longitude: -73.9754)),
        Location(name: "Midtown", coordinate: CLLocationCoordinate2D(latitude: 40.7549, longitude: -73.9840))
    ]

    @State private var scaleMode: ScaleMode = .fixed
    @State private var scaleFactor: Float = 1.0
    @State private var iconSizeMin: Double = 0.8
    @State private var iconSizeMax: Double = 2.0
    @State private var textSizeMin: Double = 0.8
    @State private var textSizeMax: Double = 2.0
    @State private var showInfoSheet = false

    // Debounced range values to avoid flooding the map renderer on every slider tick
    @State private var debouncedIconSizeMin: Double = 0.8
    @State private var debouncedIconSizeMax: Double = 2.0
    @State private var debouncedTextSizeMin: Double = 0.8
    @State private var debouncedTextSizeMax: Double = 2.0

    var body: some View {
        MapReader { mapProxy in
            Map(initialViewport: .camera(center: CLLocationCoordinate2D(latitude: 40.7489, longitude: -73.9680), zoom: 11.5)) {
                // Add custom point annotations with distinct styling
                PointAnnotationGroup(Self.locations) { location in
                    PointAnnotation(coordinate: location.coordinate)
                        .image(named: "intermediate-pin")
                        .iconAnchor(.bottom)
                        .textField(location.name)
                        .textAnchor(.top)
                        .textOffset(x: 0, y: 0.3)
                        .textSize(16)
                        .textColor(StyleColor(.systemBlue))  // Blue to distinguish from map labels
                        .textHaloColor(.white)
                        .textHaloWidth(2)
                }
                .iconSizeScaleRange(min: debouncedIconSizeMin, max: debouncedIconSizeMax)
                .textSizeScaleRange(min: debouncedTextSizeMin, max: debouncedTextSizeMax)
            }
            .mapStyle(.standard)
            .onMapLoaded { _ in
                applyScaleBehavior(to: mapProxy.map)
            }
            .onChange(of: scaleMode) { _ in
                applyScaleBehavior(to: mapProxy.map)
            }
            .onChange(of: scaleFactor) { _ in
                if scaleMode == .fixed {
                    applyScaleBehavior(to: mapProxy.map)
                }
            }
        }
        .ignoresSafeArea()
        .task(id: iconSizeMin) {
            try? await Task.sleep(nanoseconds: 150_000_000)
            debouncedIconSizeMin = iconSizeMin
        }
        .task(id: iconSizeMax) {
            try? await Task.sleep(nanoseconds: 150_000_000)
            debouncedIconSizeMax = iconSizeMax
        }
        .task(id: textSizeMin) {
            try? await Task.sleep(nanoseconds: 150_000_000)
            debouncedTextSizeMin = textSizeMin
        }
        .task(id: textSizeMax) {
            try? await Task.sleep(nanoseconds: 150_000_000)
            debouncedTextSizeMax = textSizeMax
        }
        .overlay(alignment: .bottom, content: {
            VStack(spacing: 8) {
                // Info button above settings panel
                HStack {
                    Spacer()
                    Button {
                        showInfoSheet = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 22))
                            .padding(8)
                            .background(.regularMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)

                // Settings Panel
                VStack(alignment: .leading, spacing: 12) {

                    // Scale Factor Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Scale Factor (all symbols)")
                            .font(.caption.bold())

                        Picker("Mode", selection: $scaleMode) {
                            ForEach(ScaleMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)

                        if scaleMode == .fixed {
                            HStack {
                                Text("Scale:")
                                    .font(.caption2)
                                Spacer()
                                Text(String(format: "%.1f", scaleFactor))
                                    .font(.caption2.monospacedDigit())
                            }
                            Slider(value: $scaleFactor, in: 0.5...3.0, step: 0.1)
                        } else if scaleMode == .system {
                            Text("Automatic scaling from Settings → Accessibility")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Custom mapping: dampens large accessibility scales")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    // Scale Ranges Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Scale Ranges (custom annotations)")
                            .font(.caption.bold())

                        // Icon Size Scale Range
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Icon Size Range")
                                .font(.caption2)
                            HStack(spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Min: \(String(format: "%.1f", iconSizeMin))")
                                        .font(.system(size: 10))
                                    Slider(value: $iconSizeMin, in: 0.1...5.0, step: 0.1)
                                        .onChange(of: iconSizeMin) { _ in
                                            if iconSizeMin > iconSizeMax { iconSizeMax = iconSizeMin }
                                        }
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Max: \(String(format: "%.1f", iconSizeMax))")
                                        .font(.system(size: 10))
                                    Slider(value: $iconSizeMax, in: 0.1...5.0, step: 0.1)
                                        .onChange(of: iconSizeMax) { _ in
                                            if iconSizeMax < iconSizeMin { iconSizeMin = iconSizeMax }
                                        }
                                }
                            }
                        }

                        // Text Size Scale Range
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Text Size Range")
                                .font(.caption2)
                            HStack(spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Min: \(String(format: "%.1f", textSizeMin))")
                                        .font(.system(size: 10))
                                    Slider(value: $textSizeMin, in: 0.1...5.0, step: 0.1)
                                        .onChange(of: textSizeMin) { _ in
                                            if textSizeMin > textSizeMax { textSizeMax = textSizeMin }
                                        }
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Max: \(String(format: "%.1f", textSizeMax))")
                                        .font(.system(size: 10))
                                    Slider(value: $textSizeMax, in: 0.1...5.0, step: 0.1)
                                        .onChange(of: textSizeMax) { _ in
                                            if textSizeMax < textSizeMin { textSizeMin = textSizeMax }
                                        }
                                }
                            }
                        }
                    }
                }
                .floating()
            }
            .padding(.bottom, 30)
        })
        .sheet(isPresented: $showInfoSheet) {
            AccessibilityScaleInfoView()
                .defaultDetents()
        }
    }

    private func applyScaleBehavior(to mapboxMap: MapboxMap?) {
        guard let mapboxMap = mapboxMap else { return }

        switch scaleMode {
        case .fixed:
            mapboxMap.symbolScaleBehavior = .fixed(scaleFactor: Double(scaleFactor))
        case .system:
            mapboxMap.symbolScaleBehavior = .system
        case .custom:
            // Custom mapping: dampens large accessibility scales
            mapboxMap.symbolScaleBehavior = .system(mapping: { systemScale in
                switch systemScale {
                case ..<1.0:
                    return systemScale * 1.1  // Boost small scales by 10%
                case 1.0...1.3:
                    return systemScale        // Keep medium scales unchanged
                default:
                    return 1.3 + (systemScale - 1.3) * 0.4  // Dampen large scales
                }
            })
        }
    }
}

private struct AccessibilityScaleInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Accessibility Scale Example")
                    .font(.headline)

                Text("This example demonstrates how to control symbol scaling for accessibility using the Maps SDK.")
                    .font(.subheadline)

                VStack(alignment: .leading, spacing: 12) {
                    Group {
                        Text("Scale Factor")
                            .font(.subheadline.bold())
                        Text("Adjusts the global scale factor for all symbol layers on the map using the `symbolScaleBehavior` property. This affects both system map labels and custom annotations.")
                            .font(.footnote)

                        (Text("• ") + Text("Fixed").bold() + Text(": Manual control with a slider"))
                            .font(.footnote)
                        (Text("• ") + Text("System").bold() + Text(": Automatically scales based on the device's accessibility text size setting (Settings → Accessibility → Display & Text Size → Larger Accessibility Sizes)"))
                            .font(.footnote)
                        (Text("• ") + Text("Custom").bold() + Text(": Uses a custom mapping function to modify system scale values (e.g., dampen large scales)"))
                            .font(.footnote)
                    }

                    Divider()

                    Group {
                        Text("Icon Size Scale Range")
                            .font(.subheadline.bold())
                        Text("Sets the minimum and maximum scaling limits for icons using the `icon-size-scale-range` layout property. This only affects the custom blue annotations in this example.")
                            .font(.footnote)

                        Text("Example: Setting `[1.0, 1.0]` prevents icons from scaling regardless of the scale factor value.")
                            .font(.footnote)
                            .italic()
                    }

                    Divider()

                    Group {
                        Text("Text Size Scale Range")
                            .font(.subheadline.bold())
                        Text("Sets the minimum and maximum scaling limits for text using the `text-size-scale-range` layout property. This only affects the custom blue text labels in this example.")
                            .font(.footnote)

                        Text("Example: Setting `[0.5, 3.0]` allows text to scale from half size to triple size based on the scale factor.")
                            .font(.footnote)
                            .italic()
                    }
                }

                Divider()

                Text("Try experimenting with different combinations:")
                    .font(.subheadline.bold())

                Text("• Set scale factor to 2.0 with icon range [1.0, 1.0] to see text scale while icons stay the same size")
                    .font(.footnote)
                Text("• Switch to System mode and change your device's text size in Settings to see automatic scaling")
                    .font(.footnote)
                Text("• Use Custom mode to see how mapping functions can dampen extreme scale values")
                    .font(.footnote)
            }
            .padding()
        }
    }
}

#Preview {
    AccessibilityScaleExample()
}
