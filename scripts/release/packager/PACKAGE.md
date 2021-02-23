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
  sh package-mapbox-maps.sh
  ```
- This is the master script and is the only one you should need to call.
- It reads the dependency versions from `versions.json` and begins by
  downloading previously built XCFrameworks & cloning and building any other
  XCFrameworks (currently `Turf`).
- It also creates a just-in-time Xcode project in order to create a binary
  XCFramework for `MapboxMaps`.
- NOTE: This script **MUST** be called from this directory

### `download-dependency.sh`
- Usage:
  ```
  sh download-dependency.sh <SDK_REGISTRY_NAME> <SDK_REGISTRY_ARTIFACT> <VERSION>
  ```
- This script downloads `MapboxCoreMaps.xcframework`, `MapboxCommon.xcframework`
  and `MapboxMobileEvents.xcframework` from SDK Registry
- NOTE: You **MUST** have a valid `.netrc` token

### `build-dependency.sh`

- Usage:
  ```
  sh build-dependency.sh <NAME> <GIT_REPO_URL> <GIT_TAG> <SCHEME>
  ```
- This script clones a given repository, checks out a `git tag`, and builds the specified `scheme`.
- Uses `xcodebuild`
- The `<NAME>` provided must match the name of the `.xcodeproj`.
- The `.xcodeproj` for the repository should be at the root of the repository.

### `create-xcframework.sh`

- Usage:
  ```
  sh create-xcframework.sh <PROJECT_PATH> <SCHEME> <PRODUCT_NAME>
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
