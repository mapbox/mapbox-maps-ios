import SwiftUI

struct ColorPaletteView: View {
    @Binding var selectedScheme: RadarColorScheme

    var body: some View {
            ScrollView {
                VStack(spacing: 12) {
                    Text("Color Schemes")
                        .font(.title2.weight(.semibold))
                        .padding(.top, 20)

                    Grid {
                        GridRow {
                            schemeToggle(ColorSchemes.all[0])
                                .gridCellColumns(2)
                            schemeToggle(ColorSchemes.all[1])
                        }
                        GridRow {
                            schemeToggle(ColorSchemes.all[2])
                                .gridCellColumns(3)
                        }
                        GridRow {
                            schemeToggle(ColorSchemes.all[3])
                            schemeToggle(ColorSchemes.all[4])
                            schemeToggle(ColorSchemes.all[5])
                        }
                        GridRow {
                            schemeToggle(ColorSchemes.all[6])
                            schemeToggle(ColorSchemes.all[7])
                                .gridCellColumns(2)
                        }
                        GridRow {
                            schemeToggle(ColorSchemes.all[8])
                                .gridCellColumns(3)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
    }

    @ViewBuilder
    private func schemeToggle(_ scheme: RadarColorScheme) -> some View {
        Toggle(isOn: Binding(
            get: { scheme.name == selectedScheme.name },
            set: { isSelected in
                if isSelected {
                    selectedScheme = scheme
                }
            }
        )) {
            // Gradient with embedded text
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: scheme.gradientStops),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 36)
                .overlay(
                    Text(scheme.name)
                        .font(.callout.weight(.medium))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.7), radius: 1, x: 0, y: 0.5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(
                            scheme.name == selectedScheme.name ? .white : .white.opacity(0.3),
                            lineWidth: scheme.name == selectedScheme.name ? 3 : 1
                        )
                        .animation(.easeInOut(duration: 0.3), value: scheme.name == selectedScheme.name)
                )
                .scaleEffect(scheme.name == selectedScheme.name ? 1.05 : 1.0)
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                .shadow(
                    color: scheme.name == selectedScheme.name ? .white.opacity(0.4) : .clear,
                    radius: scheme.name == selectedScheme.name ? 8 : 0,
                    x: 0,
                    y: 0
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: scheme.name == selectedScheme.name)
        }
        .toggleStyle(.button)
        .buttonStyle(.plain)
    }
}

#Preview {
    ColorPaletteView(selectedScheme: .constant(ColorSchemes.all[0]))
}
