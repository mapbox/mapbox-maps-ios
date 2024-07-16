// This file is generated.
// swiftlint:disable file_length
import Foundation
@testable import MapboxMaps

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
        return .butt
    }

    static func random() -> LineCap {
        let allCases: [LineCap] = [.butt, .round, .square]
        return allCases.randomElement()!
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
        return .bevel
    }

    static func random() -> LineJoin {
        let allCases: [LineJoin] = [.bevel, .round, .miter, .none]
        return allCases.randomElement()!
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
        return .center
    }

    static func random() -> IconAnchor {
        let allCases: [IconAnchor] = [.center, .left, .right, .top, .bottom, .topLeft, .topRight, .bottomLeft, .bottomRight]
        return allCases.randomElement()!
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
        return .map
    }

    static func random() -> IconPitchAlignment {
        let allCases: [IconPitchAlignment] = [.map, .viewport, .auto]
        return allCases.randomElement()!
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
        return .map
    }

    static func random() -> IconRotationAlignment {
        let allCases: [IconRotationAlignment] = [.map, .viewport, .auto]
        return allCases.randomElement()!
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
        return .none
    }

    static func random() -> IconTextFit {
        let allCases: [IconTextFit] = [.none, .width, .height, .both]
        return allCases.randomElement()!
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
        return .point
    }

    static func random() -> SymbolPlacement {
        let allCases: [SymbolPlacement] = [.point, .line, .lineCenter]
        return allCases.randomElement()!
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
        return .auto
    }

    static func random() -> SymbolZOrder {
        let allCases: [SymbolZOrder] = [.auto, .viewportY, .source]
        return allCases.randomElement()!
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
        return .center
    }

    static func random() -> TextAnchor {
        let allCases: [TextAnchor] = [.center, .left, .right, .top, .bottom, .topLeft, .topRight, .bottomLeft, .bottomRight]
        return allCases.randomElement()!
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
        return .auto
    }

    static func random() -> TextJustify {
        let allCases: [TextJustify] = [.auto, .left, .center, .right]
        return allCases.randomElement()!
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
        return .map
    }

    static func random() -> TextPitchAlignment {
        let allCases: [TextPitchAlignment] = [.map, .viewport, .auto]
        return allCases.randomElement()!
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
        return .map
    }

    static func random() -> TextRotationAlignment {
        let allCases: [TextRotationAlignment] = [.map, .viewport, .auto]
        return allCases.randomElement()!
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
        return .none
    }

    static func random() -> TextTransform {
        let allCases: [TextTransform] = [.none, .uppercase, .lowercase]
        return allCases.randomElement()!
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
        return .map
    }

    static func random() -> FillTranslateAnchor {
        let allCases: [FillTranslateAnchor] = [.map, .viewport]
        return allCases.randomElement()!
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
        return .map
    }

    static func random() -> LineTranslateAnchor {
        let allCases: [LineTranslateAnchor] = [.map, .viewport]
        return allCases.randomElement()!
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
        return .map
    }

    static func random() -> IconTranslateAnchor {
        let allCases: [IconTranslateAnchor] = [.map, .viewport]
        return allCases.randomElement()!
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
        return .map
    }

    static func random() -> TextTranslateAnchor {
        let allCases: [TextTranslateAnchor] = [.map, .viewport]
        return allCases.randomElement()!
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
        return .map
    }

    static func random() -> CirclePitchAlignment {
        let allCases: [CirclePitchAlignment] = [.map, .viewport]
        return allCases.randomElement()!
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
        return .map
    }

    static func random() -> CirclePitchScale {
        let allCases: [CirclePitchScale] = [.map, .viewport]
        return allCases.randomElement()!
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
        return .map
    }

    static func random() -> CircleTranslateAnchor {
        let allCases: [CircleTranslateAnchor] = [.map, .viewport]
        return allCases.randomElement()!
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
        return .map
    }

    static func random() -> FillExtrusionTranslateAnchor {
        let allCases: [FillExtrusionTranslateAnchor] = [.map, .viewport]
        return allCases.randomElement()!
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
        return .linear
    }

    static func random() -> RasterResampling {
        let allCases: [RasterResampling] = [.linear, .nearest]
        return allCases.randomElement()!
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
        return .map
    }

    static func random() -> HillshadeIlluminationAnchor {
        let allCases: [HillshadeIlluminationAnchor] = [.map, .viewport]
        return allCases.randomElement()!
    }
}

// MARK: MODEL_SCALE_MODE

extension Value where T == ModelScaleMode {
    static func testConstantValue() -> Value<ModelScaleMode> {
        return .constant(ModelScaleMode.testConstantValue())
    }
}

extension ModelScaleMode {
    static func testConstantValue() -> ModelScaleMode {
        return .map
    }

    static func random() -> ModelScaleMode {
        let allCases: [ModelScaleMode] = [.map, .viewport]
        return allCases.randomElement()!
    }
}

// MARK: MODEL_TYPE

extension Value where T == ModelType {
    static func testConstantValue() -> Value<ModelType> {
        return .constant(ModelType.testConstantValue())
    }
}

extension ModelType {
    static func testConstantValue() -> ModelType {
        return .common3d
    }

    static func random() -> ModelType {
        let allCases: [ModelType] = [.common3d, .locationIndicator]
        return allCases.randomElement()!
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
        return .gradient
    }

    static func random() -> SkyType {
        let allCases: [SkyType] = [.gradient, .atmosphere]
        return allCases.randomElement()!
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
        return .map
    }

    static func random() -> Anchor {
        let allCases: [Anchor] = [.map, .viewport]
        return allCases.randomElement()!
    }
}

// MARK: NAME

extension Value where T == StyleProjectionName {
    static func testConstantValue() -> Value<StyleProjectionName> {
        return .constant(StyleProjectionName.testConstantValue())
    }
}

extension StyleProjectionName {
    static func testConstantValue() -> StyleProjectionName {
        return .mercator
    }

    static func random() -> StyleProjectionName {
        let allCases: [StyleProjectionName] = [.mercator, .globe]
        return allCases.randomElement()!
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
        return .horizontal
    }

    static func random() -> TextWritingMode {
        let allCases: [TextWritingMode] = [.horizontal, .vertical]
        return allCases.randomElement()!
    }
}

// MARK: CLIP_LAYER_TYPES

extension Value where T == ClipLayerTypes {
    static func testConstantValue() -> Value<ClipLayerTypes> {
        return .constant(ClipLayerTypes.testConstantValue())
    }
}

extension ClipLayerTypes {
    static func testConstantValue() -> ClipLayerTypes {
        return .model
    }

    static func random() -> ClipLayerTypes {
        let allCases: [ClipLayerTypes] = [.model, .symbol]
        return allCases.randomElement()!
    }
}
// End of generated file.
