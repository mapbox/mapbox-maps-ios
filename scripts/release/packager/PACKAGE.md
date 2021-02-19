# Packaging MapboxMaps.xcframework
This folder contains scripts that package `MapboxMaps` as an xcframework.

## Requirements
- [`jq`](https://stedolan.github.io/jq/)
- [`xcodegen`](https://github.com/yonaskolb/XcodeGen) 
- valid `.netrc` token for sdk registry

Descriptions of the files in this directory is as follows:

### `package-mapbox-maps-xcframework.sh`
- This is the master script and is the only one you should need to call.
- It reads the dependency versions from `versions.json` and begins by downloading previously built xcframeworks & cloning and building any other xcframeworks (currently `Turf`).
- It also creates a just-in-time xcodeproj in order to create a binary xcframework for `MapboxMaps`.
- NOTE: This script **MUST** be called from this directory 

### `download-dependency-xcframeworks.sh`
- This script downloads `MapboxCoreMaps.xcframework`, `MapboxCommon.xcframework` and `MapboxMobileEvents.xcframework` from SDK Registry
- NOTE: You **MUST** have a valid `.netrc` token

### `create-turf-xcframework.sh`
- This script clones `turf-swift`, checks out the git tag represented in `versions.json` and then creates a `Turf.xcframework`.


### `create-mapbox-maps-xcframework.sh`
- Helper script to archive and build `MapboxMaps.xcframework`
- Uses `xcodebuild`

### `project.yml`
- This `yml` is parsed by [`xcodegen`](https://github.com/yonaskolb/XcodeGen) to create a just-in-time xcodeproj that should contain all the sources used in `MapboxMaps`.

### `versions.json`
- This is the "source of truth" that is used to download/build the correct dependency versions
- Must be updated for each release.