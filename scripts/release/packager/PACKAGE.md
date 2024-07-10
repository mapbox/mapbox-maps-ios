# Packaging MapboxMaps.xcframework

This folder contains scripts that package `MapboxMaps` and its dependencies as a
zipped archive of XCFrameworks.

## Requirements

- [`jq`](https://stedolan.github.io/jq/)
- [`xcodegen`](https://github.com/yonaskolb/XcodeGen)
- Valid `.netrc` token for SDK registry

## Scripts

### `package-mapbox-maps.sh`

- Usage:
  ```
  ./package-mapbox-maps.sh
  ```
- This is the master script and is the only one you should need to call.
- It reads the dependency versions from `versions.json` and begins by
  downloading previously built XCFrameworks & cloning and building any other
  XCFrameworks (currently `Turf`).
- It also creates a just-in-time Xcode project in order to create a binary
  XCFramework for `MapboxMaps`.
- It will also then add the LICENSE.md and appropriate README.md to the package.
- Finally, it will zip that folder so everything will be in one bundle
- NOTE: This script **MUST** be called from this directory

### `create-xcframework.sh`

- Usage:
  ```
  ./create-xcframework.sh <PROJECT_PATH> <SCHEME> <PRODUCT_NAME>
  ```
- Generic script to create an xcframework for a project located at the specified path.
- Uses `xcodebuild`

### `project.yml`

- This `yml` is parsed by [`xcodegen`](https://github.com/yonaskolb/XcodeGen) to
  create a just-in-time Xcode project that contains all the sources used in
  `MapboxMaps`.

### `versions.json`

- This is the "source of truth" that is used to download the correct dependency
  versions
- Must be updated for each release.
