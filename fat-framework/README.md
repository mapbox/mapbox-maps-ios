# Fat Framework Script

The fat framework script converts a collection of XCFrameworks into a
corresponding collection of fat frameworks. The resulting fat framework
contains an arm64 slice for iphoneos and an x86_64 slice for iphonesimulator.
[From Xcode’s perspective iOS and the iOS simulator are two different
platforms](https://developer.apple.com/forums/thread/109583), so combining
these slices into a single framework has never been supported by Apple, however
some customers may require this capability if they use build systems that do
not yet support XCFrameworks.

## Usage

1. Download the zip archive of the Maps SDK from SDK Registry
2. Navigate to the root of this directory.
3. Run `$ ./create-maps-frameworks.swift <zip_archive_path>`
4. The resulting frameworks will be located in the directory
   `MapboxMapsFrameworks`

This script works for both static and dynamic SDK variants:

* If the input zip archive contains dynamic XCFrameworks, the result is a set of
  dynamic fat frameworks.
* If the input zip archive contains static XCFrameworks, the result is a set of
  static fat frameworks.
