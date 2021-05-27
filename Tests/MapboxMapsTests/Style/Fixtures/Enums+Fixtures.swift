// swiftlint:disable all
// This file is generated.
import Foundation

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

extension Value where T == Visibility {

	static func testConstantValue() -> Value<Visibility> {
		return .constant(Visibility.testConstantValue())
	}
}

extension Visibility {
  static func testConstantValue() -> Visibility {
		return .visible
	}
}


// MARK: LINE_CAP

extension Value where T == LineCap {
    
    static func testConstantValue() -> Value<LineCap> {
       return .constant(LineCap.testConstantValue())
    }

}

extension LineCap {
    
  static func testConstantValue() -> LineCap {
     return LineCap.init(rawValue: "butt")!
  }

}
// MARK: LINE_JOIN

extension Value where T == LineJoin {
    
    static func testConstantValue() -> Value<LineJoin> {
       return .constant(LineJoin.testConstantValue())
    }

}

extension LineJoin {
    
  static func testConstantValue() -> LineJoin {
     return LineJoin.init(rawValue: "bevel")!
  }

}
// MARK: ICON_ANCHOR

extension Value where T == IconAnchor {
    
    static func testConstantValue() -> Value<IconAnchor> {
       return .constant(IconAnchor.testConstantValue())
    }

}

extension IconAnchor {
    
  static func testConstantValue() -> IconAnchor {
     return IconAnchor.init(rawValue: "center")!
  }

}
// MARK: ICON_PITCH_ALIGNMENT

extension Value where T == IconPitchAlignment {
    
    static func testConstantValue() -> Value<IconPitchAlignment> {
       return .constant(IconPitchAlignment.testConstantValue())
    }

}

extension IconPitchAlignment {
    
  static func testConstantValue() -> IconPitchAlignment {
     return IconPitchAlignment.init(rawValue: "map")!
  }

}
// MARK: ICON_ROTATION_ALIGNMENT

extension Value where T == IconRotationAlignment {
    
    static func testConstantValue() -> Value<IconRotationAlignment> {
       return .constant(IconRotationAlignment.testConstantValue())
    }

}

extension IconRotationAlignment {
    
  static func testConstantValue() -> IconRotationAlignment {
     return IconRotationAlignment.init(rawValue: "map")!
  }

}
// MARK: ICON_TEXT_FIT

extension Value where T == IconTextFit {
    
    static func testConstantValue() -> Value<IconTextFit> {
       return .constant(IconTextFit.testConstantValue())
    }

}

extension IconTextFit {
    
  static func testConstantValue() -> IconTextFit {
     return IconTextFit.init(rawValue: "none")!
  }

}
// MARK: SYMBOL_PLACEMENT

extension Value where T == SymbolPlacement {
    
    static func testConstantValue() -> Value<SymbolPlacement> {
       return .constant(SymbolPlacement.testConstantValue())
    }

}

extension SymbolPlacement {
    
  static func testConstantValue() -> SymbolPlacement {
     return SymbolPlacement.init(rawValue: "point")!
  }

}
// MARK: SYMBOL_Z_ORDER

extension Value where T == SymbolZOrder {
    
    static func testConstantValue() -> Value<SymbolZOrder> {
       return .constant(SymbolZOrder.testConstantValue())
    }

}

extension SymbolZOrder {
    
  static func testConstantValue() -> SymbolZOrder {
     return SymbolZOrder.init(rawValue: "auto")!
  }

}
// MARK: TEXT_ANCHOR

extension Value where T == TextAnchor {
    
    static func testConstantValue() -> Value<TextAnchor> {
       return .constant(TextAnchor.testConstantValue())
    }

}

extension TextAnchor {
    
  static func testConstantValue() -> TextAnchor {
     return TextAnchor.init(rawValue: "center")!
  }

}
// MARK: TEXT_JUSTIFY

extension Value where T == TextJustify {
    
    static func testConstantValue() -> Value<TextJustify> {
       return .constant(TextJustify.testConstantValue())
    }

}

extension TextJustify {
    
  static func testConstantValue() -> TextJustify {
     return TextJustify.init(rawValue: "auto")!
  }

}
// MARK: TEXT_PITCH_ALIGNMENT

extension Value where T == TextPitchAlignment {
    
    static func testConstantValue() -> Value<TextPitchAlignment> {
       return .constant(TextPitchAlignment.testConstantValue())
    }

}

extension TextPitchAlignment {
    
  static func testConstantValue() -> TextPitchAlignment {
     return TextPitchAlignment.init(rawValue: "map")!
  }

}
// MARK: TEXT_ROTATION_ALIGNMENT

extension Value where T == TextRotationAlignment {
    
    static func testConstantValue() -> Value<TextRotationAlignment> {
       return .constant(TextRotationAlignment.testConstantValue())
    }

}

extension TextRotationAlignment {
    
  static func testConstantValue() -> TextRotationAlignment {
     return TextRotationAlignment.init(rawValue: "map")!
  }

}
// MARK: TEXT_TRANSFORM

extension Value where T == TextTransform {
    
    static func testConstantValue() -> Value<TextTransform> {
       return .constant(TextTransform.testConstantValue())
    }

}

extension TextTransform {
    
  static func testConstantValue() -> TextTransform {
     return TextTransform.init(rawValue: "none")!
  }

}
// MARK: FILL_TRANSLATE_ANCHOR

extension Value where T == FillTranslateAnchor {
    
