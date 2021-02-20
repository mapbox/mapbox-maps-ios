// This file is generated.
// swiftlint:disable all
import Foundation

public enum Visibility: String, Codable {

	/// The layer is shown.
	case visible
	
	/// The layer is not shown.
	case none
	
	enum CodingKeys: String, CodingKey {
		case visible = "visible"
		case none = "none"
	  
	}
}


// MARK: LINE_CAP

/// The display of line endings.
public enum LineCap: String, Codable {

  /// A cap with a squared-off end which is drawn to the exact endpoint of the line.
  case butt
  
  /// A cap with a rounded end which is drawn beyond the endpoint of the line at a radius of one-half of the line's width and centered on the endpoint of the line.
  case round
  
  /// A cap with a squared-off end which is drawn beyond the endpoint of the line at a distance of one-half of the line's width.
  case square
  
  enum CodingKeys: String, CodingKey {
      case butt = "butt"
      case round = "round"
      case square = "square"
    
  } 
}
// MARK: LINE_JOIN

/// The display of lines when joining.
public enum LineJoin: String, Codable {

  /// A join with a squared-off end which is drawn beyond the endpoint of the line at a distance of one-half of the line's width.
  case bevel
  
  /// A join with a rounded end which is drawn beyond the endpoint of the line at a radius of one-half of the line's width and centered on the endpoint of the line.
  case round
  
  /// A join with a sharp, angled corner which is drawn with the outer sides beyond the endpoint of the path until they meet.
  case miter
  
  enum CodingKeys: String, CodingKey {
      case bevel = "bevel"
      case round = "round"
      case miter = "miter"
    
  } 
}
// MARK: ICON_ANCHOR

/// Part of the icon placed closest to the anchor.
public enum IconAnchor: String, Codable {

  /// The center of the icon is placed closest to the anchor.
  case center
  
  /// The left side of the icon is placed closest to the anchor.
  case left
  
  /// The right side of the icon is placed closest to the anchor.
  case right
  
  /// The top of the icon is placed closest to the anchor.
  case top
  
  /// The bottom of the icon is placed closest to the anchor.
  case bottom
  
  /// The top left corner of the icon is placed closest to the anchor.
  case topLeft
  
  /// The top right corner of the icon is placed closest to the anchor.
  case topRight
  
  /// The bottom left corner of the icon is placed closest to the anchor.
  case bottomLeft
  
  /// The bottom right corner of the icon is placed closest to the anchor.
  case bottomRight
  
  enum CodingKeys: String, CodingKey {
      case center = "center"
      case left = "left"
      case right = "right"
      case top = "top"
      case bottom = "bottom"
      case topLeft = "top-left"
      case topRight = "top-right"
      case bottomLeft = "bottom-left"
      case bottomRight = "bottom-right"
    
  } 
}
// MARK: ICON_PITCH_ALIGNMENT

/// Orientation of icon when map is pitched.
public enum IconPitchAlignment: String, Codable {

  /// The icon is aligned to the plane of the map.
  case map
  
  /// The icon is aligned to the plane of the viewport.
  case viewport
  
  /// Automatically matches the value of {@link ICON_ROTATION_ALIGNMENT}.
  case auto
  
  enum CodingKeys: String, CodingKey {
      case map = "map"
      case viewport = "viewport"
      case auto = "auto"
    
  } 
}
// MARK: ICON_ROTATION_ALIGNMENT

/// In combination with `symbol-placement`, determines the rotation behavior of icons.
public enum IconRotationAlignment: String, Codable {

  /// When {@link SYMBOL_PLACEMENT} is set to {@link Property#SYMBOL_PLACEMENT_POINT}, aligns icons east-west. When {@link SYMBOL_PLACEMENT} is set to {@link Property#SYMBOL_PLACEMENT_LINE} or {@link Property#SYMBOL_PLACEMENT_LINE_CENTER}, aligns icon x-axes with the line.
  case map
  
  /// Produces icons whose x-axes are aligned with the x-axis of the viewport, regardless of the value of {@link SYMBOL_PLACEMENT}.
  case viewport
  
  /// When {@link SYMBOL_PLACEMENT} is set to {@link Property#SYMBOL_PLACEMENT_POINT}, this is equivalent to {@link Property#ICON_ROTATION_ALIGNMENT_VIEWPORT}. When {@link SYMBOL_PLACEMENT} is set to {@link Property#SYMBOL_PLACEMENT_LINE} or {@link Property#SYMBOL_PLACEMENT_LINE_CENTER}, this is equivalent to {@link Property#ICON_ROTATION_ALIGNMENT_MAP}.
  case auto
  
