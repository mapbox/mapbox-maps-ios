import UIKit

/// Map color theme.
///
/// A color theme modifies the global colors of a style using a LUT (lookup table) for color grading.
/// To use a custom color theme, provide a LUT image. The image must be ≤32 pixels in height and have a width equal to the square of its height.
///
/// Pass the image either as a base64-encoded string:
/// ```swift
/// let mapView = MapView()
/// mapView.mapboxMap.setMapStyleContent {
///     ColorTheme(base64: "base64EncodedImage")
/// }
/// ```
///
/// Or as a `UIImage` for easier asset integration:
/// ```swift
/// let mapView = MapView()
/// let lutImage = UIImage(named: "monochrome_lut")!
/// mapView.mapboxMap.setMapStyleContent {
///     ColorTheme(uiimage: lutImage)
/// }
/// ```
///
/// Note: Each style can have only one `ColorTheme`. Setting a new theme overwrites the previous one.
/// Additional information [Mapbox Style Specification](https://docs.mapbox.com/style-spec/reference/root/#color-theme)
@_documentation(visibility: public)
@_spi(Experimental)
public struct ColorTheme: Equatable {
    var base64: StylePropertyValue?
    var uiimage: UIImage?

    /// Creates a ``ColorTheme`` using base64 encoded LUT image.
    ///
    /// - Important: Image height must be less or equal to 32 pixels and width of the image should be equal to the height squared.
    /// - Parameters:
    ///   - base64: base64 encoded LUT image.
    public init(base64: String) {
        self.base64 = StylePropertyValue(value: base64, kind: .constant)
        self.uiimage = nil
    }

    /// Creates a ``ColorTheme`` using base64 encoded LUT image.
    ///
    /// - Important: Image height must be less or equal to 32 pixels and width of the image should be equal to the height squared.
    /// - Parameters:
    ///   - base64: base64 encoded LUT image.
    public init(base64: Exp) {
        self.base64 = base64.asCore.flatMap { StylePropertyValue(value: $0, kind: .expression) }
        self.uiimage = nil
    }

    /// Creates a ``ColorTheme`` using base64 encoded LUT image.
    ///
    /// - Important: Image height must be less or equal to 32 pixels and width of the image should be equal to the height squared.
    /// - Parameters:
    ///   - uiimage: UIImage instance which represents color grading LUT.
    public init(uiimage: UIImage) {
        self.uiimage = uiimage
        self.base64 = nil
    }
}

@available(iOS 13.0, *)
extension ColorTheme: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedUniqueProperty(keyPath: \.colorTheme, value: self))
    }
}

extension ColorTheme {
    var core: CoreColorTheme? {
        if let base64 {
            return .fromStylePropertyValue(base64)
        } else if let uiimage, let coreImage = CoreMapsImage(uiImage: uiimage) {
            return .fromImage(coreImage)
        } else {
            return nil
        }
    }
}