    static func testConstantValue() -> Value<FillTranslateAnchor> {
       return .constant(FillTranslateAnchor.testConstantValue())
    }

}

extension FillTranslateAnchor {
    
  static func testConstantValue() -> FillTranslateAnchor {
     return FillTranslateAnchor.init(rawValue: "map")!
  }

}
// MARK: LINE_TRANSLATE_ANCHOR

extension Value where T == LineTranslateAnchor {
    
    static func testConstantValue() -> Value<LineTranslateAnchor> {
       return .constant(LineTranslateAnchor.testConstantValue())
    }

}

extension LineTranslateAnchor {
    
  static func testConstantValue() -> LineTranslateAnchor {
     return LineTranslateAnchor.init(rawValue: "map")!
  }

}
// MARK: ICON_TRANSLATE_ANCHOR

extension Value where T == IconTranslateAnchor {
    
    static func testConstantValue() -> Value<IconTranslateAnchor> {
       return .constant(IconTranslateAnchor.testConstantValue())
    }

}

extension IconTranslateAnchor {
    
  static func testConstantValue() -> IconTranslateAnchor {
     return IconTranslateAnchor.init(rawValue: "map")!
  }

}
// MARK: TEXT_TRANSLATE_ANCHOR

extension Value where T == TextTranslateAnchor {
    
    static func testConstantValue() -> Value<TextTranslateAnchor> {
       return .constant(TextTranslateAnchor.testConstantValue())
    }

}

extension TextTranslateAnchor {
    
  static func testConstantValue() -> TextTranslateAnchor {
     return TextTranslateAnchor.init(rawValue: "map")!
  }

}
// MARK: CIRCLE_PITCH_ALIGNMENT

extension Value where T == CirclePitchAlignment {
    
    static func testConstantValue() -> Value<CirclePitchAlignment> {
       return .constant(CirclePitchAlignment.testConstantValue())
    }

}

extension CirclePitchAlignment {
    
  static func testConstantValue() -> CirclePitchAlignment {
     return CirclePitchAlignment.init(rawValue: "map")!
  }

}
// MARK: CIRCLE_PITCH_SCALE

extension Value where T == CirclePitchScale {
    
    static func testConstantValue() -> Value<CirclePitchScale> {
       return .constant(CirclePitchScale.testConstantValue())
    }

}

extension CirclePitchScale {
    
  static func testConstantValue() -> CirclePitchScale {
     return CirclePitchScale.init(rawValue: "map")!
  }

}
// MARK: CIRCLE_TRANSLATE_ANCHOR

extension Value where T == CircleTranslateAnchor {
    
    static func testConstantValue() -> Value<CircleTranslateAnchor> {
       return .constant(CircleTranslateAnchor.testConstantValue())
    }

}

extension CircleTranslateAnchor {
    
  static func testConstantValue() -> CircleTranslateAnchor {
     return CircleTranslateAnchor.init(rawValue: "map")!
  }

}
// MARK: FILL_EXTRUSION_TRANSLATE_ANCHOR

extension Value where T == FillExtrusionTranslateAnchor {
    
    static func testConstantValue() -> Value<FillExtrusionTranslateAnchor> {
       return .constant(FillExtrusionTranslateAnchor.testConstantValue())
    }

}

extension FillExtrusionTranslateAnchor {
    
  static func testConstantValue() -> FillExtrusionTranslateAnchor {
     return FillExtrusionTranslateAnchor.init(rawValue: "map")!
  }

}
// MARK: RASTER_RESAMPLING

extension Value where T == RasterResampling {
    
    static func testConstantValue() -> Value<RasterResampling> {
       return .constant(RasterResampling.testConstantValue())
    }

}

extension RasterResampling {
    
  static func testConstantValue() -> RasterResampling {
     return RasterResampling.init(rawValue: "linear")!
  }

}
// MARK: HILLSHADE_ILLUMINATION_ANCHOR

extension Value where T == HillshadeIlluminationAnchor {
    
    static func testConstantValue() -> Value<HillshadeIlluminationAnchor> {
       return .constant(HillshadeIlluminationAnchor.testConstantValue())
    }

}

extension HillshadeIlluminationAnchor {
    
  static func testConstantValue() -> HillshadeIlluminationAnchor {
     return HillshadeIlluminationAnchor.init(rawValue: "map")!
  }

}
// MARK: SKY_TYPE

extension Value where T == SkyType {
    
    static func testConstantValue() -> Value<SkyType> {
       return .constant(SkyType.testConstantValue())
    }

}

extension SkyType {
    
  static func testConstantValue() -> SkyType {
     return SkyType.init(rawValue: "gradient")!
  }

}
// MARK: ANCHOR

extension Value where T == Anchor {
    
    static func testConstantValue() -> Value<Anchor> {
       return .constant(Anchor.testConstantValue())
    }

}

extension Anchor {
    
  static func testConstantValue() -> Anchor {
     return Anchor.init(rawValue: "map")!
  }

}
// MARK: TEXT_WRITING_MODE

extension Value where T == TextWritingMode {
    
    static func testConstantValue() -> Value<TextWritingMode> {
       return .constant(TextWritingMode.testConstantValue())
    }

}

extension TextWritingMode {
    
  static func testConstantValue() -> TextWritingMode {
     return TextWritingMode.init(rawValue: "horizontal")!
  }

}
// End of generated file.
// swiftlint:enable all