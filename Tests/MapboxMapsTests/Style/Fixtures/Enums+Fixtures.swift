// This file is generated.
// swiftlint:disable all
import Foundation

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

extension Value where T == Visibility {

	static func testConstantValue() -> Value<Visibility> {
		return .constant(.visible)
	}
}


// MARK: LINE_CAP

extension Value where T == LineCap {
    
    static func testConstantValue() -> Value<LineCap> {
       return .constant(LineCap.init(rawValue: "butt")!)
    }

}
// MARK: LINE_JOIN

extension Value where T == LineJoin {
    
    static func testConstantValue() -> Value<LineJoin> {
       return .constant(LineJoin.init(rawValue: "bevel")!)
    }

}
// MARK: ICON_ANCHOR

extension Value where T == IconAnchor {
    
    static func testConstantValue() -> Value<IconAnchor> {
       return .constant(IconAnchor.init(rawValue: "center")!)
    }

}
// MARK: ICON_PITCH_ALIGNMENT

extension Value where T == IconPitchAlignment {
    
    static func testConstantValue() -> Value<IconPitchAlignment> {
       return .constant(IconPitchAlignment.init(rawValue: "map")!)
    }

}
// MARK: ICON_ROTATION_ALIGNMENT

extension Value where T == IconRotationAlignment {
    
    static func testConstantValue() -> Value<IconRotationAlignment> {
       return .constant(IconRotationAlignment.init(rawValue: "map")!)
    }

}
// MARK: ICON_TEXT_FIT

extension Value where T == IconTextFit {
    
    static func testConstantValue() -> Value<IconTextFit> {
       return .constant(IconTextFit.init(rawValue: "none")!)
    }

}
// MARK: SYMBOL_PLACEMENT

extension Value where T == SymbolPlacement {
    
    static func testConstantValue() -> Value<SymbolPlacement> {
       return .constant(SymbolPlacement.init(rawValue: "point")!)
    }

}
// MARK: SYMBOL_Z_ORDER

extension Value where T == SymbolZOrder {
    
    static func testConstantValue() -> Value<SymbolZOrder> {
       return .constant(SymbolZOrder.init(rawValue: "auto")!)
    }

}
// MARK: TEXT_ANCHOR

extension Value where T == TextAnchor {
    
    static func testConstantValue() -> Value<TextAnchor> {
       return .constant(TextAnchor.init(rawValue: "center")!)
    }

}
// MARK: TEXT_JUSTIFY

extension Value where T == TextJustify {
    
    static func testConstantValue() -> Value<TextJustify> {
       return .constant(TextJustify.init(rawValue: "auto")!)
    }

}
// MARK: TEXT_FIELD
extension Value where T == Formatted {

    static func testConstantValue() -> Value<Formatted> {
        return .constant(.format([.substring(.constant("hello")), .formatOptions(.init(fontScale: 2, textColor: .purple))]))
    }
}
// MARK: TEXT_PITCH_ALIGNMENT

extension Value where T == TextPitchAlignment {
    
    static func testConstantValue() -> Value<TextPitchAlignment> {
       return .constant(TextPitchAlignment.init(rawValue: "map")!)
    }

}
// MARK: TEXT_ROTATION_ALIGNMENT

extension Value where T == TextRotationAlignment {
    
    static func testConstantValue() -> Value<TextRotationAlignment> {
       return .constant(TextRotationAlignment.init(rawValue: "map")!)
    }

}
// MARK: TEXT_TRANSFORM

extension Value where T == TextTransform {
    
    static func testConstantValue() -> Value<TextTransform> {
       return .constant(TextTransform.init(rawValue: "none")!)
    }

}
// MARK: FILL_TRANSLATE_ANCHOR

extension Value where T == FillTranslateAnchor {
    
    static func testConstantValue() -> Value<FillTranslateAnchor> {
       return .constant(FillTranslateAnchor.init(rawValue: "map")!)
    }

}
// MARK: LINE_TRANSLATE_ANCHOR

extension Value where T == LineTranslateAnchor {
    
    static func testConstantValue() -> Value<LineTranslateAnchor> {
       return .constant(LineTranslateAnchor.init(rawValue: "map")!)
    }

}
// MARK: ICON_TRANSLATE_ANCHOR

extension Value where T == IconTranslateAnchor {
    
    static func testConstantValue() -> Value<IconTranslateAnchor> {
       return .constant(IconTranslateAnchor.init(rawValue: "map")!)
    }

}
// MARK: TEXT_TRANSLATE_ANCHOR

extension Value where T == TextTranslateAnchor {
    
    static func testConstantValue() -> Value<TextTranslateAnchor> {
       return .constant(TextTranslateAnchor.init(rawValue: "map")!)
    }

}
// MARK: CIRCLE_PITCH_ALIGNMENT

extension Value where T == CirclePitchAlignment {
    
    static func testConstantValue() -> Value<CirclePitchAlignment> {
       return .constant(CirclePitchAlignment.init(rawValue: "map")!)
    }

}
// MARK: CIRCLE_PITCH_SCALE

extension Value where T == CirclePitchScale {
    
    static func testConstantValue() -> Value<CirclePitchScale> {
       return .constant(CirclePitchScale.init(rawValue: "map")!)
    }

}
// MARK: CIRCLE_TRANSLATE_ANCHOR

extension Value where T == CircleTranslateAnchor {
    
    static func testConstantValue() -> Value<CircleTranslateAnchor> {
       return .constant(CircleTranslateAnchor.init(rawValue: "map")!)
    }

}
// MARK: FILL_EXTRUSION_TRANSLATE_ANCHOR

extension Value where T == FillExtrusionTranslateAnchor {
    
    static func testConstantValue() -> Value<FillExtrusionTranslateAnchor> {
       return .constant(FillExtrusionTranslateAnchor.init(rawValue: "map")!)
    }

}
// MARK: RASTER_RESAMPLING

extension Value where T == RasterResampling {
    
    static func testConstantValue() -> Value<RasterResampling> {
       return .constant(RasterResampling.init(rawValue: "linear")!)
    }

}
// MARK: HILLSHADE_ILLUMINATION_ANCHOR

extension Value where T == HillshadeIlluminationAnchor {
    
    static func testConstantValue() -> Value<HillshadeIlluminationAnchor> {
       return .constant(HillshadeIlluminationAnchor.init(rawValue: "map")!)
    }

}
// MARK: SKY_TYPE

extension Value where T == SkyType {
    
    static func testConstantValue() -> Value<SkyType> {
       return .constant(SkyType.init(rawValue: "gradient")!)
    }

}
// MARK: ANCHOR

extension Value where T == Anchor {
    
    static func testConstantValue() -> Value<Anchor> {
       return .constant(Anchor.init(rawValue: "map")!)
    }

}
// MARK: TEXT_WRITING_MODE

extension Value where T == TextWritingMode {
    
    static func testConstantValue() -> Value<TextWritingMode> {
       return .constant(TextWritingMode.init(rawValue: "horizontal")!)
    }

}

// // swiftlint:enable all
// End of generated file.
