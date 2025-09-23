import SwiftUI
@_spi(Experimental) import MapboxMaps

struct RadarContentView: View {
    private enum AnimationState {
        case playing, paused

        func next() -> Self {
            return switch self {
            case .playing: .paused
            case .paused: .playing
            }
        }

        var iconName: String {
            return switch self {
            case .playing: "pause.fill"
            case .paused: "play.fill"
            }
        }
    }

    private let tilesets = [
        "mbxsolutions.2nm7e1vb",
        "mbxsolutions.13z8zf72",
        "mbxsolutions.6f0qjx4r",
        "mbxsolutions.bybqmlpw",
        "mbxsolutions.bhftnzh4",
        "mbxsolutions.bded0cu7",
    ]
    @State private var timer = Timer.publish(every: .infinity, on: .main, in: .common).autoconnect()
    @State private var state: AnimationState = .paused
    @State private var visibleLayerIndex = 0
    @State private var skipCount: Int = 0
    @State private var selectedColorScheme: RadarColorScheme = ColorSchemes.all[0]
    @State private var showingColorPalette = false
    @FocusState private var isFocused: Bool

    var body: some View {
        mapView
            .overlay(alignment: .bottomLeading) {
                HStack(spacing: 12) {
                    // Layer scribble view
                    TimelineScrubber(
                        itemCount: tilesets.count,
                        currentIndex: $visibleLayerIndex,
                        onInteractionStart: {
                            state = .paused
                        }
                    )
                    .frame(height: 44)
                    .frame(maxWidth: 200)
                    .padding(.horizontal, 16)
                    .safeRegularInteractiveGlassEffect()
                    Spacer()
                    // Control buttons
                    HStack(spacing: 8) {
                        Button(action: {
                            state = state.next()
                        }, label: {
                            Image(systemName: state.iconName)
                                .frame(width: 32, height: 32)
                        })
                        .onChange(of: state) { newValue in
                            skipCount = 0
                            switch newValue {
                            case .paused: timer.upstream.connect().cancel()
                            case .playing: timer = Timer.publish(every: 0.125, tolerance: 0, on: .main, in: .common).autoconnect()
                            }
                        }
                        .safeButtonGlassStyle()

                        Button(action: {
                            showingColorPalette = true
                        }, label: {
                            Image(systemName: "swatchpalette.fill")
                                .frame(width: 32, height: 32)
                        })
                        .safeButtonGlassStyle()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .applyDarkNavigationBarOniOS26AndAbove()
            .sheet(isPresented: $showingColorPalette) {
                ColorPaletteView(selectedScheme: $selectedColorScheme)
                    .presentationDetents([.medium, .fraction(0.35)])
            }
    }

    @ViewBuilder
    var mapView: some View {
        MapReader { proxy in
            Map(initialViewport: .camera(center: CLLocationCoordinate2D(latitude: 40, longitude: -74.5), zoom: 4)) {
                mapContent
            }
            .mapStyle(
                .standard(
                    theme: .default,
                    colorAdminBoundaries: .init(.white),
                    colorGreenspace: .init(.darkGray),
                    colorMotorways: .init(.clear),
                    colorRoads: .init(.clear),
                    colorTrunks: .init(.clear),
                    colorWater: .init(.black)
                )
            )
            .onStyleLoaded(action: { _ in
                for pair in tilesets.enumerated() {
                    let (index, tileset) = pair
                    try! proxy.map?.setLayerProperty(for: "layer-\(tileset)", property: "raster-color", value: selectedColorScheme.mapboxExpression)
                    try! proxy.map?.setLayerProperty(for: "layer-\(tileset)", property: "raster-opacity", value: index == visibleLayerIndex ? 1 : 0)

                }
            })
            .ornamentOptions(.init(logo: .init(margins: .init(x: 26, y: 0)), attributionButton: .init(margins: .init(x: 8, y: -2))))
            .onReceive(timer) { _ in
                skipCount -= 1
                if skipCount > 0 { return }

                changeVisibleLayer(forward: true, proxy: proxy)

                if visibleLayerIndex == self.tilesets.count - 1 {
                    skipCount = 8
                }
            }
            .safeFocusable()
            .focused($isFocused)
            .onAppear { isFocused = true }
            .safeOnKeyPressHandled(.rightArrow, action: {
                state = .paused
                changeVisibleLayer(forward: true, proxy: proxy)
            })
            .safeOnKeyPressHandled(.leftArrow, action: {
                state = .paused
                changeVisibleLayer(forward: false, proxy: proxy)
            })
            .onChange(of: visibleLayerIndex) { newValue in
                for pair in tilesets.enumerated() {
                    try! proxy.map?.setLayerProperty(for: "layer-\(pair.element)", property: "raster-opacity", value: pair.offset == newValue ? 1 : 0)
                }
            }
            .onChange(of: selectedColorScheme) { newValue in
                for tileset in tilesets {
                    try! proxy.map?.setLayerProperty(for: "layer-\(tileset)", property: "raster-color", value: newValue.mapboxExpression)
                }

            }
            .ignoresSafeArea()
        }
    }

    private func changeVisibleLayer(forward: Bool, proxy: MapProxy) {
        if forward {
            visibleLayerIndex = (visibleLayerIndex + 1) % tilesets.count
        } else {
            visibleLayerIndex = (visibleLayerIndex - 1) >= 0 ? (visibleLayerIndex - 1) : tilesets.count - 1
        }
    }

    @MapContentBuilder
    var mapContent: some MapContent {
        ForEvery(Array(tilesets.enumerated()), id: \.element) { pair in
            RasterSource(id: "source-\(pair.element)")
                .url("mapbox://\(pair.element)")
                .tileSize(256)

            RasterLayer(id: "layer-\(pair.element)", source: "source-\(pair.element)")
                .slot(.bottom)
                .rasterResampling(
                    Exp(.step) {
                        Exp(.zoom)
                        "linear"
                        3
                        "nearest"
                    }
                )
                .rasterColorMix(red: 1, green: 0, blue: 0, offset: 0)
                .rasterColorRange(min: 0, max: 1)
                .rasterFadeDuration(0)
                .rasterOpacityTransition(.init(duration: 0, delay: 0))
                .rasterColorUseTheme(.none)
        }
    }
}

extension View {
    fileprivate func applyDarkNavigationBarOniOS26AndAbove() -> some View {
        // iOS 18 and below have opaque nav bar so having black status and nav bar text is ok
        // iOS 26 has transparent nav bar, this makes nav and status bar text white for good contrast with the map underneath
#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            return self.toolbarColorScheme(.dark, for: .navigationBar)
        }
#endif
        return self
    }

    func safeFocusable() -> some View {
        if #available(iOS 17.0, *) {
            return self.focusable()
        }
        return self
    }

    func safeOnKeyPressHandled(_ key: KeyEquivalent, action: @escaping () -> Void) -> some View {
        if #available(iOS 17.0, *) {
            return self.onKeyPress(key) {
                action()
                return .handled
            }
        }
        return self
    }

    fileprivate func safeRegularInteractiveGlassEffect() -> some View {
#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            return self.glassEffect(.regular.interactive())
        }
#endif

        return self.background(.regularMaterial).cornerRadius(8)
    }

    fileprivate func safeButtonGlassStyle() -> some View {
#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            return self.buttonStyle(.glass)
        }
#endif

        return self.buttonStyle(.borderedProminent)
    }
}
