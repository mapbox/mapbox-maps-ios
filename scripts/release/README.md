# Maps SDK for iOS v10.0 (Carbon)

## Xcode Installation Instructions

1. Please drag the following 5 `xcframework`s (included with this package) to your Xcode project and add them to your application Target.

    - `MapboxCommon.xcframework`
    - `MapboxCoreMaps.xcframework`
    - `MapboxMaps.xcframework`
    - `MapboxMobileEvents.xcframework`
    - `Turf.xcframework`

2. On the General tab for the Target, scroll to the section labeled "Frameworks, Libraries and Embedded Content".

3. Change `Embed` from "Do Not Embed" to "Embed & Sign" for all 5 linked xcframeworks

4. Add `import MapboxMaps` to your Swift source file. At this time, depending on the API you may need to include `import MapboxCoreMaps` and/or `import MapboxCommon` too.

5. Please see the Migration Guide for further guidelines.