  enum CodingKeys: String, CodingKey {
      case map = "map"
      case viewport = "viewport"
      case auto = "auto"
    
  } 
}
// MARK: ICON_TEXT_FIT

/// Scales the icon to fit around the associated text.
public enum IconTextFit: String, Codable {

  /// The icon is displayed at its intrinsic aspect ratio.
  case none
  
  /// The icon is scaled in the x-dimension to fit the width of the text.
  case width
  
  /// The icon is scaled in the y-dimension to fit the height of the text.
  case height
  
  /// The icon is scaled in both x- and y-dimensions.
  case both
  
  enum CodingKeys: String, CodingKey {
      case none = "none"
      case width = "width"
      case height = "height"
      case both = "both"
    
  } 
}
// MARK: SYMBOL_PLACEMENT

/// Label placement relative to its geometry.
public enum SymbolPlacement: String, Codable {

  /// The label is placed at the point where the geometry is located.
  case point
  
  /// The label is placed along the line of the geometry. Can only be used on LineString and Polygon geometries.
  case line
  
  /// The label is placed at the center of the line of the geometry. Can only be used on LineString and Polygon geometries. Note that a single feature in a vector tile may contain multiple line geometries.
  case lineCenter
  
  enum CodingKeys: String, CodingKey {
      case point = "point"
      case line = "line"
      case lineCenter = "line-center"
    
  } 
}
// MARK: SYMBOL_Z_ORDER

/// Determines whether overlapping symbols in the same layer are rendered in the order that they appear in the data source or by their y-position relative to the viewport. To control the order and prioritization of symbols otherwise, use `symbol-sort-key`.
public enum SymbolZOrder: String, Codable {

  /// Sorts symbols by symbol sort key if set. Otherwise, sorts symbols by their y-position relative to the viewport if {@link ICON_ALLOW_OVERLAP} or {@link TEXT_ALLOW_OVERLAP} is set to {@link TRUE} or {@link ICON_IGNORE_PLACEMENT} or {@link TEXT_IGNORE_PLACEMENT} is {@link FALSE}.
  case auto
  
  /// Sorts symbols by their y-position relative to the viewport if {@link ICON_ALLOW_OVERLAP} or {@link TEXT_ALLOW_OVERLAP} is set to {@link TRUE} or {@link ICON_IGNORE_PLACEMENT} or {@link TEXT_IGNORE_PLACEMENT} is {@link FALSE}.
  case viewportY
  
  /// Sorts symbols by symbol sort key if set. Otherwise, no sorting is applied; symbols are rendered in the same order as the source data.
  case source
  
  enum CodingKeys: String, CodingKey {
      case auto = "auto"
      case viewportY = "viewport-y"
      case source = "source"
    
  } 
}
// MARK: TEXT_ANCHOR

/// Part of the text placed closest to the anchor.
public enum TextAnchor: String, Codable {

  /// The center of the text is placed closest to the anchor.
  case center
  
  /// The left side of the text is placed closest to the anchor.
  case left
  
  /// The right side of the text is placed closest to the anchor.
  case right
  
  /// The top of the text is placed closest to the anchor.
  case top
  
  /// The bottom of the text is placed closest to the anchor.
  case bottom
  
  /// The top left corner of the text is placed closest to the anchor.
  case topLeft
  
  /// The top right corner of the text is placed closest to the anchor.
  case topRight
  
  /// The bottom left corner of the text is placed closest to the anchor.
  case bottomLeft
  
  /// The bottom right corner of the text is placed closest to the anchor.
  case bottomRight
  
  enum CodingKeys: String, CodingKey {
      case center = "center"
      case left = "left"
      case right = "right"
      case top = "top"
      case bottom = "bottom"
      case topLeft = "top-left"
      case topRight = "top-right"
      case bottomLeft = "bottom-left"
      case bottomRight = "bottom-right"
    
  } 
}
// MARK: TEXT_JUSTIFY

/// Text justification options.
public enum TextJustify: String, Codable {

  /// The text is aligned towards the anchor position.
  case auto
  
  /// The text is aligned to the left.
  case left
  
  /// The text is centered.
  case center
  
  /// The text is aligned to the right.
  case right
  
