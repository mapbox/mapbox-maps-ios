import UIKit

// This file contains old methods that were public before rich type support.

extension CircleAnnotationGroup {
    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    @available(*, deprecated, renamed: "circleTranslate(x:y:)")
    public func circleTranslate(_ newValue: [Double]) -> Self {
        if newValue.count == 2 {
            return circleTranslate(x: newValue[0], y: newValue[1])
        }
        return self
    }
}

extension PointAnnotationGroup {
    /// Offset distance of icon from its anchor. Positive values indicate right and down, while negative values indicate left and up. Each component is multiplied by the value of `icon-size` to obtain the final offset in pixels. When combined with `icon-rotate` the offset will be as if the rotated direction was up.
        /// Default value: [0,0].
    @available(*, deprecated, renamed: "iconOffset(x:y:)")
    public func iconOffset(_ newValue: [Double]) -> Self {
        if newValue.count == 2 {
            return iconOffset(x: newValue[0], y: newValue[1])
        }
        return self
    }

    /// Offset distance of text from its anchor. Positive values indicate right and down, while negative values indicate left and up. If used with text-variable-anchor, input values will be taken as absolute values. Offsets along the x- and y-axis will be applied automatically based on the anchor position.
    @available(*, deprecated, renamed: "textOffset(x:y:)")
    public func textOffset(_ newValue: [Double]) -> Self {
        if newValue.count == 2 {
            return textOffset(x: newValue[0], y: newValue[1])
        }
        return self
    }

    /// Distance that the icon's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    @available(*, deprecated, renamed: "iconTranslate(x:y:)")
    public func iconTranslate(_ newValue: [Double]) -> Self {
        if newValue.count == 2 {
            return iconTranslate(x: newValue[0], y: newValue[1])
        }
        return self
    }

    /// Distance that the text's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    @available(*, deprecated, renamed: "textTranslate(x:y:)")
    public func textTranslate(_ newValue: [Double]) -> Self {
        if newValue.count == 2 {
            return textTranslate(x: newValue[0], y: newValue[1])
        }
        return self
    }

    /// Size of the additional area added to dimensions determined by `icon-text-fit`, in clockwise order: top, right, bottom, left.
    /// Default value: [0,0,0,0].
    @available(*, deprecated, message: "Use UIEdgeInsets instead of array")
    public func iconTextFitPadding(_ newValue: [Double]) -> Self {
        if newValue.count == 4 {
            return iconTextFitPadding(UIEdgeInsets(top: newValue[0], left: newValue[3], bottom: newValue[2], right: newValue[1]))
        }
        return self
    }
}

extension PolygonAnnotationGroup {
    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    @available(*, deprecated, renamed: "fillTranslate(x:y:)")
    public func fillTranslate(_ newValue: [Double]) -> Self {
        if newValue.count == 2 {
            return fillTranslate(x: newValue[0], y: newValue[1])
        }
        return self
    }
}

extension PolylineAnnotationGroup {
    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    @available(*, deprecated, renamed: "lineTranslate(x:y:)")
    public func lineTranslate(_ newValue: [Double]) -> Self {
        if newValue.count == 2 {
            return lineTranslate(x: newValue[0], y: newValue[1])
        }
        return self
    }

    /// Default value: [0,0]. Minimum value: [0,0]. Maximum value: [1,1].
    @available(*, deprecated, renamed: "lineTrimFadeRange(start:end:)")
    public func lineTrimFadeRange(_ newValue: [Double]) -> Self {
        if newValue.count == 2 {
            return lineTrimFadeRange(start: newValue[0], end: newValue[1])
        }
        return self
    }

    /// The line part between [trim-start, trim-end] will be painted using `line-trim-color,` which is transparent by default to produce a route vanishing effect. The line trim-off offset is based on the whole line range [0.0, 1.0].
    /// Default value: [0,0]. Minimum value: [0,0]. Maximum value: [1,1].
    @available(*, deprecated, renamed: "lineTrimOffset(start:end:)")
    public func lineTrimOffset(_ newValue: [Double]) -> Self {
        if newValue.count == 2 {
            return lineTrimOffset(start: newValue[0], end: newValue[1])
        }
        return self
    }
}
