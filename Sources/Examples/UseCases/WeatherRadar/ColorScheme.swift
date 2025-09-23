import SwiftUI

struct RadarColorScheme: Equatable {
    private static let stops = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]

    let name: String
    let colors: [UIColor]

    var gradientStops: [Gradient.Stop] {
        return zip(colors, Self.stops).map { Gradient.Stop(color: Color(uiColor: $0), location: $1) }
    }

    // Convert to Mapbox expression format
    var mapboxExpression: [Any] {
        let stops = zip(colors, Self.stops).reduce(into: []) { (partialResult, pair) in
            let (color, stop) = pair
            partialResult.append(stop)
            partialResult.append(color.hexString)
        }

        return ["interpolate", ["linear"], ["raster-value"]] + stops
    }

}

struct ColorSchemes {
    static let all: [RadarColorScheme] = [
        // Default "Radar" palette from the source
        RadarColorScheme(
            name: "Radar",
            colors: [
                UIColor(hex: 0x001d61),
                UIColor(hex: 0x297db0),
                UIColor(hex: 0x52dcff),
                UIColor(hex: 0x21c700),
                UIColor(hex: 0xfff714),
                UIColor(hex: 0xff950a),
                UIColor(hex: 0xd60700),
                UIColor(hex: 0xdc00f0),
                UIColor(hex: 0xe855f5),
                UIColor(hex: 0xf3aafa),
                UIColor(hex: 0xffffff)
            ]
        ),

        // D3 Blues scheme - exact colors from D3
        RadarColorScheme(
            name: "Blues",
            colors: [
                UIColor(hex: 0xf7fbff),
                UIColor(hex: 0xe3eef9),
                UIColor(hex: 0xcfe1f2),
                UIColor(hex: 0xb5d4e9),
                UIColor(hex: 0x93c3df),
                UIColor(hex: 0x6daed5),
                UIColor(hex: 0x4b97c9),
                UIColor(hex: 0x2f7ebc),
                UIColor(hex: 0x1864aa),
                UIColor(hex: 0x0a4a90),
                UIColor(hex: 0x08306b)
            ]
        ),

        // D3 YlGnBu scheme
        RadarColorScheme(
            name: "YlGnBu",
            colors: [
                UIColor(hex: 0xffffd9),
                UIColor(hex: 0xeff9bd),
                UIColor(hex: 0xd5eeb3),
                UIColor(hex: 0xa9ddb7),
                UIColor(hex: 0x73c9bd),
                UIColor(hex: 0x45b4c2),
                UIColor(hex: 0x2897bf),
                UIColor(hex: 0x2073b2),
                UIColor(hex: 0x234ea0),
                UIColor(hex: 0x1c3185),
                UIColor(hex: 0x081d58)
            ]
        ),

        // D3 RdPu scheme
        RadarColorScheme(
            name: "RdPu",
            colors: [
                UIColor(hex: 0xfff7f3),
                UIColor(hex: 0xfde4e1),
                UIColor(hex: 0xfccfcc),
                UIColor(hex: 0xfbb5bc),
                UIColor(hex: 0xf993b0),
                UIColor(hex: 0xf369a3),
                UIColor(hex: 0xe03e98),
                UIColor(hex: 0xc01788),
                UIColor(hex: 0x99037c),
                UIColor(hex: 0x700174),
                UIColor(hex: 0x49006a)
            ]
        ),

        // D3 Inferno scheme
        RadarColorScheme(
            name: "Inferno",
            colors: [
                UIColor(hex: 0x000004),
                UIColor(hex: 0x160b39),
                UIColor(hex: 0x420a68),
                UIColor(hex: 0x6a176e),
                UIColor(hex: 0x932667),
                UIColor(hex: 0xbc3754),
                UIColor(hex: 0xdd513a),
                UIColor(hex: 0xf37819),
                UIColor(hex: 0xfca50a),
                UIColor(hex: 0xf6d746),
                UIColor(hex: 0xfcffa4)
            ]
        ),

        // D3 Viridis scheme
        RadarColorScheme(
            name: "Viridis",
            colors: [
                UIColor(hex: 0x440154),
                UIColor(hex: 0x482475),
                UIColor(hex: 0x414487),
                UIColor(hex: 0x355f8d),
                UIColor(hex: 0x2a788e),
                UIColor(hex: 0x21918c),
                UIColor(hex: 0x22a884),
                UIColor(hex: 0x44bf70),
                UIColor(hex: 0x7ad151),
                UIColor(hex: 0xbddf26),
                UIColor(hex: 0xfde725)
            ]
        ),

        // D3 Spectral scheme
        RadarColorScheme(
            name: "Spectral",
            colors: [
                UIColor(hex: 0x9e0142),
                UIColor(hex: 0xd13c4b),
                UIColor(hex: 0xf0704a),
                UIColor(hex: 0xfcac63),
                UIColor(hex: 0xfedd8d),
                UIColor(hex: 0xfbf8b0),
                UIColor(hex: 0xe0f3a1),
                UIColor(hex: 0xa9dda2),
                UIColor(hex: 0x69bda9),
                UIColor(hex: 0x4288b5),
                UIColor(hex: 0x5e4fa2)
            ]
        ),

        // D3 RdBu scheme
        RadarColorScheme(
            name: "RdBu",
            colors: [
                UIColor(hex: 0x67001f),
                UIColor(hex: 0xac202f),
                UIColor(hex: 0xd56050),
                UIColor(hex: 0xf1a385),
                UIColor(hex: 0xfbd7c4),
                UIColor(hex: 0xf2efee),
                UIColor(hex: 0xcde3ee),
                UIColor(hex: 0x8fc2dd),
                UIColor(hex: 0x4b94c4),
                UIColor(hex: 0x2265a3),
                UIColor(hex: 0x053061)
            ]
        ),

        // D3 RdYlBu scheme
        RadarColorScheme(
            name: "RdYlBu",
            colors: [
                UIColor(hex: 0xa50026),
                UIColor(hex: 0xd4322c),
                UIColor(hex: 0xf16e43),
                UIColor(hex: 0xfcac64),
                UIColor(hex: 0xfedd90),
                UIColor(hex: 0xfaf8c1),
                UIColor(hex: 0xdcf1ec),
                UIColor(hex: 0xabd6e8),
                UIColor(hex: 0x75abd0),
                UIColor(hex: 0x4a74b4),
                UIColor(hex: 0x313695)
            ]
        )
    ]
}
