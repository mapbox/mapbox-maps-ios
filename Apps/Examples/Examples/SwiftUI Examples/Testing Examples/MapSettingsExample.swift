import SwiftUI
@_spi(Experimental) import MapboxMaps

struct Settings {
    var mapStyle: MapStyle = .standard
    var orientation: NorthOrientation = .upwards
    var gestureOptions: GestureOptions = .init()
    var cameraBounds: CameraBoundsOptions = .world
    var constrainMode: ConstrainMode = .heightOnly
    var ornamentSettings = OrnamentSettings()
    var debugOptions: MapViewDebugOptions = [.camera]
    var performance = PerformanceSettings()

    struct OrnamentSettings {
        var isScaleBarVisible = true
        var isCompassVisible = true
    }

    struct PerformanceSettings {
        var samplerOptions = PerformanceStatisticsOptions.SamplerOptions([.perFrame, .cumulative])
        var samplingDurationMillis: UInt32 = 5000
        var isStatisticsEnabled = false

        var statisticsOptions: PerformanceStatisticsOptions {
            PerformanceStatisticsOptions(samplerOptions, samplingDurationMillis: Double(samplingDurationMillis))
        }
    }
}

@available(iOS 14.0, *)
struct MapSettingsExample: View {
    @State private var settingsOpened = false
    @State private var settings = Settings()
    @State private var performanceStatistics: PerformanceStatistics?

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(initialViewport: .camera(center: .berlin, zoom: 12))
                .cameraBounds(settings.cameraBounds)
                .mapStyle(settings.mapStyle)
                .gestureOptions(settings.gestureOptions)
                .gestureHandlers(gestureHandlers)
                .northOrientation(settings.orientation)
                .constrainMode(settings.constrainMode)
                .collectPerformanceStatistics(settings.performance.isStatisticsEnabled ? settings.performance.statisticsOptions : nil) { stats in
                    performanceStatistics = stats
                }
                .ornamentOptions(OrnamentOptions(
                    scaleBar: ScaleBarViewOptions(visibility: settings.ornamentSettings.isScaleBarVisible ? .visible : .hidden),
                    compass: CompassViewOptions(visibility: settings.ornamentSettings.isCompassVisible ? .visible : .hidden)
                ))
                .debugOptions(settings.debugOptions)
                .ignoresSafeArea()
                .sheet(isPresented: $settingsOpened) {
                    SettingsView(settings: $settings)
                        .defaultDetents()
                }
                .safeOverlay(alignment: .trailing) {
                    MapStyleSelectorButton(mapStyle: $settings.mapStyle)
                }
                .toolbar {
                    Button("Settings") {
                        settingsOpened.toggle()
                    }
                }

            if settings.performance.isStatisticsEnabled, let stats = performanceStatistics {
                VStack(alignment: .leading) {
                    Text(stats.topRenderedLayerDescription).font(.safeMonospaced)
                    Text(stats.renderingDurationStatisticsDescription).font(.safeMonospaced)
                }
                .floating()
            }
        }
    }

    var gestureHandlers: MapGestureHandlers {
        MapGestureHandlers(
            onBegin: { type in print("Gesture begin: \(type)") },
            onEnd: { type, willAnimate in print("Gesture end: \(type), will animate: \(willAnimate)") },
            onEndAnimation: { type in print("Gesture end animation: \(type)") })
    }
}

@available(iOS 14.0, *)
struct SettingsView: View {
    @Binding var settings: Settings
    #if os(visionOS)
    @Environment(\.dismiss) private var dismiss
    #endif