  enum CodingKeys: String, CodingKey {
      case auto = "auto"
      case left = "left"
      case center = "center"
      case right = "right"
    
  } 
}
// MARK: TEXT_PITCH_ALIGNMENT

/// Orientation of text when map is pitched.
public enum TextPitchAlignment: String, Codable {

  /// The text is aligned to the plane of the map.
  case map
  
  /// The text is aligned to the plane of the viewport.
  case viewport
  
  /// Automatically matches the value of {@link TEXT_ROTATION_ALIGNMENT}.
  case auto
  
  enum CodingKeys: String, CodingKey {
      case map = "map"
      case viewport = "viewport"
      case auto = "auto"
    
  } 
}
// MARK: TEXT_ROTATION_ALIGNMENT

/// In combination with `symbol-placement`, determines the rotation behavior of the individual glyphs forming the text.
public enum TextRotationAlignment: String, Codable {

  /// When {@link SYMBOL_PLACEMENT} is set to {@link Property#SYMBOL_PLACEMENT_POINT}, aligns text east-west. When {@link SYMBOL_PLACEMENT} is set to {@link Property#SYMBOL_PLACEMENT_LINE} or {@link Property#SYMBOL_PLACEMENT_LINE_CENTER}, aligns text x-axes with the line.
  case map
  
  /// Produces glyphs whose x-axes are aligned with the x-axis of the viewport, regardless of the value of {@link SYMBOL_PLACEMENT}.
  case viewport
  
  /// When {@link SYMBOL_PLACEMENT} is set to {@link Property#SYMBOL_PLACEMENT_POINT}, this is equivalent to {@link Property#TEXT_ROTATION_ALIGNMENT_VIEWPORT}. When {@link SYMBOL_PLACEMENT} is set to {@link Property#SYMBOL_PLACEMENT_LINE} or {@link Property#SYMBOL_PLACEMENT_LINE_CENTER}, this is equivalent to {@link Property#TEXT_ROTATION_ALIGNMENT_MAP}.
  case auto
  
  enum CodingKeys: String, CodingKey {
      case map = "map"
      case viewport = "viewport"
      case auto = "auto"
    
  } 
}
// MARK: TEXT_TRANSFORM

/// Specifies how to capitalize text, similar to the CSS `text-transform` property.
public enum TextTransform: String, Codable {

  /// The text is not altered.
  case none
  
  /// Forces all letters to be displayed in uppercase.
  case uppercase
  
  /// Forces all letters to be displayed in lowercase.
  case lowercase
  
  enum CodingKeys: String, CodingKey {
      case none = "none"
      case uppercase = "uppercase"
      case lowercase = "lowercase"
    
  } 
}
// MARK: FILL_TRANSLATE_ANCHOR

/// Controls the frame of reference for `fill-translate`.
public enum FillTranslateAnchor: String, Codable {

  /// The fill is translated relative to the map.
  case map
  
  /// The fill is translated relative to the viewport.
  case viewport
  
  enum CodingKeys: String, CodingKey {
      case map = "map"
      case viewport = "viewport"
    
  } 
}
// MARK: LINE_TRANSLATE_ANCHOR

/// Controls the frame of reference for `line-translate`.
public enum LineTranslateAnchor: String, Codable {

  /// The line is translated relative to the map.
  case map
  
  /// The line is translated relative to the viewport.
  case viewport
  
  enum CodingKeys: String, CodingKey {
      case map = "map"
      case viewport = "viewport"
    
  } 
}
// MARK: ICON_TRANSLATE_ANCHOR

/// Controls the frame of reference for `icon-translate`.
public enum IconTranslateAnchor: String, Codable {

  /// Icons are translated relative to the map.
  case map
  
  /// Icons are translated relative to the viewport.
  case viewport
  
  enum CodingKeys: String, CodingKey {
      case map = "map"
      case viewport = "viewport"
    
  } 
}
// MARK: TEXT_TRANSLATE_ANCHOR

/// Controls the frame of reference for `text-translate`.
public enum TextTranslateAnchor: String, Codable {

  /// The text is translated relative to the map.
  case map
  
  /// The text is translated relative to the viewport.
  case viewport
  
  enum CodingKeys: String, CodingKey {
      case map = "map"
      case viewport = "viewport"
    
  } 
}
// MARK: CIRCLE_PITCH_ALIGNMENT

/// Orientation of circle when map is pitched.
public enum CirclePitchAlignment: String, Codable {

