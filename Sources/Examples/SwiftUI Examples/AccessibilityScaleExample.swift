import SwiftUI
@_spi(Experimental) import MapboxMaps

/// Example demonstrating accessibility scaling for map symbols.
///
/// This example shows three modes:
/// - Fixed: Manual scale control with slider (no system listeners)
/// - System: Automatic scaling based on system text size (opt-in)
/// - Custom: System scaling with custom mapping that dampens large accessibility scales
struct AccessibilityScaleExample: View {
    enum ScaleMode: String, CaseIterable {
        case fixed = "Fixed"
        case system = "System"
        case custom = "Custom"
    }

    @State private var selectedMode: ScaleMode = .fixed
    @State private var customScaleValue: Float = 1.0

    var body: some View {
        MapReader { mapProxy in
            Map(initialViewport: .camera(center: .init(latitude: 40.7128, longitude: -74.0060), zoom: 12))
                .mapStyle(.standard)
                .onMapLoaded { _ in
                    applySymbolScaleBehavior(to: mapProxy.map)
                }
                .onChange(of: selectedMode) { _ in
                    applySymbolScaleBehavior(to: mapProxy.map)
                }
                .onChange(of: customScaleValue) { _ in
                    if selectedMode == .fixed {
                        applySymbolScaleBehavior(to: mapProxy.map)
                    }
                }
        }
        .ignoresSafeArea(edges: .bottom)
        .overlay(alignment: .bottom) {
            VStack(spacing: 12) {
                // Conditional content (above buttons)
                Group {
                    if selectedMode == .fixed {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Scale factor:")
                                    .font(.caption)
                                Spacer()
                                Text(String(format: "%.2fx", customScaleValue))
                                    .font(.caption.monospacedDigit())
                            }
                            Slider(value: $customScaleValue, in: 0.8...2.0, step: 0.1)
                            Text("Manual scale control (no system listeners)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                        .frame(maxWidth: 340)
                    } else if selectedMode == .system {
                        Text("Automatic scaling with default mapping.\nChange system text size in Settings to see effect.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                            .frame(maxWidth: 340)
                    } else if selectedMode == .custom {
                        Text("Custom mapping: boosts small scales +10%, dampens large scales.\nChange system text size in Settings to see effect.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                            .frame(maxWidth: 340)
                    }
                }
                .frame(height: selectedMode == .fixed ? 80 : 60)
                .opacity(1)

                // Mode picker
                Picker("Scale Mode", selection: $selectedMode) {
                    ForEach(ScaleMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 340)
            }
            .padding(.bottom, 70)
            .animation(.easeInOut(duration: 0.2), value: selectedMode)
        }
    }

    private func applySymbolScaleBehavior(to mapboxMap: MapboxMap?) {
        guard let mapboxMap = mapboxMap else { return }
        let behavior = scaleBehaviorForMode()
        mapboxMap.symbolScaleBehavior = behavior
    }

    private func scaleBehaviorForMode() -> SymbolScaleBehavior {
        switch selectedMode {
        case .fixed:
            // Fixed scale: manual control via slider
            return .fixed(scaleFactor: Double(customScaleValue))
        case .system:
            // System: automatic scaling with default mapping
            return .system
        case .custom:
            // Custom: increases low scale values proportionally, dampens large accessibility scales
            return .system(mapping: { systemScale in
                switch systemScale {
                case ..<1.0:
                    return systemScale * 1.1  // Boost small scales by 10%
                case 1.0...1.3:
                    return systemScale        // Keep medium scales unchanged
                default:
                    return 1.3 + (systemScale - 1.3) * 0.4  // Dampen large scales (max ~1.6x)
                }
            })
        }
    }
}

#Preview {
    AccessibilityScaleExample()
}
