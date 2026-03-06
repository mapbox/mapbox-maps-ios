# Packaging MapboxMaps.xcframework

This folder contains scripts that package `MapboxMaps` and its dependencies as a
zipped archive of XCFrameworks.

## Requirements

- [`jq`](https://stedolan.github.io/jq/)
- Valid `.netrc` token for SDK registry

## Scripts

### `create-xcframework.sh`

- Usage:
  ```
  ./create-xcframework.sh <PROJECT_PATH> <SCHEME> <PRODUCT_NAME>
  ```
- Generic script to create an xcframework for a project located at the specified path.
- Uses `xcodebuild`