    var body: some View {
        Form {
            Section {
                Picker(selection: $settings.cameraBounds, label: Text("Camera Bounds")) {
                    Text("World").tag(CameraBoundsOptions.world)
                    Text("Iceland").tag(CameraBoundsOptions.iceland)
                }
                HStack {
                    Text("Orientation")
                    Picker("orientation", selection: $settings.orientation) {
                        Text("Up").tag(NorthOrientation.upwards)
                        Text("Down").tag(NorthOrientation.downwards)
                        Text("Left").tag(NorthOrientation.rightwards)
                        Text("Right").tag(NorthOrientation.leftwards)
                    }
                    .pickerStyle(.segmented)
                }
                HStack {
                    Text("Constrain Mode")
                    Picker("constrain mode", selection: $settings.constrainMode) {
                        Text("Height").tag(ConstrainMode.heightOnly)
                        Text("Width+Height").tag(ConstrainMode.widthAndHeight)
                        Text("None").tag(ConstrainMode.none)
                    }
                    .pickerStyle(.segmented)
                }
            }.pickerStyle(.menu)
            Section {
                Toggle("Pan", isOn: $settings.gestureOptions.panEnabled)
                Toggle("Pinch", isOn: $settings.gestureOptions.pinchEnabled)
                Toggle("Rotate", isOn: $settings.gestureOptions.rotateEnabled)
            } header: {
                Text("Gestures")
            }
            Section {
                Toggle("Show Scale Bar", isOn: $settings.ornamentSettings.isScaleBarVisible)
                Toggle("Show Compass", isOn: $settings.ornamentSettings.isCompassVisible)
            } header: {
                Text("Ornaments")
            }
            Section {
                let options = [
                    ("Camera", MapViewDebugOptions.camera),
                    ("Padding", .padding),
                    ("Tile Borders", .tileBorders),
                    ("Parse Status", .parseStatus),
                    ("Timestamps", .timestamps),
                    ("Collision", .collision),
                    ("Overdraw", .overdraw),
                    ("Stencil Clip", .stencilClip),
                    ("Depth Buffer", .depthBuffer),
                    ("Model Bounds", .modelBounds),
                    ("Light", .light)
                ]
                ForEach(options, id: \.0) { option in
                    Toggle(option.0, isOn: $settings.debugOptions.contains(option: option.1))
                }

            } header: {
                Text("Debug Options")
            }
            Section {
                let samplerOptions = [
                    ("Per Frame", PerformanceStatisticsOptions.SamplerOptions.perFrame),
                    ("Cumulative", .cumulative)
                ]
                Toggle("Collect Statistics", isOn: $settings.performance.isStatisticsEnabled)

                if settings.performance.isStatisticsEnabled {
                    Stepper("Sampling Duration, \(settings.performance.samplingDurationMillis) ms", value: $settings.performance.samplingDurationMillis, step: 1000)
                    ForEach(samplerOptions, id: \.0) { option in
                        Toggle(option.0, isOn: $settings.performance.samplerOptions.contains(option: option.1))
                    }
                }
            } header: {
                Text("Performance Statistics")
            }
            #if os(visionOS)
            Button("Close Settings") {
                dismiss()
            }
            #endif
        }
    }
}

@available(iOS 13.0, *)
private extension Binding where Value: OptionSet {
    func contains(option: Value.Element) -> Binding<Bool> {
        Binding<Bool> {
            self.wrappedValue.contains(option)
        }
        set: {
            if $0 {
                self.wrappedValue.insert(option)
            } else {
                self.wrappedValue.remove(option)
            }
        }
    }
}

@available(iOS 15.0, *)
struct MapSettingsExample_Preveiw: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MapSettingsExample()
        }
    }
}

extension PerformanceStatistics {
    fileprivate var topRenderedLayerDescription: String {
        if let topRenderedLayer = perFrameStatistics?.topRenderLayers.first {
            return "Top rendered layer: `\(topRenderedLayer.name)` for \(topRenderedLayer.durationMillis)ms."
        } else {
            return "No information about topRenderedLayer."
        }
    }

    fileprivate var renderingDurationStatisticsDescription: String {
        "Max rendering call duration: \(mapRenderDurationStatistics.maxMillis)ms.\nMedian rendering call duration: \(mapRenderDurationStatistics.medianMillis)ms"
    }
}
