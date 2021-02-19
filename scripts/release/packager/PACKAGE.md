# Packaging MapboxMaps.xcframework
This folder contains scripts that package `MapboxMaps` and its dependencies as a zipped archive of XCFrameworks.

## Requirements
- [`jq`](https://stedolan.github.io/jq/)
- [`xcodegen`](https://github.com/yonaskolb/XcodeGen) 
- valid `.netrc` token for sdk registry

Descriptions of the files in this directory is as follows:

### `package-mapbox-maps-xcframework.sh`
- This is the master script and is the only one you should need to call.
- It reads the dependency versions from `versions.json` and begins by downloading previously built XCFrameworks & cloning and building any other XCFrameworks (currently `Turf`).
- It also creates a just-in-time Xcode project in order to create a binary XCFramework for `MapboxMaps`.
- NOTE: This script **MUST** be called from this directory 

### `download-dependency-xcframeworks.sh`
- This script downloads `MapboxCoreMaps.xcframework`, `MapboxCommon.xcframework` and `MapboxMobileEvents.xcframework` from SDK Registry
- NOTE: You **MUST** have a valid `.netrc` token

### `create-turf-xcframework.sh`
- This script clones `turf-swift`, checks out the git tag represented in `versions.json` and then creates `Turf.xcframework`.

### `create-mapbox-maps-xcframework.sh`
- Helper script to archive and build `MapboxMaps.xcframework`
- Uses `xcodebuild`

### `project.yml`
- This `yml` is parsed by [`xcodegen`](https://github.com/yonaskolb/XcodeGen) to create a just-in-time Xcode project that contains all the sources used in `MapboxMaps`.

### `versions.json`
- This is the "source of truth" that is used to download the correct dependency versions
- Must be updated for each release.