  /// The circle is aligned to the plane of the map.
  case map
  
  /// The circle is aligned to the plane of the viewport.
  case viewport
  
  enum CodingKeys: String, CodingKey {
      case map = "map"
      case viewport = "viewport"
    
  } 
}
// MARK: CIRCLE_PITCH_SCALE

/// Controls the scaling behavior of the circle when the map is pitched.
public enum CirclePitchScale: String, Codable {

  /// Circles are scaled according to their apparent distance to the camera.
  case map
  
  /// Circles are not scaled.
  case viewport
  
  enum CodingKeys: String, CodingKey {
      case map = "map"
      case viewport = "viewport"
    
  } 
}
// MARK: CIRCLE_TRANSLATE_ANCHOR

/// Controls the frame of reference for `circle-translate`.
public enum CircleTranslateAnchor: String, Codable {

  /// The circle is translated relative to the map.
  case map
  
  /// The circle is translated relative to the viewport.
  case viewport
  
  enum CodingKeys: String, CodingKey {
      case map = "map"
      case viewport = "viewport"
    
  } 
}
// MARK: FILL_EXTRUSION_TRANSLATE_ANCHOR

/// Controls the frame of reference for `fill-extrusion-translate`.
public enum FillExtrusionTranslateAnchor: String, Codable {

  /// The fill extrusion is translated relative to the map.
  case map
  
  /// The fill extrusion is translated relative to the viewport.
  case viewport
  
  enum CodingKeys: String, CodingKey {
      case map = "map"
      case viewport = "viewport"
    
  } 
}
// MARK: RASTER_RESAMPLING

/// The resampling/interpolation method to use for overscaling, also known as texture magnification filter
public enum RasterResampling: String, Codable {

  /// (Bi)linear filtering interpolates pixel values using the weighted average of the four closest original source pixels creating a smooth but blurry look when overscaled
  case linear
  
  /// Nearest neighbor filtering interpolates pixel values using the nearest original source pixel creating a sharp but pixelated look when overscaled
  case nearest
  
  enum CodingKeys: String, CodingKey {
      case linear = "linear"
      case nearest = "nearest"
    
  } 
}
// MARK: HILLSHADE_ILLUMINATION_ANCHOR

/// Direction of light source when map is rotated.
public enum HillshadeIlluminationAnchor: String, Codable {

  /// The hillshade illumination is relative to the north direction.
  case map
  
  /// The hillshade illumination is relative to the top of the viewport.
  case viewport
  
  enum CodingKeys: String, CodingKey {
      case map = "map"
      case viewport = "viewport"
    
  } 
}
// MARK: SKY_TYPE

/// The type of the sky
public enum SkyType: String, Codable {

  /// Renders the sky with a gradient that can be configured with {@link SKY_GRADIENT_RADIUS} and {@link SKY_GRADIENT}.
  case gradient
  
  /// Renders the sky with a simulated atmospheric scattering algorithm, the sun direction can be attached to the light position or explicitly set through {@link SKY_ATMOSPHERE_SUN}.
  case atmosphere
  
  enum CodingKeys: String, CodingKey {
      case gradient = "gradient"
      case atmosphere = "atmosphere"
    
  } 
}
// MARK: ANCHOR

/// Whether extruded geometries are lit relative to the map or viewport.
public enum Anchor: String, Codable {

  /// The position of the light source is aligned to the rotation of the map.
  case map
  
  /// The position of the light source is aligned to the rotation of the viewport.
  case viewport
  
  enum CodingKeys: String, CodingKey {
      case map = "map"
      case viewport = "viewport"
    
  } 
}
// MARK: TEXT_WRITING_MODE

/// The property allows control over a symbol's orientation. Note that the property values act as a hint, so that a symbol whose language doesn’t support the provided orientation will be laid out in its natural orientation. Example: English point symbol will be rendered horizontally even if array value contains single 'vertical' enum value. The order of elements in an array define priority order for the placement of an orientation variant.
public enum TextWritingMode: String, Codable {

  /// If a text's language supports horizontal writing mode, symbols with point placement would be laid out horizontally.
  case horizontal
  
  /// If a text's language supports vertical writing mode, symbols with point placement would be laid out vertically.
  case vertical
  
  enum CodingKeys: String, CodingKey {
      case horizontal = "horizontal"
      case vertical = "vertical"
    
  } 
}

// // swiftlint:enable all
// End of generated file.
