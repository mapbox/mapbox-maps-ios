## Known Issues

### Annotations
* Annotation selection may have a false positive if the selection of an annotation occurs on the edge of the display.
* Point, line, and polygon colors cannot be customized.
* Annotation interaction cannot be disabled.
* Point annotations may not be rendered when `PointAnnotation.properties` is non-nil.

### Camera
* The camera can jump while pinching or panning.

### Ornaments
* Unable to toggle `scaleBar` and `compass` visibility.
* Ornaments do not reposition after navigation bar is displayed.

### Style
* An `NSException` can occur when accessing symbol style layers that contain a value for `textField` using `Style.getLayer()`.