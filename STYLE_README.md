# Style

In v10 SDK, the style API is directly aligned with the Mapbox Style Specification. `Sources`, `Layers`, `Light` all work in the exact same manner as in the Style Specification.

The `Style` object in the `MapViewController` is responsible for all run time styling related functionality.

### Type-safe API
Every `Source` and `Layer` declared in the Style Specification exists in v10 as a simple Swift struct. Furthermore, every property within those sources and layers is modeled using familiar swift types. This means that creating new sources and layers are easy!

##### GeoJSON Source Example
For example, a simple GeoJSON source can be created by the following code. We can set properties on this source (with the help of the full power of Xcode's autocomplete) as we would expect too!

```swift
var myGeoJSONSource = GeoJSONSource()
myGeoJSONSource.maxZoom = 14.0
```

GeoJSON sources have a `data` property that can be set to either a `url` or inline geojson. The swift struct representing a GeoJSON source is modeled 1:1 with this expectation.

The SDK uses [Turf-swift](https://github.com/mapbox/turf-swift) to model geojson. So crafting geojson at runtime becomes straightforward and is backed by the type-safety that Turf provides.

```swift
// Setting the `data` property with a url pointing to a geojson document
myGeoJSONSource.data = .url(URL(string: "<path-to-geojson-file>"))

// Setting a Turf feature to the `data` property
myGeoJSONSource.data = .featureCollection(someTurfFeatureCollection)
```

Having created a source, adding it to map is simple. The `MapViewController` holds a `style` object that can be used to add, remove or update sources and layers.

```swift
self.mapViewController.addSource(myGeoJSONSource)
```

##### Background Layer Example
Let's add a simple background layer to further demonstrate the type-safety provided in v10.

As mentioned earlier, all Layers are also simple Swift structs. The following code sets up a background layer and sets its background color to red.

```swift
var myBackgroundLayer = BackgroundLayer(id: "my-background-layer")
myBackgroundLayer.paint?.backgroundColor = .constant(StyleColor(.red))
```

Adding a layer to the map is similar to the way we added sources above:
```swift
self.mapViewController.addLayer(myBackgroundLayer)
```

### What about Expressions?

In the Background Layer example above, we set a constant value to the `backgroundColor` porperty of the layer. However, the `backgroundColor` property (and nearly all layout and paint properties) support expressions too!

Fortunately, the SDK is flexible enough to handle both expressions and constants. Moreover, expressions have been redesigned from the ground up in v10. Instead of using `NSExpression` to represent expressions, the new Expression DSL directly models expressions based on the Mapbox Style Specification.

In v10, expressions now exist as simple, familiar and type-safe Swift structs. They are also backed by Swift function-builders to make the experience of writing an expression similar to the way SwiftUI works.

Consider a simple `interpolate` expression written in raw JSON:
```json
[
  "interpolate",
  ["linear"],
  ["zoom"],
  0,
  "hsl(0, 79%, 53%)",
  14,
  "hsl(233, 80%, 47%)"
]
```

In v10, this can be translated to Swift like so:

```swift
Exp(.interpolate) {
    Exp(.linear)
    Exp(.zoom)
    0
    UIColor.red
    14
    UIColor.blue
}
```

You also have the full power of Swift and the iOS runtime when defining this expression. So let's assume that you want to tweak this expression based on whether the user has dark mode enabled. Doing so becomes straightforward:

```swift
var isDarkModeEnabled = traitCollection.userInterfaceStyle == .dark

Exp(.interpolate) {
    Exp(.linear)
    Exp(.zoom)
    0
    isDarkModeEnabled ? UIColor.black : UIColor.red
    14
    isDarkModeEnabled ? UIColor.grey : UIColor.blue
}

```

#### Composable expressions
In v10, Expressions can also be composed and built in modular ways.

```swift
Exp(.interpolate) {
    Exp(.linear)
    Exp(.zoom)
    Exp(.subtract) {
        10
        3
    }
    UIColor.red
    Exp(.sum) {
        7
        7
    }
    UIColor.blue
}
```

#### Other Expression Examples
- This (example)[Apps/Examples/Examples/All%20Examples/DataDrivenSymbolsExample.swift#L74] highlights the use of a match, and a switchcase expression
