# Mapbox Maps SDK v11 for iOS

## Xcode Installation Instructions

1. Please drag the following 5 XCFrameworks (included in this archive) to your
   Xcode project and add them to your application target.

    - `MapboxCommon.xcframework`
    - `MapboxCoreMaps.xcframework`
    - `MapboxMaps.xcframework`
    - `Turf.xcframework`

2. On the General tab for the target, scroll to the section labeled "Frameworks,
   Libraries and Embedded Content".

3. Ensure `Embed` is set to "Do Not Embed" for all 5 linked XCFrameworks

4. Configure your application to link with `libz`, `libsqlite3`, and `libc++` by
   clicking on the '+' button at the bottom of the "Frameworks, Libraries and
   Embedded Content" list, selecting `libz.tbd`, clicking "Add", and
   the repeating these steps for `libsqlite3.tbd` and `libc++.tbd`.

5. On the Build Settings tab for the target, find the "Other Linker Flags"
   setting. Add the value `-ObjC` to the list of values for the target. You may
   also want to add `$(inherited)` to ensure that any values for this setting
   from the project or from configuration files are not overwritten.

6. Add `import MapboxMaps` to your Swift source file.

7. Please see the [Migration Guide](https://docs.mapbox.com/ios/maps/guides/migrate-to-v11/)
   for further guidelines.
