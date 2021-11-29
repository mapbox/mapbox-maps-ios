# Mapbox Maps SDK v10 for iOS

## Xcode Installation Instructions

1. Please drag the following 5 XCFrameworks (included in this archive) to your
   Xcode project and add them to your application target.

    - `MapboxCommon.xcframework`
    - `MapboxCoreMaps.xcframework`
    - `MapboxMaps.xcframework`
    - `MapboxMobileEvents.xcframework`
    - `Turf.xcframework`

2. On the General tab for the target, scroll to the section labeled "Frameworks,
   Libraries and Embedded Content".

3. Ensure `Embed` is set to "Embed & Sign" for all 5 linked XCFrameworks.

4. Add `import MapboxMaps` to your Swift source file.

5. Please see the [Migration Guide](https://docs.mapbox.com/ios/maps/guides/migrate-to-v10/)
   for further guidelines.
